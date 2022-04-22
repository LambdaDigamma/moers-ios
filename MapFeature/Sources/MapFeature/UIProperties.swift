//
//  UIProperties.swift
//  Moers
//
//  Created by Lennart Fischer on 06.04.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI

struct UIProperties {
    
    static func detailHeight(for location: Location) -> CGFloat {
    
        if location is Camera {
            return 80.0
        } else if location is ParkingLot {
            return 220.0
        } else if location is BikeChargingStation {
            return 520.0
        } else if location is Entry {
            return 720.0
        } else if location is PetrolStation {
            return 250.0
        } else {
            return 100.0
        }
        
    }
    
    static func detailImage(for location: Location) -> UIImage {
        
        if location is Camera {
            return #imageLiteral(resourceName: "camera")
        } else if location is ParkingLot {
            return #imageLiteral(resourceName: "parkingLot")
        } else if location is BikeChargingStation {
            return #imageLiteral(resourceName: "ebike")
        } else if location is Entry {
            return #imageLiteral(resourceName: "entry")
        } else if location is PetrolStation {
            return #imageLiteral(resourceName: "petrol")
        } else {
            return UIImage()
        }
        
    }
    
    static func detailViewController(for location: Location) -> UIViewController {
        
        if location is Camera {
            return DetailCameraViewController()
        } else if location is ParkingLot {
            return DetailParkingViewController()
        } else if location is BikeChargingStation {
            return UIViewController()
        } else if location is Entry {
            return DetailEntryViewController.fromStoryboard()
        } else if location is PetrolStation {
            return UIViewController()
        } else {
            return UIViewController()
        }
        
    }
    
    static func detailSubtitle(for location: Location) -> String {
        
        if let location = location as? Entry {

            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return "\(dist) • \(location.street) \(location.houseNumber)"
                
            } else {
                return location.street + " " + location.houseNumber
            }
            
        } else if let location = location as? PetrolStation {
            
            let open = location.isOpen ? String.localized("LocalityOpen") : String.localized("LocalityClosed")
            
            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return dist + " • " + open + " • " + location.localizedCategory
                
            } else {
                return open + " • " + location.localizedCategory
            }
            
        } else {
            
            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return "\(dist) • \(location.localizedCategory)"
                
            } else {
                return location.localizedCategory
            }
            
        }
        
    }
    
}
