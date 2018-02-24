//
//  SelectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 22.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Pulley

class SelectionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var clusteredLocations: [Location] = [] {
        
        didSet {
            
            titleLabel.text = "\(clusteredLocations.count) Einträge"
            
            tableView.reloadData()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}

extension SelectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return clusteredLocations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.searchResultCell, for: indexPath) as! SearchResultTableViewCell
        
        cell.searchImageView.backgroundColor = UIColor.clear
        cell.searchImageView.image = nil
        cell.searchImageView.layer.borderWidth = 0
        
        if let shop = clusteredLocations[indexPath.row] as? Shop {
            
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
            
        } else if let parkingLot = clusteredLocations[indexPath.row] as? ParkingLot {
            
            cell.titleLabel.text = parkingLot.title
            cell.subtitleLabel.text = parkingLot.subtitle
            
            cell.searchImageView.image = #imageLiteral(resourceName: "parkingLot")
            
        } else if let camera = clusteredLocations[indexPath.row] as? Camera {
            
            cell.titleLabel.text = camera.title
            cell.subtitleLabel.text = "360° Kamera"
            
            cell.searchImageView.image = #imageLiteral(resourceName: "camera")
            
        } else if let ebike = clusteredLocations[indexPath.row] as? BikeChargingStation {
            
            cell.titleLabel.text = ebike.title
            cell.subtitleLabel.text = "EBike Ladestation"
            
            cell.searchImageView.image = #imageLiteral(resourceName: "ebike")
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let drawer = self.parent as? PulleyViewController {
            let drawerDetail = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            drawer.setDrawerContentViewController(controller: drawerDetail, animated: false)
            drawer.setDrawerPosition(position: .partiallyRevealed, animated: true)
            
            drawerDetail.selectedLocation = clusteredLocations[indexPath.row]
            
            if let mapController = drawer.primaryContentViewController as? MapViewController {
                
                let coordinate = self.clusteredLocations[indexPath.row].location.coordinate
                
                mapController.map.setCenter(coordinate, animated: true)
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let _ = clusteredLocations[indexPath.row - 1] as? Shop {
            
            cell.searchImageView.backgroundColor = AppColor.yellow
            
        }
        
    }
    
}

extension SelectionViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        tableView.isScrollEnabled = drawer.drawerPosition == .open
    }
    
    func makeUIAdjustmentsForFullscreen(progress: CGFloat) {
        
        if progress != 0 {
            
            navigationController?.navigationBar.alpha = (progress * -1) + 1 - 0.2
            
        } else {
            
            navigationController?.navigationBar.alpha = 1
            
        }
        
    }
    
}
