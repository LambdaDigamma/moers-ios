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
    
    var body: some View {
        
        let items = [
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 1 * 24 * 60 * 60),
                type: .paper
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 1 * 24 * 60 * 60),
                type: .plastic
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 2 * 24 * 60 * 60),
                type: .organic
            )
        ]
        
        ZStack {
            
            Color(UIColor.black)
            
            if widgetFamily == .systemSmall {
                
                if let first = items.first {
                    RubbishCalendarItem(item: first)
                        .padding()
                }
                
            } else if widgetFamily == .systemMedium {
                
                HStack() {
                    
                    RubbishDayPanel(date: "Morgen", items: [
                        .init(date: Date(), type: .plastic),
                        .init(date: Date(), type: .paper),
                    ])
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    Divider()
                    
                    RubbishDayPanel(date: "24.12.", items: [
                        .init(date: Date(), type: .organic),
                    ])
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    Divider()
                    
                    RubbishDayPanel(date: "25.12.", items: [
                    ])
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                }
                
                
//                HorizontalPickupItems(items: items)
//                    .padding()
                
            }
            
        }
        
    }
    
}

struct RubbishCollectionWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        
        RubbishCollectionWrapperView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        RubbishCollectionWrapperView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .preferredColorScheme(.dark)
            .environment(\.colorScheme, .dark)
        
    }
}
