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
        bar.searchTextField.allowsCopyingTokens = false
        navigationItem.titleView = bar
        navigationItem.backButtonTitle = String(localized: "Search", bundle: .module)
    }

    func focusSearch() {
        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
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
            cell.contentConfiguration = content
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: searchDrawer.collectionView) {
            collection, indexPath, item in
            collection.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }
        let header = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, indexPath in
            guard let section = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section] else { return }
            var content = UIListContentConfiguration.groupedHeader()
            content.text = section == .categories
                ? String(localized: "Categories", bundle: .module)
                : String(localized: "Places", bundle: .module)
            content.textProperties.color = .secondaryLabel
            view.contentConfiguration = content
        }
        dataSource.supplementaryViewProvider = { collection, _, indexPath in
            collection.dequeueConfiguredReusableSupplementary(using: header, for: indexPath)
        }
    }

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
        updateResults()
    }

    public func didPresentSearchController(_ searchController: UISearchController) {
        // UIKit completes placement of the search field after this callback.
        DispatchQueue.main.async { [weak self] in
            guard let self, self.searchController.isActive else { return }
            self.searchController.searchBar.searchTextField.becomeFirstResponder()
        }
    }
}

extension SearchDrawerViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let sheet = navigationController?.presentationController as? UISheetPresentationController {
            sheet.animateChanges { sheet.selectedDetentIdentifier = .large }
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
