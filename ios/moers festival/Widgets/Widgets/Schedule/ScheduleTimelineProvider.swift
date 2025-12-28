//
//  ScheduleTimelineProvider.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import WidgetKit

struct ScheduleTimelineProvider: TimelineProvider {
    
    typealias Entry = ScheduleTimelineEntry
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleTimelineEntry) -> Void) {
        
        completion(ScheduleTimelineEntry(date: Date(), data: WidgetScheduleData(items: WidgetScheduleData.staticContent)))
        
    }
    
    func placeholder(in context: Context) -> ScheduleTimelineEntry {
        
        return ScheduleTimelineEntry(
            date: Date(),
            data: WidgetScheduleData(items: WidgetScheduleData.staticContent)
        )
        
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleTimelineEntry>) -> Void) {
        
        let timeline = Timeline<ScheduleTimelineEntry>(entries: [], policy: .after(Date().addingTimeInterval(30 * 60)))
        
        completion(timeline)
        
    }
    
}
