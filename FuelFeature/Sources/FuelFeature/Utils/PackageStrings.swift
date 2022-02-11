//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 29.01.22.
//

import Foundation

internal enum PackageStrings {
    
    internal enum FuelStationList {
        static let title = String.localized("FuelStationList.title")
        static let contextNavigationAction = String.localized("FuelStationList.contextNavigationAction")
    }
    
    internal enum Dashboard {
        static let currentLocation = String.localized("Dashboard.currentLocation")
        static func perL(_ type: PetrolType) -> String {
            return String.localized("Dashboard.perL") + type.name
        }
        static func stationsNearYou(_ count: Int) -> String {
            return String.localizedStringWithFormat(
                String.localized("Dashboard.stationsNearYou"),
                "\(count)"
            )
        }
    }
    
}
