//
//  ScheduleWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

struct ScheduleWidget: Widget {
    
    let kind: String = WidgetKinds.schedule
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(
            kind: kind,
            provider: ScheduleTimelineProvider()
        ) { entry in
            WidgetScheduleView()
        }
        .configurationDisplayName("Your schedule")
        .description("Create your personal moers festival schedule in the app and display it here.")
        .supportedFamilies([.systemSmall, .systemMedium])
        
//        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
//            WidgetsEntryView(entry: entry)
//        }
//        .configurationDisplayName("Your schedule")
//        .description("Create your personal moers festival schedule in the app and display it here.")
    }
    
}
