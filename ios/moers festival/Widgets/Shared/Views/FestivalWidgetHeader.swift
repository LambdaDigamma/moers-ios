//
//  FestivalWidgetHeader.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetHeader: View {

    let title: String
    let subtitle: String
    let subtitleSystemImage: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .default))
                .fontWeight(.bold)
                .foregroundStyle(WidgetColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 8)

            Group {
                if let subtitleSystemImage {
                    Label(subtitle, systemImage: subtitleSystemImage)
                        .labelStyle(.titleAndIcon)
                } else {
                    Text(subtitle)
                }
            }
            .font(.caption2.monospaced())
            .foregroundStyle(WidgetColors.mutedText)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
        }
    }

}
