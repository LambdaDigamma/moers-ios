//
//  ContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Pulley

public struct CellIdentifier {
    
    static let searchResultCell = "searchResult"
    static let branchCell = "branchCell"
    static let filterCell = "filterCell"
    
}

class ContentViewController: UIViewController {

    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerSectionHeightConstraint: NSLayoutConstraint!
    
    var locations: [Location] = []
    
    var filteredLocations: [Location] = []
    var branches: [Branch] = []
    
    var datasource: [Location] {
        
        if searchBar.text == "" {
            
            return locations
            
        } else {
            
            return filteredLocations
            
        }
        
    }
    
    var api = API()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gripperView.layer.cornerRadius = 2.5
        
        api.delegate = self
        api.loadShop()
        api.loadParkingLots()
        api.loadCameras()
        
        branches = api.loadBranches()
        
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
    
    fileprivate let itemsPerRow: CGFloat = 4
    fileprivate let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    fileprivate let cellWidth: CGFloat = 60
    fileprivate var isBranchSelectionShown = true
    
}

extension ContentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            if isBranchSelectionShown == true {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.branchCell, for: indexPath) as! BranchTableViewCell
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.filterCell, for: indexPath) as! FilterTableViewCell
                
                cell.branchLabel.text = "Bäckerei"
                cell.onButtonClick = { cell in
                    
                    self.isBranchSelectionShown = true
                    
                    tableView.reloadData()
                    
                }
                
                return cell
                
            }
            
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
                        
                        cell.searchImageView.backgroundColor = UIColor(red: 0xFF, green: 0xF5, blue: 0x00, alpha: 1)
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
                
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let drawer = self.parent as? PulleyViewController {
            let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
            drawer.setDrawerPosition(position: .collapsed, animated: true)
            
            drawerDetail.selectedLocation = datasource[indexPath.row - 1]
            
            if let mapController = drawer.primaryContentViewController as? MapViewController {
                
                let coordinate = self.datasource[indexPath.row - 1].location.coordinate
                
                mapController.map.setCenter(coordinate, animated: true)
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            if isBranchSelectionShown == true {
                
                return 190
                
            } else {
                
                return 50
                
            }
            
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: 80)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return sectionInsets

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let width = collectionView.frame.width - (itemsPerRow * cellWidth)
        
        return width / (itemsPerRow - 1)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? BranchCollectionViewCell else { return }
        
        cell.buttonView.layer.borderWidth = 3.5
        cell.buttonView.layer.borderColor = UIColor.white.cgColor
        
        isBranchSelectionShown = false
        
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
            
            isBranchSelectionShown = false
            
        }
        
        filteredLocations = locs
        
        tableView.reloadData()
        
    }
    
}

extension ContentViewController: APIDelegate {
    
    func didReceiveShops(shops: [Shop]) {
        
        self.locations.append(contentsOf: shops as [Location])
        
        DispatchQueue.main.async {
            
            self.branches = self.api.loadBranches()
            
            print(self.branches)
            
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
        
        if progress != 0 {
            
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0).darker(amount: progress / 3)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white.darker(amount: progress / 3)]
            
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.alpha = 1 - (progress / 3)
            }
            
        } else {
            
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
            
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.alpha = 1
            }
            
        }
        
    }
    
}
