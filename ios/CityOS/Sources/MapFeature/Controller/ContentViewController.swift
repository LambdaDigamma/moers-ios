//
//  ContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI

import Pulley
import MapKit
import TagListView
import Fuse
import Combine
import Core
import Factory

// swiftlint:disable file_length

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let tagCell = "tagCell"
    
}

enum ContentDrawerItem: Hashable {
    case tag(NSAttributedString, id: String)
    case location(Core.AnyLocation)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .tag(_, let id):
            hasher.combine("tag")
            hasher.combine(id)
        case .location(let anyLocation):
            hasher.combine("location")
            hasher.combine(anyLocation)
        }
    }
    
    static func == (lhs: ContentDrawerItem, rhs: ContentDrawerItem) -> Bool {
        switch (lhs, rhs) {
        case (.tag(_, let id1), .tag(_, let id2)):
            return id1 == id2
        case (.location(let loc1), .location(let loc2)):
            return loc1 == loc2
        default:
            return false
        }
    }
}

class ContentViewController: UIViewController {

    @LazyInjected(\.locationService) var locationService
    
    // MARK: - UI
    
    private let contentDrawerView = ContentDrawerView()
    private var dataSource: UICollectionViewDiffableDataSource<Int, ContentDrawerItem>!
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.contentDrawerView.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    // swiftlint:disable:next force_cast
    private lazy var drawer = { self.parent as! MainViewController }()
    private var normalColor = UIColor.clear
    private var highlightedColor = UIColor.clear
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Data
    
    private var displayMode = DisplayMode.list
    private var locations: [Location] = []
    private var datasource: [Location] = []
    private var selectedTags: [String] = []
    private var tags: [String] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func loadView() {
        view = contentDrawerView
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        self.configureDataSource()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.setupPulleyUI()
        self.setupSearchBar()
        self.setupTagListView()
        
        self.contentDrawerView.headerSectionHeightConstraint.constant = 68.0
        
    }
    
    private func setupPulleyUI() {
        // Gripper and separators are already configured in ContentDrawerView
    }
    
    private func setupSearchBar() {
        self.contentDrawerView.searchBar.delegate = self
    }
    
    private func setupTagListView() {
        self.contentDrawerView.tagListView.delegate = self
    }
    
    // MARK: - Collection View
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, ContentDrawerItem>(
            collectionView: contentDrawerView.collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewListCell() }
            
            switch item {
            case .tag(let attributedString, _):
                let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSAttributedString> { cell, indexPath, attrStr in
                    if #available(iOS 16.0, *) {
                        cell.contentConfiguration = UIHostingConfiguration {
                            Text(AttributedString(attrStr))
                                .font(.system(size: 17))
                        }
                        .margins(.all, 0)
                    } else {
                        var content = cell.defaultContentConfiguration()
                        content.attributedText = attrStr
                        cell.contentConfiguration = content
                    }
                    cell.accessories = []
                }
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: attributedString
                )
                
            case .location(let anyLocation):
                    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Core.AnyLocation> { cell, indexPath, anyLoc in
                    let location = anyLoc.location
                    let showCheckmark: Bool
                    if let entry = location as? Entry {
                        showCheckmark = entry.isValidated
                    } else {
                        showCheckmark = true
                    }
                    
                    if #available(iOS 16.0, *) {
                        cell.contentConfiguration = UIHostingConfiguration {
                            SearchResultCellView(
                                image: UIProperties.detailImage(for: location),
                                title: (location.title ?? "") ?? "",
                                subtitle: UIProperties.detailSubtitle(for: location),
                                showCheckmark: showCheckmark
                            )
                        }
                        .margins(.all, 0)
                    } else {
                        var content = cell.defaultContentConfiguration()
                        content.text = location.title ?? ""
                        content.secondaryText = UIProperties.detailSubtitle(for: location)
                        content.image = UIProperties.detailImage(for: location)
                        cell.contentConfiguration = content
                    }
                    cell.accessories = [.disclosureIndicator()]
                }
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: anyLocation
                )
            }
        }
        
        contentDrawerView.collectionView.delegate = self
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ContentDrawerItem>()
        snapshot.appendSections([0])
        
        let items = itemsForCurrentDisplayMode()
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func itemsForCurrentDisplayMode() -> [ContentDrawerItem] {
        switch displayMode {
        case .list:
            return datasource.map { .location(AnyLocation($0)) }
            
        case .filter(_, let tagStrings, let items):
            contentDrawerView.tagListView.removeAllTags()
            contentDrawerView.tagListView.addTags(tagStrings)
            return items.map { .location(AnyLocation($0)) }
            
        case .search(_, let tagAttrs, let items):
            let numberOfTags = min(tagAttrs.count, 5)
            var result: [ContentDrawerItem] = []
            
            for i in 0..<numberOfTags {
                let id = "\(tagAttrs[i].string)-\(i)"
                result.append(.tag(tagAttrs[i], id: id))
            }
            
            result.append(contentsOf: items.map { .location(AnyLocation($0)) })
            
            return result
        }
    }
    
    private func setupTheming() {
        
    }
    
    private func updateDatasource() {
        
        self.tags = Array(Set(locations.map { $0.tags }.reduce([], +)))
        
        // todo: !!!
//        let updatedLocations = self.locationService.updateDistances(locations: locations)
//
//        updatedLocations.sink { _ in
//
//        } receiveValue: { (locations: [Location]) in
//
//            self.locations = locations.sorted(by: { (location1, location2) -> Bool in
//                location1.distance < location2.distance
//            })
//
//            self.datasource = self.locations
//
//            DispatchQueue.main.async {
//                self.updateSnapshot()
//            }
//
//        }
//        .store(in: &cancellables)
        
    }
    
    private func searchTags(with searchTerm: String) -> [NSAttributedString] {
    
        let results = fuse.search(searchTerm, in: tags)
        
        let boldAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        
        let filteredTags: [NSAttributedString] = results.sorted(by: { $0.score < $1.score }).map { result in
            
            let tag = tags[result.index]
            
            let attributedString = NSMutableAttributedString(string: tag)
            
            result.ranges.map(Range.init).map(NSRange.init).forEach {
                attributedString.addAttributes(boldAttrs, range: $0)
            }
            
            return attributedString
            
        }
        
        return filteredTags
        
    }
    
    private func searchLocations(with searchTerm: String) -> [Location] {
        
        let results = fuse.search(searchTerm, in: locations)
                          .sorted(by: { $0.score < $1.score })
                          .map { locations[$0.index] }
        
        return results
        
    }
    
    private func filterLocations(with searchTerm: String) -> [Location] {
        
        if searchTerm.isNotEmptyOrWhitespace {
            
            let locations = searchLocations(with: searchTerm)
            
            let isEmpty = selectedTags.isEmpty
            
            let filterLocations = datasource.filter { !isEmpty && arrayContainsSubset(array: $0.tags, subset: selectedTags) }
            
            return (locations + filterLocations).sorted(by: { $0.distance < $1.distance }) // todo
            
        } else {
            
            let filterLocations = datasource.filter { !$0.tags.isEmpty && arrayContainsSubset(array: $0.tags, subset: selectedTags) }.sorted(by: { $0.distance < $1.distance })
            
            return filterLocations
            
        }
        
    }
    
    private func selectLocaton(_ location: Location) {
        
        if let mapController = drawer.primaryContentViewController as? MapViewController {
            
//            AnalyticsManager.shared.logSelectedItemContent(location)
            
            mapController.map.selectAnnotation(location, animated: true)
            mapController.map.camera.altitude = 1000
            
        }
        
    }
    
    func arrayContainsSubset<T : Equatable>(array: [T], subset: [T]) -> Bool {
        return subset.allSatisfy { (item) in
            return array.contains(item)
        }
    }
    
    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        self.updateDatasource()
        
    }
    
}

extension ContentViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = self.parent as? MainViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
        
        let searchTerm = contentDrawerView.searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            
            let tags = searchTags(with: searchTerm)
            let items = searchLocations(with: searchTerm)
            
            displayMode = .search(searchTerm: searchTerm, tags: tags, items: items)
            
            updateSnapshot()
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Scroll to top if needed (UICollectionView doesn't need cellForItem check)
        if !tags.isEmpty && !locations.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            if contentDrawerView.collectionView.numberOfItems(inSection: 0) > 0 {
                contentDrawerView.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            }
        }
        
        if searchText.isNotEmptyOrWhitespace {
            
            let tags = searchTags(with: searchText)
            let items = searchLocations(with: searchText)
            
            displayMode = .search(searchTerm: searchText, tags: tags, items: items)
            
        } else {
            
            if selectedTags.isEmpty {
                displayMode = .list
            } else {
                displayMode = .filter(searchTerm: nil, selectedTags: selectedTags, items: filterLocations(with: ""))
            }
            
        }
        
        updateSnapshot()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = contentDrawerView.searchBar.text ?? ""
        
        if searchText.isNotEmptyOrWhitespace {
            
            let filteredItems = filterLocations(with: searchText)
            
            self.displayMode = .filter(searchTerm: searchText, selectedTags: selectedTags, items: filteredItems)
            
        } else {
            
            let filteredItems = filterLocations(with: searchText)
            
            self.displayMode = .filter(searchTerm: nil, selectedTags: selectedTags, items: filteredItems)
            
        }
        
        contentDrawerView.searchBar.resignFirstResponder()
        
        updateSnapshot()
        
        // Answers.logSearch(withQuery: contentDrawerView.searchBar.text, customAttributes: nil)
        
    }
    
}

extension ContentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .tag(let attrString, _):
            // Handle tag selection
            if !selectedTags.contains(attrString.string) {
                self.selectedTags.append(attrString.string)
            }
            
            self.contentDrawerView.searchBar.text = ""
            
            self.contentDrawerView.headerSectionHeightConstraint.constant = 98
            
            let filteredItems = filterLocations(with: "")
            
            self.displayMode = .filter(searchTerm: "", selectedTags: selectedTags, items: filteredItems)
            
            self.updateSnapshot()
            
        case .location(let anyLocation):
            selectLocaton(anyLocation.location)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.contentDrawerView.searchBar.resignFirstResponder()
        
    }
    
}


extension ContentViewController: TagListViewDelegate {
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        self.selectedTags.removeAll(where: { $0 == title })
        
        sender.removeTagView(tagView)
        
        if sender.tagViews.isEmpty {
            self.contentDrawerView.headerSectionHeightConstraint.constant = 68.0
            self.displayMode = .list
            self.updateSnapshot()
        } else {
            let searchText = contentDrawerView.searchBar.text ?? ""
            self.displayMode = .filter(searchTerm: searchText, selectedTags: selectedTags, items: filterLocations(with: searchText))
            self.updateSnapshot()
        }
        
    }
    
}

extension ContentViewController: EntryDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        
        self.locations = self.locations.filter { !($0 is Entry) }
        self.locations.append(contentsOf: entries as [Entry])
        
        self.updateDatasource()
        
    }
    
    func didReceiveCameras(_ cameras: [Camera]) {
        
        self.locations = self.locations.filter { !($0 is Camera) }
        self.locations.append(contentsOf: cameras as [Location])
        
        self.updateDatasource()
        
    }
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStationViewModel]) {
        
        self.locations = self.locations.filter { !($0 is PetrolStationViewModel) }
        self.locations.append(contentsOf: petrolStations as [PetrolStationViewModel])
        
        self.updateDatasource()
        
    }
    
}

extension ContentViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        let height = drawer.mapViewController.map.frame.height
        
        if drawer.currentDisplayMode == .panel {
            return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
        }
        
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        
        if drawer.currentDisplayMode == .panel {
            self.contentDrawerView.gripperView.isHidden = true
            
            return [PulleyPosition.partiallyRevealed]
        }
        
        return PulleyPosition.all
        
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        //        if drawer.drawerPosition == .collapsed {
        //            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        //        } else {
        //            headerSectionHeightConstraint.constant = 68.0
        //        }
        
        contentDrawerView.collectionView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open {
            contentDrawerView.searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .panel {
            self.contentDrawerView.topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            self.contentDrawerView.bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            self.contentDrawerView.topSeparatorView.isHidden = false
            self.contentDrawerView.bottomSeparatorView.isHidden = true
        }
        
    }
    
}

