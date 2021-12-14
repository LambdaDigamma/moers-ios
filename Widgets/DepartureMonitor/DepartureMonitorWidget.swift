//
//  DepartureMonitorWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import NewsWidgets

struct DepartureMonitorWidget: Widget {
    
    let kind: String = "DepartureMonitorWidget"
    
    var body: some WidgetConfiguration {
        
        IntentConfiguration(
            kind: kind,
            intent: SelectDepartureMonitorStopIntent.self,
            provider: DepartureMonitorProvider()
        ) { entry in
            DepartureMonitorView(entry: entry)
        }
            .configurationDisplayName("Abfahrtsmonitor")
            .description("Sehe Dir die nächsten Abfahrten von der ausgewählen Haltestelle an.")
            .supportedFamilies([.systemMedium])
        
    }
    
}
