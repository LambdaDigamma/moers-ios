//
//  RubbishCollectionProvider.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import WidgetKit

class RubbishCollectionProvider: TimelineProvider {
    
    typealias Entry = RubbishCollectionEntry
    
    func placeholder(in context: Context) -> RubbishCollectionEntry {
        return RubbishCollectionEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RubbishCollectionEntry) -> Void) {
        completion(RubbishCollectionEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RubbishCollectionEntry>) -> Void) {
        
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        
        let timeline = Timeline(entries: [RubbishCollectionEntry(date: currentDate)], policy: .after(refreshDate))
        completion(timeline)
        
    }
    
}
