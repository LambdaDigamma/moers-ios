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
            
            Color(UIColor.black)
            
            if widgetFamily == .systemSmall {
                
                if let first = items.first {
                    RubbishCalendarItem(item: first)
                        .padding()
                }
                
            } else if widgetFamily == .systemMedium {
                
                medium()
                
                VStack(alignment: .leading, spacing: 0) {
                    
//                    Text("Abfallkalender")
//                        .font(Font.callout.weight(.bold))
//                        .foregroundColor(.white)
//                        .padding(.horizontal)
//                        .padding(.vertical, 8)
                    
                }
                
//                HorizontalPickupItems(items: items)
//                    .padding()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func medium() -> some View {
        
        HStack(spacing: 16) {
            
            ForEach(days, id: \.self) { day in
                
                RubbishDayPanel(
                    date: title(for: day),
                    items: items(for: day)
                )
                    .frame(maxWidth: .infinity)
//                    .padding([.leading, .trailing, .bottom, .top])
                    
                }
            
//            RubbishDayPanel(date: "Morgen", items: [
//                .init(date: Date(), type: .plastic),
//                .init(date: Date(), type: .paper),
//            ])
//                .frame(maxWidth: .infinity)
//                .padding([.leading, .trailing, .bottom, .top])
//
//                Divider()
//
//            RubbishDayPanel(date: "24.12.", items: [
//                .init(date: Date(), type: .organic),
//            ])
//                .frame(maxWidth: .infinity)
//                .padding([.leading, .trailing, .bottom, .top])
//
//                Divider()
//
//            RubbishDayPanel(date: "25.12.", items: [])
//                .frame(maxWidth: .infinity)
//                .padding([.leading, .trailing, .bottom, .top])
                
        }
        .padding()
        
    }
    
    var days: [Date] {
        return Date.todayPlusNDays(2)
    }
    
    private func items(for day: Date) -> [RubbishPickupItem] {
        return items.filter({ Self.calendar.isDate($0.date, inSameDayAs: day )})
    }
    
    private func title(for day: Date) -> String {
        return Self.shortRubbishDateFormatter.string(from: day)
    }
    
    public static let shortRubbishDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.doesRelativeDateFormatting = true
        
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    public static let calendar: Calendar = {
        return Calendar.autoupdatingCurrent
    }()
    
}

struct RubbishCollectionWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        
        RubbishCollectionWrapperView(items: RubbishPickupItem.placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        RubbishCollectionWrapperView(items: RubbishPickupItem.placeholder)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
        
    }
}
