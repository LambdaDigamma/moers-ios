//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

internal enum PackageStrings {
    
    internal static let close = String.localized("Close")
    
    internal enum States {
        internal static let open = String.localized("States.open")
        internal static let closed = String.localized("States.closed")
        internal static let unknown = String.localized("States.unkown")
    }
    
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
    
    internal enum ParkingTimerActivePartial {
        internal static let yourCar = String.localized("ParkingTimerActivePartial.yourCar")
        internal static let backToCar = String.localized("ParkingTimerActivePartial.backToCar")
        internal static let cancel = String.localized("ParkingTimerActivePartial.cancel")
    }
    
    internal enum ParkingTimerConfigurationPartial {
        internal static let sectionOverview = String.localized("ParkingTimerConfigurationPartial.sectionOverview")
        internal static let sectionOptions = String.localized("ParkingTimerConfigurationPartial.sectionOptions")
        internal static let enableNotifications = String.localized("ParkingTimerConfigurationPartial.enableNotifications")
        internal static let saveCarPosition = String.localized("ParkingTimerConfigurationPartial.saveCarPosition")
        internal static let startTimer = String.localized("ParkingTimerConfigurationPartial.startTimer")
        internal static let addFiveMinutes = String.localized("ParkingTimerConfigurationPartial.addFiveMinutes")
        internal static let subtractFiveMinutes = String.localized("ParkingTimerConfigurationPartial.subtractFiveMinutes")
    }
    
    internal enum ParkingTimerScreen {
        internal static let title = String.localized("ParkingTimerScreen.title")
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
