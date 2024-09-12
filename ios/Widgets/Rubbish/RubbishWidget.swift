//
//  RubbishWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import Core


struct RubbishWidget: Widget {
    
    let kind: String = WidgetKinds.rubbish.rawValue
    
    private let supportedFamilies:[WidgetFamily] = {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
//                .accessoryRectangular,
//                .accessoryInline
            ]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }()
    
//    @available(iOSApplicationExtension 16.0, *)
    var body: some WidgetConfiguration {
        
        StaticConfiguration(
            kind: kind,
            provider: RubbishCollectionProvider()
        ) { (entry: RubbishCollectionEntry) in
            
            RubbishCollectionWrapperView(items: entry.rubbishPickupItems)
            
        }
        .configurationDisplayName(WidgetStrings.RubbishCollection.widgetTitle)
        .description(WidgetStrings.RubbishCollection.widgetDescription)
        .supportedFamilies(supportedFamilies)
        
//        if #available(iOSApplicationExtension 16.0, *) {
//
//            StaticConfiguration(
//                kind: kind,
//                provider: RubbishCollectionProvider()
//            ) { (entry: RubbishCollectionEntry) in
//
//
//                if family == .accessoryRectangular {
//
//                    Text("Hallo")
//
//                } else {
//                    RubbishCollectionWrapperView(items: entry.rubbishPickupItems)
//                }
//
//            }
//            .configurationDisplayName(WidgetStrings.RubbishCollection.widgetTitle)
//            .description(WidgetStrings.RubbishCollection.widgetDescription)
//            .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
//
//        } else {
//
//            StaticConfiguration(
//                kind: kind,
//                provider: RubbishCollectionProvider()
//            ) { (entry: RubbishCollectionEntry) in
//
//                RubbishCollectionWrapperView(items: entry.rubbishPickupItems)
//
//            }
//            .configurationDisplayName(WidgetStrings.RubbishCollection.widgetTitle)
//            .description(WidgetStrings.RubbishCollection.widgetDescription)
//            .supportedFamilies([.systemSmall, .systemMedium])
//
//        }
        
    }
    
}
