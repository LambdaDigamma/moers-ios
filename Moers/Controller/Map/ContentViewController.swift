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

public enum SearchStyle {
    
    case none
    case branchSearch
    case textSearch
    
}

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let branchCell = "branchCell"
    static let filterCell = "filterCell"
    
}

class ContentViewController: UIViewController, PulleyDrawerViewControllerDelegate, UISearchBarDelegate {

    // MARK: - UI
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var bottomSeparatorView: UIView!
    
    @IBOutlet weak var gripperTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSectionHeightConstraint: NSLayoutConstraint!
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    private let cellHeight: CGFloat = 80
    private var normalColor = UIColor.clear
    private var highlightedColor = UIColor.clear
    private lazy var drawer = { self.parent as! MainViewController }()
    
    // MARK: - Data
    
    private var locations: [Location] = []
    private var filteredLocations: [Location] = []
    private var branches: [Branch] = []
    private var selectedBranch: Branch?
    public var searchStyle = SearchStyle.none
    
    var datasource: [Location] = []
    
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
        self.tableView.register(BranchTableViewCell.self, forCellReuseIdentifier: CellIdentifier.branchCell)
        self.tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: CellIdentifier.filterCell)
        
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
            
        }
        
    }
    
    private func generateDatasource() -> [Location] {
        
        if searchBar.text == "" && searchStyle == .none {
            return locations.sorted { t1, t2 in
                if t1 is Shop && t2 is Shop {
                    return t1.name < t2.name
                } else if t1 is ParkingLot && t2 is ParkingLot {
                    return t1.name < t2.name
                } else if t1 is Camera && t2 is Camera {
                    return t1.name < t2.name
                } else if t1 is PetrolStation && t2 is PetrolStation {
                  return t1.name < t2.name
                } else if t1 is Shop && !(t2 is Shop) {
                    return true
                } else if t1 is ParkingLot && t2 is Shop {
                    return false
                } else if t1 is PetrolStation && t2 is ParkingLot {
                    return false
                } else if t1 is PetrolStation && t2 is Camera {
                    return false
                } else {
                    return false
                }
            }
        } else {
            return filteredLocations
        }
        
    }
    
    public func onSelect(item: Branch) {
        
        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }

        selectedBranch = item
        
        AnalyticsManager.shared.logSelectedBranch(item.name)
        
        searchStyle = .branchSearch
        
        filteredLocations = locations.filter { (location) -> Bool in

            guard let shop = location as? Store else { return false }

            if shop.branch == item.name {
                return true
            } else {
                return false
            }

        }

        tableView.reloadData()
        
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = self.parent as? MainViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let fuzziness = 1.0 //0.75
        let threshold = 0.5 // 0.5
        
        var locs: [Location] = []
        
        if searchText != "" {
            
            for location in locations {
                
                if location.name.score(searchText, fuzziness: fuzziness) >= threshold {
                    
                    locs.append(location)
                    
                    continue
                    
                } else if location is ParkingLot {
                    
                    let loc = location as! ParkingLot
                    
                    if loc.address.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.subtitle!.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                    }
                    
                    
                } else if location is Shop {
                    
                    let loc = location as! Shop
                    
                    if loc.branch.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.place.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.street.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.quater.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if loc.houseNumber.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    }
                    
                } else if location is Camera {
                    
                    let loc = location as! Camera
                    
                    if loc.title!.score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    } else if "360° Kamera".score(searchText, fuzziness: fuzziness) >= threshold {
                        
                        locs.append(location)
                        
                        continue
                        
                    }
                    
                }
                
            }
            
        }
        
        if searchText != "" {
            
            searchStyle = .none
            
        }
        
        filteredLocations = locs
        
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
        
        searchBar.resignFirstResponder()
        
    }
    
    // MARK: - PulleyDrawerViewControllerDelegate
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        
        let height = drawer.mapViewController.map.frame.height
        
        if drawer.currentDisplayMode == .leftSide {
            return height - 49.0 - 16.0 - 16.0 - 64.0 - 50.0 - 16.0
        }
        
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        
        if drawer.currentDisplayMode == .leftSide {
            
            self.gripperView.isHidden = true
            
            return [PulleyPosition.partiallyRevealed]
        }
        
        return PulleyPosition.all
        
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        if drawer.drawerPosition == .collapsed {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        } else {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open || drawer.currentDisplayMode == .leftSide
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
        if drawer.currentDisplayMode == .leftSide {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeparatorView.isHidden = drawer.drawerPosition == .collapsed
        } else {
            topSeparatorView.isHidden = false
            bottomSeparatorView.isHidden = true
        }
        
    }
    
}

extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("generateDatasource")
        
        datasource = generateDatasource()
        
        if searchStyle == SearchStyle.textSearch {
            return datasource.count
        } else {
            return datasource.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchStyle == .none && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.branchCell, for: indexPath) as! BranchTableViewCell
            
            cell.branches = branches
            cell.onSelect = onSelect
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if searchStyle == .branchSearch && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filterCell, for: indexPath) as! FilterTableViewCell
            
            cell.selectionStyle = .none
            
            guard let branch = selectedBranch else { return cell }
            
            cell.branchLabel.text = branch.name
            cell.onButtonClick = { cell in
                
                self.searchStyle = .none
                
                tableView.reloadData()
                
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
            
            cell.searchImageView.backgroundColor = UIColor.clear
            cell.searchImageView.image = nil
            cell.searchImageView.layer.borderWidth = 0
            
            if let shop = datasource[indexPath.row - 1] as? Store {
                
                cell.titleLabel.text = shop.title
                cell.subtitleLabel.text = shop.subtitle
                
                cell.searchImageView.backgroundColor = AppColor.yellow
                cell.searchImageView.contentMode = .scaleAspectFit
                cell.searchImageView.layer.borderColor = UIColor.black.cgColor
                cell.searchImageView.layer.borderWidth = 1
                cell.searchImageView.layer.cornerRadius = 7
                
                if let image = ShopIconDrawer.annotationImage(from: shop.branch) {
                    
                    if let img = UIImage.imageResize(imageObj: image, size: CGSize(width: cell.searchImageView.bounds.width / 2, height: cell.searchImageView.bounds.height / 2), scaleFactor: 0.75) {
                        
                        cell.searchImageView.image = img
                        
                    }
                    
                }
                
            } else if let parkingLot = datasource[indexPath.row - 1] as? ParkingLot {
                
                cell.titleLabel.text = parkingLot.title
                cell.subtitleLabel.text = parkingLot.subtitle
                
                cell.searchImageView.image = #imageLiteral(resourceName: "parkingLot")
                
            } else if let camera = datasource[indexPath.row - 1] as? Camera {
                
                cell.titleLabel.text = camera.title
                cell.subtitleLabel.text = camera.localizedCategory
                
                cell.searchImageView.image = #imageLiteral(resourceName: "camera")
                
            } else if let bikeCharger = datasource[indexPath.row - 1] as? BikeChargingStation {
                
                cell.titleLabel.text = bikeCharger.title
                cell.subtitleLabel.text = bikeCharger.localizedCategory
                
                cell.searchImageView.image = #imageLiteral(resourceName: "ebike")
                
            } else if let petrolStation = datasource[indexPath.row - 1] as? PetrolStation {
                
                cell.titleLabel.text = petrolStation.title
                cell.subtitleLabel.text = petrolStation.localizedCategory
                
                cell.searchImageView.image = #imageLiteral(resourceName: "petrol")
                
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if searchStyle == .none && indexPath.row == 0 {
            
            return (2 * cellHeight) + 40
            
        } else if searchStyle == .branchSearch && indexPath.row == 0 {
            
            return 50
            
        } else {
            
            return 81
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        
        cell.backgroundColor = highlightedColor
        
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let _ = datasource[indexPath.row - 1] as? Shop {
            
            cell.searchImageView.backgroundColor = AppColor.yellow
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell else { return }
        
        cell.backgroundColor = normalColor
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.text != "" {
            
            Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
            
        }
        
        if indexPath.row != 0 {
            
            if let mapController = drawer.primaryContentViewController as? MapViewController {
                
                let location = self.datasource[indexPath.row - 1]
                
                guard let annotation = location as? MKAnnotation else { return }
                
                AnalyticsManager.shared.logSelectedItemContent(location)
                
                mapController.map.selectAnnotation(annotation, animated: true)
                mapController.map.camera.altitude = 1000
                
            }
            
        }
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
        
    }
    
}

extension ContentViewController: ShopDatasource, ParkingLotDatasource, CameraDatasource, PetrolDatasource {
    
    func didReceiveShops(_ shops: [Store]) {
        
        self.locations.append(contentsOf: shops as [Location])
        
        self.branches = shops.map { Branch(name: $0.branch, color: "") }.uniqueElements.sorted(by: { $0.name < $1.name })
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveParkingLots(_ parkingLots: [ParkingLot]) {
        
        self.locations.append(contentsOf: parkingLots as [Location])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveCameras(_ cameras: [Camera]) {
        
        self.locations.append(contentsOf: cameras as [Location])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStation]) {
        
        self.locations.append(contentsOf: petrolStations as [PetrolStation])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }

        
    }
    
}
