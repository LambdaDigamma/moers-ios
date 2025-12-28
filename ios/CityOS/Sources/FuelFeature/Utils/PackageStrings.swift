//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 29.01.22.
//

import Foundation

internal enum PackageStrings {
    
    internal enum Error {
        static let onlyGermany = String(localized: "Only available in Germany", bundle: .module)
    }
    
    static let dataSource = String(localized: "Datasource: MTS-K via https://creativecommons.tankerkoenig.de - CC BY 4.0", bundle: .module)
    
    internal enum FuelStationList {
        static let title = String(localized: "Fuel stations", bundle: .module)
        static let contextNavigationAction = String(localized: "Get directions", bundle: .module)
    }
    
    internal enum Dashboard {
        static let currentLocation = String(localized: "Current location", bundle: .module)
        static func perL(_ type: PetrolType) -> String {
            return String(localized: "per L \(type.name)", bundle: .module)
        }
        static func stationsNearYou(_ count: Int) -> String {
            return String(localized: "\(count) fuel stations in your area are currently open.", bundle: .module)
        }
    }
    
}
