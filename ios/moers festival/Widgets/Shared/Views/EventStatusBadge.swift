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

    var body: some View {
        
        Group {
            
            if event.status == .live {
                
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.live)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(WidgetColors.live.opacity(0.18), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                
            } else if let startDate = event.event.startDate {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(startDate, format: .dateTime.hour())
                    Text(startDate, format: .dateTime.minute())
                }
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(WidgetColors.upcoming)
                .frame(width: 34, alignment: .leading)
                
            }
            
        }
        
    }
    
}
