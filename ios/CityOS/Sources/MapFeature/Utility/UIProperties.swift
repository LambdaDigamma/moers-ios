//
//  UIProperties.swift
//  Moers
//
//  Created by Lennart Fischer on 06.04.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Core
import UIKit

public struct UIProperties {
    
    public static func detailHeight(for location: Location) -> CGFloat {
    
        if location is Camera {
            return 80.0
        } /*else if location is ParkingLot {
            return 220.0
        } */
        /*else if location is BikeChargingStation {
            return 520.0
        } */else if location is Entry {
            return 720.0
        } else if location is PetrolStationViewModel {
            return 250.0
        } else {
            return 100.0
        }
        
    }
    
    public static func detailImage(for location: Location) -> UIImage {
        
        if location is Camera {
            return #imageLiteral(resourceName: "camera")
        }/* else if location is BikeChargingStation {
            return #imageLiteral(resourceName: "ebike")
        }*/ else if location is Entry {
            return #imageLiteral(resourceName: "entry")
        } else if location is PetrolStationViewModel {
            return #imageLiteral(resourceName: "petrol")
        } else {
            return UIImage()
        }
        
    }
    
    public static func detailViewController(for location: Location) -> UIViewController {
        
        if location is Camera {
            return DetailCameraViewController()
        }/* else if location is BikeChargingStation {
            return UIViewController()
        }*/ else if location is Entry {
            return DetailEntryViewController.fromStoryboard()
        } else if location is PetrolStationViewModel {
            return UIViewController()
        } else {
            return UIViewController()
        }
        
    }
    
    public static func detailSubtitle(for location: Location) -> String {
        
        if let location = location as? Entry {

            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return "\(dist) · \(location.street) \(location.houseNumber ?? "")"
                
            } else {
                return location.street + " " + (location.houseNumber ?? "")
            }
            
        } else if let location = location as? PetrolStationViewModel {
            
            let open = location.isOpen ? String.localized("LocalityOpen") : String.localized("LocalityClosed")
            
            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return dist + " · " + location.localizedCategory
                
            } else {
                return open + " · " + location.localizedCategory
            }
            
        } else {
            
            if location.distance.value != 0 {
                
                let dist = prettifyDistance(distance: location.distance.converted(to: .meters).value)
                
                return "\(dist) · \(location.localizedCategory)"
                
            } else {
                return location.localizedCategory
            }
            
        }
        
    }
    
}
