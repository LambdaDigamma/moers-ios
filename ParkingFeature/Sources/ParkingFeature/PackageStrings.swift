//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

internal enum PackageStrings {
    
    internal enum ParkingAreaList {
        internal static let title = String.localized("ParkingAreaList.title")
        internal static let titleNearYou = String.localized("ParkingAreaList.titleNearYou")
        internal static let filter = String.localized("ParkingAreaList.filter")
        internal static let filterDescription = String.localized("ParkingAreaList.filterDescription")
        internal static let filterAll = String.localized("ParkingAreaList.filterAll")
        internal static let filterOnlyOpen = String.localized("ParkingAreaList.filterOnlyOpen")
        internal static let disclaimer = String.localized("ParkingAreaList.disclaimer")
        internal static let dataSource = String.localized("ParkingAreaList.dataSource")
    }
    
    internal enum Dashboard {
        internal static let title = String.localized("Dashboard.title")
    }
    
    internal enum ParkingAreaDetail {
        
        internal static func free(number: Int) -> String {
            return String.localizedStringWithFormat(String.localized("ParkingAreaDetail.free"), "\(number)")
        }
        
    }
    
    internal enum ParkingAreaDetailScreen {
        internal static let currentAvailability = String.localized("ParkingAreaDetailScreen.currentAvailability")
        internal static let free = String.localized("ParkingAreaDetailScreen.free")
        internal static let pricesTitle = String.localized("ParkingAreaDetailScreen.pricesTitle")
        internal static let noPrices = String.localized("ParkingAreaDetailScreen.noPrices")
    }
    
}

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key,
                                 tableName: nil,
                                 bundle: .module,
                                 value: "",
                                 comment: "")
    }
    
}
