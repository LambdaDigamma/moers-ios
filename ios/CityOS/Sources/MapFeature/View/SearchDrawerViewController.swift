//
//  SearchDrawerViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 18.10.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI

import Pulley
import TagListView
import Fuse
import Combine
import Factory
//import NewsFeature

public enum DisplayMode {
    case list
    case search(searchTerm: String, tags: [NSAttributedString], items: [Location])
    case filter(searchTerm: String?, selectedTags: [String], items: [Location])
}

enum SearchDrawerItem: Hashable {
    case tag(NSAttributedString, id: String)
    case location(AnyLocation)
    
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
    
    static func == (lhs: SearchDrawerItem, rhs: SearchDrawerItem) -> Bool {
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

// swiftlint:disable file_length
public class SearchDrawerViewController: UIViewController {
    
    public let searchDrawer: SearchDrawerView
    
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    
    private var displayMode = DisplayMode.list
    private var locations: [Location] = []
    private var datasource: [Location] = []
    private var selectedTags: [String] = []
    private var tags: [String] = []
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, SearchDrawerItem>!
    
    private var cancellables = Set<AnyCancellable>()
    private var normalColor = UIColor.clear
    private var highlightedColor = UIColor.clear
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.searchDrawer.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    @LazyInjected(\.locationManager) private var locationManager
    
    public init() {
        self.searchDrawer = SearchDrawerView()
        super.init(nibName: nil, bundle: nil)
        self.searchDrawer.searchBar.delegate = self
        self.searchDrawer.tagList.delegate = self
        self.configureDataSource()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = searchDrawer
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pulleyViewController?.delegate = self
        pulleyViewController?.setDrawerPosition(position: .open, animated: false)
        
    }
    
    // MARK: - Collection View
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, SearchDrawerItem>(
            collectionView: searchDrawer.collectionView
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
                let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnyLocation> { cell, indexPath, anyLoc in
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
                                title: location.title ?? "",
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
        
        searchDrawer.collectionView.delegate = self
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchDrawerItem>()
        snapshot.appendSections([0])
        
        let items = itemsForCurrentDisplayMode()
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func itemsForCurrentDisplayMode() -> [SearchDrawerItem] {
        switch displayMode {
        case .list:
            return datasource.map { .location(AnyLocation($0)) }
            
        case .filter(_, let tagStrings, let items):
            searchDrawer.tagList.removeAllTags()
            searchDrawer.tagList.addTags(tagStrings)
            return items.map { .location(AnyLocation($0)) }
            
        case .search(_, let tagAttrs, let items):
            let numberOfTags = min(tagAttrs.count, 5)
            var result: [SearchDrawerItem] = []
            
            for i in 0..<numberOfTags {
                let id = "\(tagAttrs[i].string)-\(i)"
                result.append(.tag(tagAttrs[i], id: id))
            }
            
            result.append(contentsOf: items.map { .location(AnyLocation($0)) })
            
            return result
        }
    }
    
    // MARK: - Data Handling
    
    private func updateDatasource() {
        
        self.tags = Array(Set(locations.map { $0.tags }.reduce([], +)))
        
        let updatedLocations = self.locationManager.updateDistances(locations: locations)
        
        updatedLocations
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                
             } receiveValue: { (locations: [Location]) in
                
                self.locations = locations.sorted(by: { (location1, location2) -> Bool in
                    location1.distance < location2.distance
                })
                
                self.datasource = self.locations
                
                DispatchQueue.main.async {
                    self.updateSnapshot()
                }
                
            }
            .store(in: &cancellables)
        
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
        
        if let mapController = pulleyViewController?.primaryContentViewController as? MapViewController {
            
//            AnalyticsManager.shared.logSelectedItemContent(location)
            
            mapController.map.selectAnnotation(location, animated: true)
            mapController.map.camera.altitude = 1000
            
        }
        
    }
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        self.updateDatasource()
        
    }
    
}

extension SearchDrawerViewController: PulleyDrawerViewControllerDelegate {
    
    public func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    public func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    public func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    public func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        searchDrawer.collectionView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open {
            searchDrawer.searchBar.resignFirstResponder()
        }
        
    }
    
}

extension SearchDrawerViewController: TagListViewDelegate {
    
    public func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        self.selectedTags.removeAll(where: { $0 == title })
        
        sender.removeTagView(tagView)
        
        if sender.tagViews.isEmpty {
            self.searchDrawer.searchWrapperHeight.constant = 68.0
            self.displayMode = .list
            self.updateSnapshot()
        } else {
            let searchText = searchDrawer.searchBar.text ?? ""
            self.displayMode = .filter(searchTerm: searchText,
                                       selectedTags: selectedTags,
                                       items: filterLocations(with: searchText))
            self.updateSnapshot()
        }
        
    }
    
}

extension SearchDrawerViewController: UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawer = self.parent as? MainViewController {
            drawer.setDrawerPosition(position: .open, animated: true)
        }
        
        let searchTerm = searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            
//            let tags = searchTags(with: searchTerm)
//            let items = searchLocations(with: searchTerm)
//
//            displayMode = .search(searchTerm: searchTerm, tags: tags, items: items)
            
            updateSnapshot()
            
        }
        
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let tagsNotEmpty = !tags.isEmpty
        let locationsNotEmpty = !locations.isEmpty
        let cellAtIndex0Exists = searchDrawer.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil
        
        if tagsNotEmpty && locationsNotEmpty && cellAtIndex0Exists {
            
            self.searchDrawer.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                    at: UITableView.ScrollPosition.top,
                                                    animated: false)
            
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
        
        self.updateSnapshot()
        
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text ?? ""
        
        let newSearchTerm: String? = searchText.isNotEmptyOrWhitespace ? searchText : nil
        
        self.displayMode = .filter(searchTerm: newSearchTerm,
                                   selectedTags: selectedTags,
                                   items: filterLocations(with: searchText))
        
        searchBar.resignFirstResponder()
        
        self.updateSnapshot()
        
    }
    
}

extension SearchDrawerViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .tag(let attrString, _):
            // Handle tag selection
            if !selectedTags.contains(attrString.string) {
                self.selectedTags.append(attrString.string)
            }
            
            self.searchDrawer.searchBar.text = ""
            self.searchDrawer.searchWrapperHeight.constant = 98
            
            let filteredItems = filterLocations(with: "")
            
            self.displayMode = .filter(searchTerm: "", selectedTags: selectedTags, items: filteredItems)
            
            self.updateSnapshot()
            
        case .location(let anyLocation):
            selectLocaton(anyLocation.location)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.searchDrawer.searchBar.resignFirstResponder()
        
    }
    
}

extension SearchDrawerViewController: EntryDatasource, CameraDatasource, PetrolDatasource {
    
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

extension SearchDrawerViewController {
    
    private func arrayContainsSubset<T : Equatable>(array: [T], subset: [T]) -> Bool {
        return subset.allSatisfy { (item) in
            return array.contains(item)
        }
    }
    
}

