//
//  WidgetStrings.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 20.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation

internal enum WidgetStrings {
    
    internal enum News {
        internal static let widgetTitle = String(localized: "News from Moers")
        internal static let widgetDescription = String(localized: "Keep up to date with whats happening in and around Moers")
    }
    
    internal enum DepartureMonitor {
        internal static let widgetTitle = String(localized: "Departure Monitor")
        internal static let widgetDescription = String(localized: "View the next departures from the selected stop.")
    }
    
    internal enum RubbishCollection {
        internal static let widgetTitle = String(localized: "Pickup Schedule")
        internal static let widgetDescription = String(localized: "View the next pickup dates of your rubbish for your selected street.")
    }
    
}
