//
//  PackageStrings.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation

internal enum PackageStrings {
    
    internal enum Waste {
        internal static let dashboardTitle = String(localized: "Next collection dates", bundle: .module)
        internal static let noUpcomingRubbishItems = String(localized: "No further dates could be found in the waste calendar.", bundle: .module)
        internal static let loadingDashboard = String(localized: "Loading waste schedule…", bundle: .module)
    }
    
    internal enum WasteType {
        internal static let residual = String(localized: "Residual Waste", bundle: .module)
        internal static let organic = String(localized: "Organic Waste", bundle: .module)
        internal static let paper = String(localized: "Paper Waste", bundle: .module)
        internal static let yellow = String(localized: "Yellow Bag", bundle: .module)
        internal static let green = String(localized: "Green Cuttings", bundle: .module)
    }
    
    internal enum WasteShort {
        internal static let residual = String(localized: "Residual", bundle: .module)
        internal static let organic = String(localized: "Organic", bundle: .module)
        internal static let paper = String(localized: "Paper", bundle: .module)
        internal static let yellow = String(localized: "Yellow", bundle: .module)
        internal static let green = String(localized: "Cuttings", bundle: .module)
    }
    
    internal enum WasteSchedule {
        internal static let title = String(localized: "Waste schedule", bundle: .module)
        internal enum Info {
            internal static let close = String(localized: "Close", bundle: .module)
            internal static let selectedStreet = String(localized: "Selected street", bundle: .module)
            internal static let disclaimer = String(localized: """
The waste calendar is provided by waste management company ENNI for the app.
There is no guarantee that the data listed here is correct.
If you have any problems, you should therefore rather contact ENNI itself.
""", bundle: .module)
        }
    }
    
    internal enum RubbishDashboardError {
        
        internal enum Deactivated {
            internal static let title = String(localized: "Waste schedule disabled", bundle: .module)
            internal static let text = String(localized: "You can enable the waste schedule in the settings.", bundle: .module)
        }
        
        internal enum NotConfigured {
            internal static let title = String(localized: "No street selected", bundle: .module)
            internal static let text = String(localized: "You have not selected a street for which you want to see the waste schedule. Select a street in the settings first.", bundle: .module)
        }
        
        internal enum NoYearData {
            internal static let title = String(localized: "Attention", bundle: .module)
            internal static let text = String(localized: "No other pickup dates could be found in the waste schedule.", bundle: .module)
        }
        
        internal enum InternalError {
            internal static let title = String(localized: "Internal error", bundle: .module)
        }
        
    }
    
    internal enum Notification {
        
        internal static let title = String(localized: "Pick-up Schedule", bundle: .module)
        internal static let body = String(localized: "Tomorrow will be collected: ", bundle: .module)
        
    }
    
}
