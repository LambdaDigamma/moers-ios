//
//  ScheduleMedium.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.04.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import WidgetKit

public struct ScheduleMedium: View {
    
    public var data: WidgetScheduleData
    
    public init(data: WidgetScheduleData) {
        self.data = data
        self.data.items = Array(self.data.items.prefix(4))
    }
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            ZStack(alignment: .topLeading) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("Your schedule")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .unredacted()
                    
                    if !data.items.isEmpty {
                        
                        HStack(spacing: 8) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                if data.items.count >= 1 {
                                    entry(for: data.items[0])
                                }
                                
                                if data.items.count >= 2 {
                                    entry(for: data.items[1])
                                }
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                
                                if data.items.count >= 3 {
                                    entry(for: data.items[2])
                                }
                                
                                if data.items.count >= 4 {
                                    entry(for: data.items[3])
                                }
                                
                            }
                            .padding(.leading, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        
                    } else {
                        
                        Text("There are no further events on your schedule.")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top)
                            .unredacted()
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .preferredColorScheme(.dark)
                
            }
            .frame(
                maxWidth: proxy.size.width,
                maxHeight: proxy.size.height,
                alignment: .topLeading
            )
            .background {
                
                ZStack {
                    
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
                        .clipped()
                    
                }
                
            }
            
        }
        .preferredColorScheme(.dark)
        
    }
    
    @ViewBuilder func entry(for item: WidgetScheduleItem) -> some View {
        
        VStack(alignment: .leading) {
            
            Text(item.name)
                .fontDesign(.monospaced)
                .lineLimit(1)
                .truncationMode(.tail)
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

struct ScheduleMedium_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ScheduleMedium(
            data: WidgetScheduleData(items: WidgetScheduleData.staticContent)
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        ScheduleMedium(
            data: WidgetScheduleData(items: WidgetScheduleData.staticContent)
        )
        .redacted(reason: .placeholder)
        .previewDisplayName("Redacted")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        ScheduleMedium(
            data: WidgetScheduleData(items: [])
        )
        .previewDisplayName("Empty")
        .previewContext(WidgetPreviewContext(family: .systemMedium))
        
    }
    
}
