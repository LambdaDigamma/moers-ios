//
//  SearchDrawerViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 18.10.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI
import Gestalt
import Pulley
import TagListView
import Fuse

enum DisplayMode {
    case list
    case search(searchTerm: String, tags: [NSAttributedString], items: [Location])
    case filter(searchTerm: String?, selectedTags: [String], items: [Location])
}

class SearchDrawerViewController: UIViewController {
    
    public let searchDrawer: SearchDrawerView
    
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    
    private var displayMode = DisplayMode.list
    private var locations: [Location] = []
    private var datasource: [Location] = []
    private var selectedTags: [String] = []
    private var tags: [String] = []
    
    private var normalColor = UIColor.clear
    private var highlightedColor = UIColor.clear
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.searchDrawer.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    public var locationManager: LocationManagerProtocol!
    
    init(locationManager: LocationManagerProtocol) {
        self.locationManager = locationManager
        self.searchDrawer = SearchDrawerView()
        super.init(nibName: nil, bundle: nil)
        self.searchDrawer.searchBar.delegate = self
        self.searchDrawer.tagList.delegate = self
        self.searchDrawer.tableView.delegate = self
        self.searchDrawer.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = searchDrawer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let feedbackGenerator = UISelectionFeedbackGenerator()
        self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
        pulleyViewController?.delegate = self
        pulleyViewController?.setDrawerPosition(position: .open, animated: false)
        
    }
    
    // MARK: - Data Handling
    
    private func updateDatasource() {
        
        self.tags = Array(Set(locations.map { $0.tags }.reduce([], +)))
        
        let updatedLocations = self.locationManager.updateDistances(locations: locations)
        
        updatedLocations.observeNext { locations in
            
            self.locations = locations.sorted(by: { (l1, l2) -> Bool in
                l1.distance < l2.distance
            })
            
            self.datasource = self.locations
            
            DispatchQueue.main.async {
                self.searchDrawer.tableView.reloadData()
            }
            
        }.dispose(in: bag)
        
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
            
            return (locations + filterLocations).sorted(by: { $0.distance < $1.distance }) // TODO
            
        } else {
            
            let filterLocations = datasource.filter { !$0.tags.isEmpty && arrayContainsSubset(array: $0.tags, subset: selectedTags) }.sorted(by: { $0.distance < $1.distance })
            
            return filterLocations
            
        }
        
    }
    
    private func selectLocaton(_ location: Location) {
        
        if let mapController = pulleyViewController?.primaryContentViewController as? MapViewController {
            
            AnalyticsManager.shared.logSelectedItemContent(location)
            
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
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + (pulleyViewController?.currentDisplayMode == .drawer ? bottomSafeArea : 0.0)
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        searchDrawer.tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open {
            searchDrawer.searchBar.resignFirstResponder()
        }
        
    }
    
}


extension SearchDrawerViewController: TagListViewDelegate {
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        self.selectedTags.removeAll(where: { $0 == title })
        
        sender.removeTagView(tagView)
        
        if sender.tagViews.count == 0 {
            self.searchDrawer.searchWrapperHeight.constant = 68.0
            self.displayMode = .list
            self.searchDrawer.tableView.reloadData()
        } else {
            let searchText = searchDrawer.searchBar.text ?? ""
            self.displayMode = .filter(searchTerm: searchText,
                                       selectedTags: selectedTags,
                                       items: filterLocations(with: searchText))
            self.searchDrawer.tableView.reloadData()
        }
        
    }
    
}

extension SearchDrawerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawer = self.parent as? MainViewController {
            drawer.setDrawerPosition(position: .open, animated: true)
        }
        
        let searchTerm = searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            
//            let tags = searchTags(with: searchTerm)
//            let items = searchLocations(with: searchTerm)
//
//            displayMode = .search(searchTerm: searchTerm, tags: tags, items: items)
            
            searchDrawer.tableView.reloadData()
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
        
        self.searchDrawer.tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text ?? ""
        
        let newSearchTerm: String? = searchText.isNotEmptyOrWhitespace ? searchText : nil
        
        self.displayMode = .filter(searchTerm: newSearchTerm,
                                   selectedTags: selectedTags,
                                   items: filterLocations(with: searchText))
        
        searchBar.resignFirstResponder()
        
        self.searchDrawer.tableView.reloadData()
        
    }
    
}

extension SearchDrawerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch displayMode {
        
        case .list:
            return datasource.count
            
        case .filter(_, let tags, let items):
            
            searchDrawer.tagList.removeAllTags()
            searchDrawer.tagList.addTags(tags)
            
            return items.count
            
        case .search(_, let tags, let items):
            
            if tags.count >= 5 {
                return 5 + items.count
            } else {
                return tags.count + items.count
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        func setupSearchResultCell(_ cell: SearchResultTableViewCell, _ location: Location) -> SearchResultTableViewCell {
            
            cell.titleLabel.text = location.title ?? ""
            cell.subtitleLabel.text = UIProperties.detailSubtitle(for: location)
            cell.searchImageView.image = UIProperties.detailImage(for: location)
            
            if let entry = location as? Entry {
                if entry.isValidated {
                    cell.checkmarkView.style = .green
                } else {
                    cell.checkmarkView.style = .nothing
                }
                
            } else {
                cell.checkmarkView.style = .green
            }
            
            return cell
            
        }
        
        switch displayMode {
            
        case .list:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
            
            let location = datasource[indexPath.row]
            
            return setupSearchResultCell(cell, location)
            
        case .filter(_, _, let items):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
            
            let location = items[indexPath.row]
            
            return setupSearchResultCell(cell, location)
            
        case .search(_, let tags, let items):
            
            let numberOfTags = tags.count >= 5 ? 5 : tags.count
            
            if indexPath.row < numberOfTags {
            
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.tagCell, for: indexPath) as! TagTableViewCell
                
                cell.titleLabel.attributedText = tags[indexPath.row]
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
                
                return setupSearchResultCell(cell, items[indexPath.row - numberOfTags])
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch displayMode {
            
        case .list:
            return 60
            
        case .search(_, let tags, _):
            
            let numberOfTags = tags.count >= 5 ? 5 : tags.count
            
            if indexPath.row < numberOfTags {
                return 50
            } else {
                return 60
            }
            
        case .filter(_, _, _):
            return 60
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        
        cell.backgroundColor = highlightedColor
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        
        cell.backgroundColor = normalColor
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch displayMode {
        
        case .list:
            selectLocaton(datasource[indexPath.row])
            
        case .filter(_, _, let items):
            selectLocaton(items[indexPath.row])
            
        case .search(_, let tags, let items):
            
            let numberOfTags = tags.count >= 5 ? 5 : tags.count
            
            if indexPath.row < numberOfTags {
                
                if !selectedTags.contains(tags[indexPath.row].string) {
                    self.selectedTags.append(tags[indexPath.row].string)
                }
                
                self.searchDrawer.searchBar.text = ""
                self.searchDrawer.searchWrapperHeight.constant = 98
                
                let filteredItems = filterLocations(with: "")
                
                self.displayMode = .filter(searchTerm: "", selectedTags: selectedTags, items: filteredItems)
                
                self.searchDrawer.tableView.reloadData()
                
            } else {
                
                selectLocaton(items[indexPath.row - numberOfTags])
                
            }
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        self.searchDrawer.searchBar.resignFirstResponder()
        
    }
    
}

extension SearchDrawerViewController: EntryDatasource, ParkingLotDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        
        self.locations = self.locations.filter { !($0 is Entry) }
        self.locations.append(contentsOf: entries as [Entry])
        
        self.updateDatasource()
        
    }
    
    func didReceiveParkingLots(_ parkingLots: [ParkingLot]) {
        
        self.locations = self.locations.filter { !($0 is ParkingLot) }
        self.locations.append(contentsOf: parkingLots as [Location])
        
        self.updateDatasource()
        
    }
    
    func didReceiveCameras(_ cameras: [Camera]) {
        
        self.locations = self.locations.filter { !($0 is Camera) }
        self.locations.append(contentsOf: cameras as [Location])
        
        self.updateDatasource()
        
    }
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStation]) {
        
        self.locations = self.locations.filter { !($0 is PetrolStation) }
        self.locations.append(contentsOf: petrolStations as [PetrolStation])
        
        self.updateDatasource()
        
    }
    
}

extension SearchDrawerViewController {
    
    private func arrayContainsSubset<T : Equatable>(array: [T], subset: [T]) -> Bool {
        return subset.reduce(true) { (result, item) in return result && array.contains(item) }
    }
    
}

extension SearchDrawerViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        self.normalColor = theme.backgroundColor
        self.highlightedColor = theme.backgroundColor.darker(by: 10)!
    }
    
}
