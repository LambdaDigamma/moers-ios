//
//  RebuildContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Pulley
import Crashlytics

public enum SearchStyle {
    
    case none
    case branchSearch
    case textSearch
    
}

class RebuildContentViewController: UIViewController, PulleyDrawerViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    // MARK: - UI
    
    lazy var headerView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        return view
        
    }()
    
    lazy var gripperView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.lightGray
        
        return view
        
    }()
    
    lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.backgroundColor = UIColor.clear
        searchBar.placeholder = String.localized("SearchBarPrompt")
        searchBar.delegate = self
        
        return searchBar
        
    }()
    
    lazy var separatorView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.alpha = 0.75
        
        return view
        
    }()
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(RebuildSearchResultTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchResultCell)
        
        return tableView
        
    }()
    
    private var headerHeightConstraint: NSLayoutConstraint?
    
    private var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let cellWidth: CGFloat = 100
    private let cellHeight: CGFloat = 80
    
    // MARK: - Data
    
    private var locations: [Location] = []
    private var filteredLocations: [Location] = []
    private var branches: [Branch] = []
    private var selectedBranch: Branch?
    public var searchStyle = SearchStyle.none
    
    var datasource: [Location] {
        
        if searchBar.text == "" && searchStyle == .none {
            return locations.sorted { t1, t2 in
                if t1 is Shop && t2 is Shop {
                    return t1.name < t2.name
                } else if t1 is ParkingLot && t2 is ParkingLot {
                    return t1.name < t2.name
                } else if t1 is Camera && t2 is Camera {
                    return t1.name < t2.name
                } else if t1 is Shop && !(t2 is Shop) {
                    return true
                } else if t1 is ParkingLot && t2 is Shop {
                    return false
                } else if t1 is ParkingLot && t2 is Camera {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return filteredLocations
        }
        
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        self.view.addSubview(headerView)
        self.headerView.addSubview(searchBar)
        self.headerView.addSubview(gripperView)
        self.headerView.addSubview(separatorView)
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
        API.shared.delegate = self
        
        self.populateData()

    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let seperatorHeightConstraint = gripperView.heightAnchor.constraint(equalToConstant: 5)
        let searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 65)
        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 68)
        
        seperatorHeightConstraint.isActive = true
        searchBarHeightConstraint.isActive = true
        headerHeightConstraint?.isActive = true
        
        let constraints = [headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           gripperView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
                           gripperView.widthAnchor.constraint(equalToConstant: 36),
                           gripperView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                           searchBar.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
                           searchBar.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                           searchBar.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                           separatorView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
                           separatorView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
                           separatorView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
                           separatorView.heightAnchor.constraint(equalToConstant: 1),
                           tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.navigationColor
            themeable.searchBar.barTintColor = theme.accentColor
            themeable.searchBar.backgroundColor = theme.navigationColor
            themeable.searchBar.tintColor = theme.accentColor
            themeable.searchBar.textField?.textColor = theme.color
            themeable.separatorView.backgroundColor = theme.separatorColor
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            
        }
        
    }
    
    private func populateData() {
        
        self.locations = []
        
        self.locations.append(contentsOf: API.shared.cachedShops as [Location])
        self.locations.append(contentsOf: API.shared.cachedParkingLots as [Location])
        self.locations.append(contentsOf: API.shared.cachedCameras as [Location])
        self.locations.append(contentsOf: API.shared.cachedBikeCharger as [Location])
        
        DispatchQueue.main.async {
            
            self.branches = API.shared.loadBranches()
            
            self.branches.sort(by: { $0.name < $1.name })
            
            self.tableView.reloadData()
            
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchStyle == SearchStyle.textSearch {
            return datasource.count
        } else {
            return datasource.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchStyle == .none && indexPath.row == 0 {
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.branchCell, for: indexPath) as! BranchTableViewCell
//
//            cell.selectionStyle = .none
            
            let cell = UITableViewCell()
            
            return cell
            
        } else if searchStyle == .branchSearch && indexPath.row == 0 {
            
            let cell = UITableViewCell()
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filterCell, for: indexPath) as! FilterTableViewCell
            
//            cell.selectionStyle = .none
//
//            guard let branch = selectedBranch else { fatalError("Error while selecting branch!") }
//
//            cell.branchLabel.text = branch.name
//            cell.onButtonClick = { cell in
//
//                self.searchStyle = .none
//
//                tableView.reloadData()
//
//            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! RebuildSearchResultTableViewCell
            
            cell.searchImageView.backgroundColor = UIColor.clear
            cell.searchImageView.image = nil
            cell.searchImageView.layer.borderWidth = 0
            
            if let shop = datasource[indexPath.row - 1] as? Shop {
                
                cell.titleLabel.text = shop.title
                cell.subtitleLabel.text = shop.subtitle
                
                if let image = ShopIconDrawer.annotationImage(from: shop.branch) {
                    
                    if let img = UIImage.imageResize(imageObj: image, size: CGSize(width: cell.searchImageView.bounds.width / 2, height: cell.searchImageView.bounds.height / 2), scaleFactor: 0.75) {
                        
                        cell.searchImageView.backgroundColor = AppColor.yellow //UIColor(red: 0xFF, green: 0xF5, blue: 0x00, alpha: 1)i
                        cell.searchImageView.image = img
                        cell.searchImageView.contentMode = .scaleAspectFit
                        cell.searchImageView.layer.borderColor = UIColor.black.cgColor
                        cell.searchImageView.layer.borderWidth = 1
                        cell.searchImageView.layer.cornerRadius = 7
                        
                    }
                    
                }
                
            } else if let parkingLot = datasource[indexPath.row - 1] as? ParkingLot {
                
                cell.titleLabel.text = parkingLot.title
                cell.subtitleLabel.text = parkingLot.subtitle
                
                cell.searchImageView.image = #imageLiteral(resourceName: "parkingLot")
                
            } else if let camera = datasource[indexPath.row - 1] as? Camera {
                
                cell.titleLabel.text = camera.title
                cell.subtitleLabel.text = "360° Kamera"
                
                cell.searchImageView.image = #imageLiteral(resourceName: "camera")
                
            } else if let bikeCharger = datasource[indexPath.row - 1] as? BikeChargingStation {
                
                cell.titleLabel.text = bikeCharger.title
                cell.subtitleLabel.text = "E-Bike Ladestation"
                
                cell.searchImageView.image = #imageLiteral(resourceName: "ebike")
                
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
        
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        if let drawerVC = self.parent as? PulleyViewController {
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
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        if drawer.drawerPosition == .collapsed {
            headerHeightConstraint?.constant = 68.0 + drawerBottomSafeArea
        } else {
            headerHeightConstraint?.constant = 68.0
        }
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
    }
    
}

extension RebuildContentViewController: APIDelegate {
    
    func didReceiveShops(shops: [Shop]) {
        
        self.locations.append(contentsOf: shops as [Location])
        
        DispatchQueue.main.async {
            
            self.branches = API.shared.loadBranches()
            
            self.branches.sort(by: { $0.name < $1.name })
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveParkingLots(parkingLots: [ParkingLot]) {
        
        self.locations.append(contentsOf: parkingLots as [Location])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveCameras(cameras: [Camera]) {
        
        self.locations.append(contentsOf: cameras as [Location])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    func didReceiveBikeChargers(chargers: [BikeChargingStation]) {
        
        self.locations.append(contentsOf: chargers as [Location])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
}
