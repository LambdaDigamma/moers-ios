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
        internal static let noUpcomingRubbishItems = String.localized("Waste.noUpcomingRubbishItems")
        internal static let loadingDashboard = String.localized("Waste.loadingDashboard")
    }
    
    internal enum WasteType {
        internal static let residual = String.localized("WasteType.residual")
        internal static let organic = String.localized("WasteType.organic")
        internal static let paper = String.localized("WasteType.paper")
        internal static let yellow = String.localized("WasteType.yellow")
        internal static let green = String.localized("WasteType.green")
    }
    
    internal enum WasteShort {
        internal static let residual = String.localized("WasteTypeShort.residual")
        internal static let organic = String.localized("WasteTypeShort.organic")
        internal static let paper = String.localized("WasteTypeShort.paper")
        internal static let yellow = String.localized("WasteTypeShort.yellow")
        internal static let green = String.localized("WasteTypeShort.green")
    }
    
    internal enum WasteSchedule {
        internal static let title = String.localized("WasteSchedule.title")
        internal enum Info {
            internal static let close = String.localized("WasteSchedule.Info.close")
            internal static let selectedStreet = String.localized("WasteSchedule.Info.selectedStreet")
            internal static let disclaimer = String.localized("WasteSchedule.Info.disclaimer")
        }
    }
    
    internal enum RubbishDashboardError {
        
        internal enum Deactivated {
            internal static let title = String.localized("RubbishDashboardError.Deactivated.title")
            internal static let text = String.localized("RubbishDashboardError.Deactivated.text")
        }
        
        internal enum NotConfigured {
            internal static let title = String.localized("RubbishDashboardError.NotConfigured.title")
            internal static let text = String.localized("RubbishDashboardError.NotConfigured.text")
        }
        
        internal enum NoYearData {
            internal static let title = String.localized("RubbishDashboardError.NoYearData.title")
            internal static let text = String.localized("RubbishDashboardError.NoYearData.text")
        }
        
        internal enum InternalError {
            internal static let title = String.localized("RubbishDashboardError.InternalError.title")
        }
        
    }
    
    internal enum Notification {
        
        internal static let title = String.localized("RubbishCollectionNotification.title")
        internal static let body = String.localized("RubbishCollectionNotification.body")
        
    }
    
}
