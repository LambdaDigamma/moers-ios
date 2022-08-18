//
//  RubbishCollectionWrapperView.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import RubbishFeature

struct RubbishCollectionWrapperView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    public let items: [RubbishPickupItem]
    
    public init(items: [RubbishPickupItem]) {
        self.items = items
    }
    
    public var body: some View {
        
        ZStack {
            
//            if ![WidgetFamily.accessoryInline, .accessoryRectangular].contains(widgetFamily) {
//                Color(UIColor.systemBackground)
//            } else {
////                AccessoryWidgetBackground()
////                    .clipShape(RoundedRectangle(cornerRadius: 10))
//            }
            
            if widgetFamily == .systemSmall {
                small()
            } else if widgetFamily == .systemMedium {
                medium()
            }
            
//            if #available(iOSApplicationExtension 16.0, *) {
//                if widgetFamily == .accessoryRectangular {
//                    RubbishAccessoryRectangle(items: items)
//                } else if widgetFamily == .accessoryInline {
//                    RubbishAccessoryInline(items: items)
//                }
//            }
            
        }
        
    }
    
    @ViewBuilder
    private func small() -> some View {
        
        let tomorrow = Date(timeIntervalSinceNow: 60 * 60 * 24)
        let tomorrowItems = items.filter { (item: RubbishPickupItem) in
            return Calendar.autoupdatingCurrent.isDateInTomorrow(item.date)
        }
        
        RubbishDayPanel(date: title(for: tomorrow), items: tomorrowItems)
            .cornerRadius(16)
            .padding(8)
        
    }
    
    @ViewBuilder
    private func medium() -> some View {
        
        HStack(spacing: 8) {
            
            ForEach(days, id: \.self) { day in
                
                RubbishDayPanel(
                    date: title(for: day),
                    items: items(for: day)
                )
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    
            }
                
        }
        .padding(8)
        
    }
    
    private var days: [Date] {
        return Date.todayPlusNDays(2)
    }
    
    private func items(for day: Date) -> [RubbishPickupItem] {
        return items.filter({ Self.calendar.isDate($0.date, inSameDayAs: day )})
    }
    
    private func title(for day: Date) -> String {
        return Self.shortRubbishDateFormatter.string(from: day)
    }
    
}

internal extension RubbishCollectionWrapperView {
    
    static let shortRubbishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let calendar: Calendar = {
        return Calendar.autoupdatingCurrent
    }()
    
}

struct RubbishCollectionWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        
//        RubbishCollectionWrapperView(items: RubbishPickupItem.placeholder)
//            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        
        RubbishCollectionWrapperView(items: RubbishPickupItem.placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        RubbishCollectionWrapperView(items: RubbishPickupItem.placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
        
    }
}
