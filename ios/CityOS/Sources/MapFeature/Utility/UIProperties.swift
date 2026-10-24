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
    
    public static func symbolName(for location: Location) -> String {
        if location is Camera { return "camera.fill" }
        if location is PetrolStationViewModel { return "fuelpump.fill" }
        return "mappin.circle.fill"
    }

    @MainActor
    static func listContent(for location: Location) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.subtitleCell()
        content.text = location.name
        content.secondaryText = detailSubtitle(for: location)
        content.textProperties.numberOfLines = 0
        content.secondaryTextProperties.numberOfLines = 0
        content.textProperties.color = .label
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: symbolName(for: location))
        content.imageProperties.tintColor = .tintColor
        content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title2)
        return content
    }

    public static func detailImage(for location: Location) -> UIImage {
        
        if location is Camera {
            return UIImage(named: "camera") ?? UIImage(systemName: "camera.fill") ?? UIImage()
        }/* else if location is BikeChargingStation {
            return #imageLiteral(resourceName: "ebike")
        }*/ else if location is Entry {
            return UIImage(named: "entry") ?? UIImage(systemName: "mappin.circle.fill") ?? UIImage()
        } else if location is PetrolStationViewModel {
            return UIImage(named: "petrol") ?? UIImage(systemName: "fuelpump.fill") ?? UIImage()
        } else {
            return UIImage()
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
            
            let open = location.isOpen ? String(localized: "open", bundle: .module) : String(localized: "closed", bundle: .module)
            
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
