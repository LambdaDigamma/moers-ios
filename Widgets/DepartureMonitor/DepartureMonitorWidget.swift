//
//  DepartureMonitorWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
//import NewsWidgets

struct DepartureMonitorWidget: Widget {
    
    let kind: String = "DepartureMonitorWidget"
    
    var body: some WidgetConfiguration {
        
        IntentConfiguration(
            kind: kind,
            intent: SelectDepartureMonitorStopIntent.self,
            provider: DepartureMonitorProvider()
        ) { entry in
            DepartureMonitorWrapperView(entry: entry)
        }
            .configurationDisplayName(WidgetStrings.DepartureMonitor.widgetTitle)
            .description(WidgetStrings.DepartureMonitor.widgetDescription)
            .supportedFamilies([.systemMedium])
        
    }
    
}
