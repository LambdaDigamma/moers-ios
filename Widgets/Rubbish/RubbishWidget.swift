//
//  RubbishWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit

struct RubbishWidget: Widget {
    
    let kind: String = "RubbishWidget"
    
    var body: some WidgetConfiguration {
        
        StaticConfiguration(
            kind: kind,
            provider: RubbishCollectionProvider()
        ) { (entry: TimelineEntry) in
            
            RubbishCollectionWrapperView()
            
        }
        .configurationDisplayName(WidgetStrings.RubbishCollection.widgetTitle)
        .description(WidgetStrings.RubbishCollection.widgetDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
        
    }
    
}
