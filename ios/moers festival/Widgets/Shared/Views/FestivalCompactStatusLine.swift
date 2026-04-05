//
//  FestivalCompactStatusLine.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalCompactStatusLine: View {

    let event: FestivalWidgetDisplayEvent

    var body: some View {
        
        HStack(spacing: 6) {
            
            if event.status == .live {
                
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(WidgetColors.live.opacity(0.2), in: Capsule())
                    .foregroundStyle(WidgetColors.live)
                
            } else if let startDate = event.event.startDate {
                
                Text(startDate, format: .dateTime.hour().minute())
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(WidgetColors.upcoming)
                
            }

            Text(event.event.venueName)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.secondary)
            
        }
        
    }
    
}
