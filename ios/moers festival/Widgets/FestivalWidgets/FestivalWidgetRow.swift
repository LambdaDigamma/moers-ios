//
//  FestivalWidgetRow.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetRow: View {

    let event: FestivalWidgetDisplayEvent
    let isCompact: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            EventStatusBadge(event: event)

            VStack(alignment: .leading, spacing: isCompact ? 2 : 3) {
                Text(event.event.name)
                    .font(.system(.caption, design: .default, weight: .heavy))
                    .fontWeight(.bold)
                    .foregroundStyle(WidgetColors.primaryText)
                    .lineLimit(isCompact ? 1 : 2)
                    .minimumScaleFactor(isCompact ? 0.9 : 1)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 4) {
                    Text(event.event.venueName)
                        .lineLimit(1)

                    if event.status == .live, let endDate = event.event.endDate, endDate > .now {
                        Text("·")
                        Text("until \(endDate, format: .dateTime.hour().minute())")
                    }
                }
                .font(.caption2)
                .foregroundStyle(WidgetColors.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
