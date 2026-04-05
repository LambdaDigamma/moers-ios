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

    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(WidgetColors.primaryText)

            Text(subtitle)
                .font(.caption2.monospaced())
                .foregroundStyle(WidgetColors.mutedText)
                .lineLimit(1)
            
        }
        
    }
    
}
