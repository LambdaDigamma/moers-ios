//
//  ScheduleSmall.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import WidgetKit

public struct ScheduleSmall: View {
    
    var data: WidgetScheduleData
    
    public init(data: WidgetScheduleData) {
        self.data = data
        self.data.items = Array(self.data.items.prefix(2))
    }
    
    public var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            
            Image("StyledBackground")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(0.25)
                .unredacted()
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Your schedule")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .unredacted()
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    if !data.items.isEmpty {
                        ForEach(data.items) { item in
                            entry(for: item)
                        }
                    } else {
                        
                        Text("There are no further events on your schedule.")
                            .font(.caption)
                            .foregroundColor(.white)
                            .unredacted()
                        
                    }
                    
                }.padding(.top)
                    
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
        }
        .preferredColorScheme(.dark)
        
    }
    
    @ViewBuilder func entry(for item: WidgetScheduleItem) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(item.name)
                .fontDesign(.monospaced)
                .lineLimit(1)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Group {
                Text(item.startDate, style: .time)
                Text(item.place)
            }
                .foregroundColor(.secondary)
                .font(.caption2)
            
        }
        
    }
    
    
}

struct ScheduleSmall_Previews: PreviewProvider {
    
    static var data = [
        WidgetScheduleItem(
            name: "Editrix (US)",
            startDate: Date(timeIntervalSinceNow: 60 * 7),
            place: "ENNI Eventhalle"
        ),
        WidgetScheduleItem(
            name: "SAPAT (DE, SE, UK)",
            startDate: Date(timeIntervalSinceNow: 60 * 70),
            place: "AmViehTheater"
        )
    ]
    
    static var previews: some View {
        
        ScheduleSmall(
            data: WidgetScheduleData(items: self.data)
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ScheduleSmall(
            data: WidgetScheduleData(items: self.data)
        )
        .redacted(reason: .placeholder)
        .previewDisplayName("Redacted")
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ScheduleSmall(
            data: WidgetScheduleData(items: [])
        )
        .previewDisplayName("Empty")
        .previewContext(WidgetPreviewContext(family: .systemSmall))
        
    }
}
