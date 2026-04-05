//
//  FestivalWidgetSection.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetSection<Content: View>: View {

    let title: String
    let accent: FestivalWidgetStatus
    let content: Content

    init(
        title: String,
        accent: FestivalWidgetStatus,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Capsule()
                    .fill(accent == .live ? WidgetColors.live : WidgetColors.upcoming)
                    .frame(width: 14, height: 4)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            content
        }
    }
}