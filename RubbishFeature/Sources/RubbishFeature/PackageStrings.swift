//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation

internal enum PackageStrings {
    
    internal enum Waste {
        internal static let dashboardTitle = String.localized("Waste.dashboardTitle")
        internal static let errorMessage = String.localized("Waste.loadingFailed")
        internal static let loadingFailed = String.localized("Waste.loadingFailed")
        internal static let scheduleDeactivated = String.localized("Waste.scheduleDeactivated")
        internal static let noUpcomingRubbishItems = String.localized("Waste.noUpcomingRubbishItems")
        internal static let loadingDashboard = String.localized("Waste.loadingDashboard")
    }
    
    internal enum WasteShort {
        internal static let residual = String.localized("WasteTypeShort.residual")
        internal static let organic = String.localized("WasteTypeShort.organic")
        internal static let paper = String.localized("WasteTypeShort.paper")
        internal static let yellow = String.localized("WasteTypeShort.yellow")
        internal static let green = String.localized("WasteTypeShort.green")
    }
    
}
