//
//  ContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit

import Pulley
import MapKit
import TagListView
import Fuse
import Combine
import Core
import Resolver

// swiftlint:disable file_length

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let tagCell = "tagCell"
    
}

class ContentViewController: UIViewController {

    @LazyInjected var locationService: LocationService
    
    // MARK: - UI
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    @IBOutlet weak var tagListView: TagListView!
    
    @IBOutlet weak var gripperTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSectionHeightConstraint: NSLayoutConstraint!
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
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
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.setupPulleyUI()
        self.setupSearchBar()
        self.setupTableView()
        self.setupTagListView()
        
        self.headerSectionHeightConstraint.constant = 68.0
        
    }
    
    private func setupPulleyUI() {
        self.gripperView.layer.cornerRadius = 2.5
        self.gripperView.backgroundColor = UIColor.lightGray
        self.topSeparatorView.backgroundColor = UIColor.lightGray
        self.topSeparatorView.alpha = 0.75
        self.bottomSeparatorView.backgroundColor = UIColor.clear
    }
    
    private func setupSearchBar() {
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.barStyle = .default
        self.searchBar.isTranslucent = true
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.placeholder = String.localized("SearchBarPrompt")
        self.searchBar.delegate = self
    }
    
    private func setupTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchResultCell)
        self.tableView.register(TagTableViewCell.self, forCellReuseIdentifier: CellIdentifier.tagCell)
    }
    
    private func setupTagListView() {
        self.tagListView.delegate = self
        self.tagListView.enableRemoveButton = true
        self.tagListView.paddingX = 12
        self.tagListView.paddingY = 7
        self.tagListView.marginX = 10
        self.tagListView.marginY = 7
        self.tagListView.removeIconLineWidth = 2
        self.tagListView.removeButtonIconSize = 7
        self.tagListView.textFont = UIFont.boldSystemFont(ofSize: 10)
        self.tagListView.cornerRadius = 10
        self.tagListView.backgroundColor = UIColor.clear
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
//                self.tableView.reloadData()
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
        
        let searchTerm = searchBar.text ?? ""
        
        if !searchTerm.isEmpty {
            
            let tags = searchTags(with: searchTerm)
            let items = searchLocations(with: searchTerm)
            
            displayMode = .search(searchTerm: searchTerm, tags: tags, items: items)
            
            tableView.reloadData()
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !tags.isEmpty && !locations.isEmpty && tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
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
        
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text ?? ""
        
        if searchText.isNotEmptyOrWhitespace {
            
            let filteredItems = filterLocations(with: searchText)
            
            self.displayMode = .filter(searchTerm: searchText, selectedTags: selectedTags, items: filteredItems)
            
        } else {
            
            let filteredItems = filterLocations(with: searchText)
            
            self.displayMode = .filter(searchTerm: nil, selectedTags: selectedTags, items: filteredItems)
            
        }
        
        searchBar.resignFirstResponder()
        
        tableView.reloadData()
        
        // Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
        
    }
    
}

extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(displayMode)
        
        switch displayMode {
        
        case .list:
            return datasource.count
            
        case .filter(_, let tags, let items):
            
            tagListView.removeAllTags()
            tagListView.addTags(tags)
            
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
            
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
            
            let location = datasource[indexPath.row]
            
            return setupSearchResultCell(cell, location)
            
        case .filter(_, _, let items):
            
            // swiftlint:disable force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
            
            let location = items[indexPath.row]
            
            print(location.tags)
            
            return setupSearchResultCell(cell, location)
            
        case .search(_, let tags, let items):
            
            let numberOfTags = tags.count >= 5 ? 5 : tags.count
            
            if indexPath.row < numberOfTags {
            
                // swiftlint:disable force_cast
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.tagCell, for: indexPath) as! TagTableViewCell
                
                cell.titleLabel.attributedText = tags[indexPath.row]
                
                return cell
                
            } else {
                
                // swiftlint:disable force_cast
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
            
        case .filter:
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
                
                self.searchBar.text = ""
                
                self.headerSectionHeightConstraint.constant = 98
                
                let filteredItems = filterLocations(with: "")
                
                self.displayMode = .filter(searchTerm: "", selectedTags: selectedTags, items: filteredItems)
                
                self.tableView.reloadData()
                
            } else {
                
                selectLocaton(items[indexPath.row - numberOfTags])
                
            }
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
        
    }
    
}

extension ContentViewController: TagListViewDelegate {
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        self.selectedTags.removeAll(where: { $0 == title })
        
        sender.removeTagView(tagView)
        
        if sender.tagViews.isEmpty {
            self.headerSectionHeightConstraint.constant = 68.0
            self.displayMode = .list
            self.tableView.reloadData()
        } else {
            let searchText = searchBar.text ?? ""
            self.displayMode = .filter(searchTerm: searchText, selectedTags: selectedTags, items: filterLocations(with: searchText))
            self.tableView.reloadData()
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
            
            self.gripperView.isHidden = true
            
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
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .panel
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .panel {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
        
    }
    
}

