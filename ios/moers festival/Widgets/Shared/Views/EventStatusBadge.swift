//
//  EventStatusBadge.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct EventStatusBadge: View {

    let event: FestivalWidgetDisplayEvent

    @ScaledMetric(relativeTo: .caption) private var timeFontSize = 11
    @ScaledMetric(relativeTo: .caption) private var liveFontSize = 10
    @ScaledMetric(relativeTo: .caption) private var badgeWidth = 34
    @ScaledMetric(relativeTo: .caption2) private var liveHorizontalPadding = 6
    @ScaledMetric(relativeTo: .caption2) private var liveVerticalPadding = 4

    var body: some View {
        
        Group {
            
            if event.status == .live {
                
                Text("LIVE")
                    .font(.system(size: liveFontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.live)
                    .padding(.horizontal, liveHorizontalPadding)
                    .padding(.vertical, liveVerticalPadding)
                    .background(WidgetColors.live.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                
            } else if let startDate = event.event.startDate {
                
                Text(startDate, format: .dateTime.hour().minute())
                    .font(.system(size: timeFontSize, weight: .bold, design: .monospaced))
                    .foregroundStyle(WidgetColors.upcoming)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: badgeWidth, alignment: .leading)
                
            }
            
        }
        
    }
    
}
