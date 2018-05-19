//
//  ContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Pulley
import Crashlytics
import MapKit

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let branchCell = "branchCell"
    static let filterCell = "filterCell"
    
}

// textSearch
// branchSearch
// none

class ContentViewController: UIViewController {

    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSectionHeightConstraint: NSLayoutConstraint!
    
    var locations: [Location] = []
    
    var filteredLocations: [Location] = []
    var branches: [Branch] = []
    
    var selectedBranch: Branch? = nil
    
    public var searchStyle: SearchStyle = SearchStyle.none
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gripperView.layer.cornerRadius = 2.5
        
        API.shared.delegate = self
        
        self.populateData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.topItem?.title = "Karte"
        
    }
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            
            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
            
        }
    }
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    fileprivate let cellWidth: CGFloat = 100
    fileprivate let cellHeight: CGFloat = 80
    
    fileprivate func resetNavBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.alpha = 1
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
    
}

extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchStyle == SearchStyle.textSearch {
            
            return datasource.count
            
        } else {
            
            return datasource.count + 1
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchStyle == .none && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.branchCell, for: indexPath) as! BranchTableViewCell
            
            cell.selectionStyle = .none
            
            return cell
            
        } else if searchStyle == .branchSearch && indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filterCell, for: indexPath) as! FilterTableViewCell
            
            cell.selectionStyle = .none
            
            guard let branch = selectedBranch else { fatalError("Error while selecting branch!") }
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.text != "" {
            
            Answers.logSearch(withQuery: searchBar.text, customAttributes: nil)
            
        }
        
        if indexPath.row != 0 {
            
            resetNavBar()
            
            if let drawer = self.parent as? PulleyViewController {
                let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
                drawer.setDrawerPosition(position: .collapsed, animated: true)
                
                drawerDetail.selectedLocation = datasource[indexPath.row - 1]
                
                if let mapController = drawer.primaryContentViewController as? MapViewController {
                    
                    let coordinate = self.datasource[indexPath.row - 1].location.coordinate
                    
                    let annotation = self.datasource[indexPath.row - 1] as! MKAnnotation
                    
                    mapController.map.selectAnnotation(annotation, animated: true)
                    mapController.map.setCenter(coordinate, animated: true)
                    mapController.map.camera.altitude = 0.5
                    
                }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let _ = datasource[indexPath.row - 1] as? Shop {
            
            cell.searchImageView.backgroundColor = AppColor.yellow
            
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? BranchTableViewCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        
    }
    
}

extension ContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return branches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "branchCell", for: indexPath) as! BranchCollectionViewCell
        
        cell.titleLabel.text = branches[indexPath.row].name
        
        cell.layout()
        
        cell.buttonView.backgroundColor = AppColor.yellow
        
        cell.imageView.image = nil
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let branchCell = cell as? BranchCollectionViewCell else { return }
        
        branchCell.buttonView.layer.cornerRadius = 52 / 2
        branchCell.buttonView.backgroundColor = AppColor.yellow
        branchCell.buttonView.layer.borderColor = UIColor.black.cgColor
        branchCell.buttonView.layer.borderWidth = 1
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return sectionInsets

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let width = collectionView.frame.width - (itemsPerRow * cellWidth)
        
        return width / (itemsPerRow - 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let drawerVC = self.parent as? PulleyViewController {
            drawerVC.setDrawerPosition(position: .open, animated: true)
        }
        
        selectedBranch = branches[indexPath.row]
        
        if let branch = selectedBranch {
            
            Answers.logCustomEvent(withName: "Branch", customAttributes: ["name": branch.name])
            
        }
        
        searchStyle = .branchSearch
        
        filteredLocations = locations.filter { (location) -> Bool in
            
            guard let shop = location as? Shop else { return false }
            
            if shop.branch == branches[indexPath.row].name {
                return true
            } else {
                return false
            }
            
        }
        
        tableView.reloadData()
        
    }
    
}

extension ContentViewController: UISearchBarDelegate {
    
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
    
}

extension ContentViewController: APIDelegate {
    
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

extension ContentViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        drawerBottomSafeArea = bottomSafeArea
        
        if drawer.drawerPosition == .collapsed {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        } else {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        tableView.isScrollEnabled = drawer.drawerPosition == .open
        
        if drawer.drawerPosition != .open {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat, bottomSafeArea: CGFloat) {
        
        
        
    }
    
}
