//
//  DrawerViewController+TableView.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import MapKit
import MMEvents

extension DrawerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if trackers.isEmpty || !ConfigManager.shared.showTracker {
                return 1
            } else {
                return trackers.count
            }
        } else {
            return entries.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: DrawerItemTableViewCell.identifier, for: indexPath) as! DrawerItemTableViewCell
        
        if indexPath.section == 0 {
            
            if trackers.count > indexPath.row && ConfigManager.shared.showTracker {
                
                let tracker = trackers[indexPath.row]
                
                cell.titleLabel.text = tracker.name
                cell.subtitleLabel.text = tracker.description ?? String.localized("NoDescription")
                
            } else {
                
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as HintTableViewCell
                
                cell.hint = String.localized("NoMovingActs")
                cell.selectionStyle = .none
                
                return cell
                
            }
            
        } else {
            
            let entry = entries[indexPath.row]
            
            cell.titleLabel.text = entry.name
            cell.subtitleLabel.text = entry.subtitle
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && !trackers.isEmpty && ConfigManager.shared.showTracker {
            
            let tracker = trackers[indexPath.row]
            
            let regionDistance: CLLocationDistance = 500
            let coordinates = CLLocationCoordinate2D(latitude: tracker.coordinate.latitude, longitude: tracker.coordinate.longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(tracker.name)"
            mapItem.openInMaps(launchOptions: options)
            
        } else if indexPath.section == 1 {
            
            let entry = entries[indexPath.row]
            coordinator?.showPlaceDetail(placeID: entry.id)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return String.localized("MovingActs")
        } else {
            return String.localized("Stages")
        }
    }
    
}
