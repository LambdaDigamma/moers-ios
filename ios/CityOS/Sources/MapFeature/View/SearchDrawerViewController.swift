import Combine
import Core
import FactoryKit
import Fuse
import SwiftUI
import UIKit

public final class SearchDrawerViewController: UIViewController {
    
    @LazyInjected(\.locationManager) private var locationManager
    
    weak var container: MapContainerViewController?
    
    public let searchDrawer = SearchDrawerView()
    public let searchController = UISearchController(searchResultsController: nil)
    
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    private var locations: [Location] = []
    private var locationsByID: [Core.AnyLocation: Location] = [:]
    private var dataSource: UICollectionViewDiffableDataSource<MapSearchSection, SearchDrawerItem>!
    private var distanceUpdates: AnyCancellable?
    private(set) var isDismissingSearch = false
    private var retainedSearchText: String?
    private var retainedSearchTokens: [UISearchToken] = []
    private var searchDismissalCompletions: [() -> Void] = []
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        configureSearch()
        searchDrawer.collectionView.delegate = self
        configureDataSource()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        view = searchDrawer
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: SearchDrawerViewController, _) in
            controller.dataSource.applySnapshotUsingReloadData(controller.dataSource.snapshot())
        }
    }

    private func configureSearch() {
        
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        let bar = searchController.searchBar
        bar.delegate = self
        bar.placeholder = String(localized: "Where do you want to go?", bundle: .module)
        bar.accessibilityIdentifier = "SearchBar"
        bar.searchTextField.adjustsFontForContentSizeCategory = true
        bar.searchTextField.allowsDeletingTokens = true
        bar.searchTextField.allowsCopyingTokens = false
        bar.searchTextField.addTarget(self, action: #selector(searchCriteriaChanged), for: .editingChanged)
        navigationItem.titleView = bar
        navigationItem.backButtonTitle = String(localized: "Search", bundle: .module)
    }

    func focusSearch() {
        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }

    func endSearch(completion: (() -> Void)? = nil) {
        guard searchController.isActive || isDismissingSearch else {
            searchController.searchBar.resignFirstResponder()
            completion?()
            return
        }
        if let completion { searchDismissalCompletions.append(completion) }
        if retainedSearchText == nil {
            retainedSearchText = searchController.searchBar.text ?? ""
            retainedSearchTokens = searchController.searchBar.searchTextField.tokens
        }
        searchController.isActive = false
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sheet = navigationController?.presentationController as? UISheetPresentationController
        let isCompact = navigationController?.presentingViewController != nil
            && sheet?.selectedDetentIdentifier == MapSheetPresentationController.compactDetent
        searchDrawer.collectionView.isHidden = isCompact
        searchDrawer.collectionView.isScrollEnabled = !isCompact
    }

    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, SearchDrawerItem> {
            [weak self] cell, _, item in
            guard let self else { return }
            var content = UIListContentConfiguration.subtitleCell()
            switch item {
            case .category(let category):
                content.text = category
                content.image = UIImage(systemName: "magnifyingglass")
                content.imageProperties.tintColor = .tintColor
                content.textProperties.color = .label
                cell.accessories = []
            case .location(let identifier):
                guard let location = locationsByID[identifier] else { return }
                content = UIProperties.listContent(for: location)
                cell.accessories = [.disclosureIndicator()]
            }
            // Use the page's appearance while UIKit moves existing cells into active search.
            content.textProperties.color = UIColor.label.resolvedColor(with: traitCollection)
            content.secondaryTextProperties.color = UIColor.secondaryLabel.resolvedColor(with: traitCollection)
            cell.contentConfiguration = content
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: searchDrawer.collectionView) {
            collection, indexPath, item in
            collection.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
        let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, indexPath in
            guard let self else { return }
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            var content = UIListContentConfiguration.groupedHeader()
            content.text = section == .categories
                ? String(localized: "Categories", bundle: .module)
                : String(localized: "Places", bundle: .module)
            content.textProperties.color = UIColor.secondaryLabel.resolvedColor(with: traitCollection)
            view.contentConfiguration = content
        }
        dataSource.supplementaryViewProvider = { collection, _, indexPath in
            collection.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
        }
    }

    @objc private func searchCriteriaChanged() { updateResults() }

    private func updateResults() {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedCategories = searchController.searchBar.searchTextField.tokens.compactMap { $0.representedObject as? String }
        let categories = Array(Set(locations.flatMap(\.tags))).sorted()
            .filter { !selectedCategories.contains($0) }
        let suggestions = query.isEmpty ? Array(categories.prefix(4)) : fuse.search(query, in: categories)
            .sorted { $0.score < $1.score }.prefix(5).map { categories[$0.index] }
        let matches: [Location] = query.isEmpty ? locations : fuse.search(query, in: locations.map(\.name))
            .sorted { $0.score < $1.score }.map { locations[$0.index] }
        let results = matches.filter { location in selectedCategories.allSatisfy { location.tags.contains($0) } }
        locationsByID.removeAll(keepingCapacity: true)
        var snapshot = NSDiffableDataSourceSnapshot<MapSearchSection, SearchDrawerItem>()
        if !suggestions.isEmpty {
            snapshot.appendSections([.categories])
            snapshot.appendItems(suggestions.map(SearchDrawerItem.category), toSection: .categories)
        }
        snapshot.appendSections([.places])
        var seen = Set<Core.AnyLocation>()
        snapshot.appendItems(results.compactMap { location in
            let identifier = Core.AnyLocation(location)
            guard seen.insert(identifier).inserted else { return nil }
            locationsByID[identifier] = location
            return .location(identifier)
        }, toSection: .places)
        let previousItems = Set(dataSource.snapshot().itemIdentifiers)
        snapshot.reconfigureItems(snapshot.itemIdentifiers.filter { previousItems.contains($0) })
        dataSource.apply(snapshot, animatingDifferences: false)
        if results.isEmpty, suggestions.isEmpty, !query.isEmpty || !selectedCategories.isEmpty {
            var empty = UIContentUnavailableConfiguration.search()
            empty.text = String(localized: "No Results", bundle: .module)
            searchDrawer.collectionView.backgroundView = UIContentUnavailableView(configuration: empty)
        } else {
            searchDrawer.collectionView.backgroundView = nil
        }
    }

    private func updateLocations() {
        updateResults()
        distanceUpdates = locationManager.updateDistances(locations: locations)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] locations in
                self?.locations = locations.sorted { $0.distance < $1.distance }
                self?.updateResults()
            }
    }

    public func addLocation(_ location: Location) {
        locations.append(location)
        updateLocations()
    }

    nonisolated deinit {}
}

extension SearchDrawerViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    public func updateSearchResults(for searchController: UISearchController) {
        guard retainedSearchText == nil else { return }
        updateResults()
    }

    public func didPresentSearchController(_ searchController: UISearchController) {
        // UIKit completes placement of the search field after this callback.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.searchController.isActive else { return }
            self.searchController.searchBar.searchTextField.becomeFirstResponder()
        }
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        isDismissingSearch = true
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        isDismissingSearch = false
        if let retainedSearchText {
            searchController.searchBar.text = retainedSearchText
            searchController.searchBar.searchTextField.tokens = retainedSearchTokens
        }
        retainedSearchText = nil
        retainedSearchTokens = []
        updateResults()
        let completions = searchDismissalCompletions
        searchDismissalCompletions.removeAll()
        completions.forEach { $0() }
    }
}

extension SearchDrawerViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let sheet = navigationController?.presentationController as? UISheetPresentationController {
            sheet.animateChanges { sheet.selectedDetentIdentifier = .large }
        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.searchTextField.tokens = []
        updateResults()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateResults()
        searchBar.resignFirstResponder()
    }
    
}

extension SearchDrawerViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .category(let category):
            let field = searchController.searchBar.searchTextField
            let token = UISearchToken(icon: UIImage(systemName: "tag"), text: category)
            token.representedObject = category
            field.insertToken(token, at: field.tokens.count)
            searchController.searchBar.text = ""
            updateResults()
        case .location(let identifier):
            guard let location = locationsByID[identifier] else { return }
            container?.showLocation(location, fromList: true)
        }
        
    }
}

extension SearchDrawerViewController: EntryDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        locations.removeAll { $0 is Entry }
        locations.append(contentsOf: entries)
        updateLocations()
    }

    func didReceiveCameras(_ cameras: [Camera]) {
        locations.removeAll { $0 is Camera }
        locations.append(contentsOf: cameras)
        updateLocations()
    }

    func didReceivePetrolStations(_ stations: [PetrolStationViewModel]) {
        locations.removeAll { $0 is PetrolStationViewModel }
        locations.append(contentsOf: stations)
        updateLocations()
    }
    
}

#Preview {
    let controller = SearchDrawerViewController()
    controller.addLocation(Camera.stub(withID: 1))
    return UINavigationController(rootViewController: controller)
}
