//
//  ContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Pulley
import Crashlytics
import MapKit
import TagListView

enum DisplayMode {
    
    case list
    case search(searchTerm: String, tags: [NSAttributedString], items: [Location])
    case filter(searchTerm: String?, selectedTags: [String], items: [Location])
    
}

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let tagCell = "tagCell"
    
}

class ContentViewController: UIViewController {

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
    
    private lazy var drawer = { self.parent as! MainViewController }()
    private var normalColor = UIColor.clear
    private var highlightedColor = UIColor.clear
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    
    // MARK: - Data
    
    private var displayMode = DisplayMode.list
    
    private var locations: [Location] = []
    private var datasource: [Location] = []
    private var selectedTags: [String] = []
    private var tags: [String] = []
    
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
        
        self.gripperView.layer.cornerRadius = 2.5
        self.gripperView.backgroundColor = UIColor.lightGray
        self.topSeparatorView.backgroundColor = UIColor.lightGray
        self.topSeparatorView.alpha = 0.75
        self.bottomSeparatorView.backgroundColor = UIColor.clear
        
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.barStyle = .default
        self.searchBar.isTranslucent = true
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.placeholder = String.localized("SearchBarPrompt")
        self.searchBar.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.contentInsetAdjustmentBehavior = .never
        self.tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchResultCell)
        self.tableView.register(TagTableViewCell.self, forCellReuseIdentifier: CellIdentifier.tagCell)
        
        self.tagListView.delegate = self
        self.tagListView.enableRemoveButton = true
        
        self.headerSectionHeightConstraint.constant = 68.0
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.searchBar.barTintColor = theme.accentColor
            themeable.searchBar.backgroundColor = theme.backgroundColor
            themeable.searchBar.tintColor = theme.accentColor
            themeable.searchBar.textField?.textColor = theme.color
            themeable.topSeparatorView.backgroundColor = theme.separatorColor
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            themeable.normalColor = theme.backgroundColor
            themeable.highlightedColor = theme.backgroundColor.darker(by: 10)!
            themeable.searchBar.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            themeable.tagListView.tagBackgroundColor = theme.accentColor
            themeable.tagListView.textColor = theme.backgroundColor
            themeable.tagListView.removeIconLineColor = theme.backgroundColor
            
        }
        
    }
    
    private func generateDatasource() -> [Location] {
        
        self.tags = Array(Set(locations.map { $0.tags }.reduce([], +)))
        
        if LocationManager.shared.authorizationStatus == .authorizedAlways ||
            LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
         
            return locations.sorted(by: { (l1, l2) -> Bool in
                l1.distance < l2.distance
            })
            
        } else {
            return locations
        }
        
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
        
        if let mapController = drawer.primaryContentViewController as? MapViewController {
            
            AnalyticsManager.shared.logSelectedItemContent(location)
            
            mapController.map.selectAnnotation(location, animated: true)
            mapController.map.camera.altitude = 1000
            
        }
        
    }
    
    func arrayContainsSubset<T : Equatable>(array: [T], subset: [T]) -> Bool {
        return subset.reduce(true) { (result, item) in return result && array.contains(item) }
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
        
        if !tags.isEmpty && !locations.isEmpty {
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
        
        //Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
        
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
            cell.subtitleLabel.text = location.detailSubtitle
            cell.searchImageView.image = location.detailImage
            
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
            
            print(location.tags)
            
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
        
        if sender.tagViews.count == 0 {
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

extension ContentViewController: EntryDatasource, ShopDatasource, ParkingLotDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveEntries(_ entries: [Entry]) {
        
        self.locations.append(contentsOf: entries as [Entry])
        
        self.datasource = generateDatasource()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func didReceiveShops(_ shops: [Store]) {
        
    }
    
    func didReceiveParkingLots(_ parkingLots: [ParkingLot]) {
        
        self.locations.append(contentsOf: parkingLots as [Location])
        
        self.datasource = generateDatasource()
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveCameras(_ cameras: [Camera]) {
        
        self.locations.append(contentsOf: cameras as [Location])
        
        self.datasource = generateDatasource()
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStation]) {
        
        self.locations.append(contentsOf: petrolStations as [PetrolStation])
        
        self.datasource = generateDatasource()
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }

        
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
