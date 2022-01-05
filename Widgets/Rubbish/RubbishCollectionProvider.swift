//
//  RubbishCollectionProvider.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import WidgetKit
import RubbishFeature

class RubbishCollectionProvider: TimelineProvider {
    
    typealias Entry = RubbishCollectionEntry
    
    func placeholder(in context: Context) -> RubbishCollectionEntry {
        return placeholderEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RubbishCollectionEntry) -> Void) {
        completion(placeholderEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RubbishCollectionEntry>) -> Void) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        let placeholder = placeholderEntry()
        
        let timeline = Timeline(entries: [placeholder], policy: .after(refreshDate))
        completion(timeline)
        
    }
    
    func placeholderEntry() -> RubbishCollectionEntry {
        
        return RubbishCollectionEntry(
            date: Date(),
            streetName: "Musterstraße",
            rubbishPickupItems: RubbishPickupItem.placeholder
        )
        
    }
    
}
