//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

internal enum PackageStrings {
    
    internal static let close = String(localized: "Close", bundle: .module)
    
    internal enum States {
        internal static let open = String(localized: "Open", bundle: .module)
        internal static let closed = String(localized: "Closed", bundle: .module)
        internal static let unknown = String(localized: "Unknown", bundle: .module)
    }
    
    internal enum ParkingAreaList {
        internal static let title = String(localized: "Parking spaces", bundle: .module)
        internal static let titleNearYou = String(localized: "Free parking spaces near you", bundle: .module)
        internal static let filter = String(localized: "Filter", bundle: .module)
        internal static let filterDescription = String(localized: "Filter parking spaces", bundle: .module)
        internal static let filterAll = String(localized: "All", bundle: .module)
        internal static let filterOnlyOpen = String(localized: "Only open", bundle: .module)
        internal static let disclaimer = String(localized: "All data without liability. The current parking situation may differ from the data shown.", bundle: .module)
        internal static let dataSource = String(localized: "Data source: Parking management system of the city of Moers", bundle: .module)
    }
    
    internal enum Dashboard {
        internal static let title = String(localized: "Free parking spaces", bundle: .module)
        internal static func outOfDateWarning(date: String) -> String {
            return String(localized: "The data is no longer up to date. (\(date))", bundle: .module)
        }
    }
    
    internal enum ParkingAreaDetail {
        
        internal static func free(number: Int) -> String {
            return String(localized: " / \(number) free", bundle: .module)
        }
        
    }
    
    internal enum ParkingAreaDetailScreen {
        internal static let currentAvailability = String(localized: "Current occupancy", bundle: .module)
        internal static let free = String(localized: " free", bundle: .module)
        internal static let pricesTitle = String(localized: "Pricing", bundle: .module)
        internal static let noPrices = String(localized: "No pricing information", bundle: .module)
    }
    
    internal enum ParkingTimerActivePartial {
        internal static let yourCar = String(localized: "Your car", bundle: .module)
        internal static let backToCar = String(localized: "Return to your car", bundle: .module)
        internal static let cancel = String(localized: "Cancel", bundle: .module)
    }
    
    internal enum ParkingTimerConfigurationPartial {
        internal static let sectionOverview = String(localized: "Overview", bundle: .module)
        internal static let sectionOptions = String(localized: "Settings", bundle: .module)
        internal static let enableNotifications = String(localized: "Enable notifications", bundle: .module)
        internal static let saveCarPosition = String(localized: "Save parking location", bundle: .module)
        internal static let startTimer = String(localized: "Start timer", bundle: .module)
        internal static let addFiveMinutes = String(localized: "Add five minutes", bundle: .module)
        internal static let subtractFiveMinutes = String(localized: "Remove five minutes", bundle: .module)
    }
    
    internal enum ParkingTimerScreen {
        internal static let title = String(localized: "Parking meter", bundle: .module)
    }
    
}
