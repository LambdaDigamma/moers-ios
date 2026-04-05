//
//  EventsEmptyState.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct EventsEmptyState: View {

    let message: String

    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WidgetColors.primaryText)

                Text(message)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(WidgetColors.overlay.opacity(0.55), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .preferredColorScheme(.dark)
        
    }
    
}
