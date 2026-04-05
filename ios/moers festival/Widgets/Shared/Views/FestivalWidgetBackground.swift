//
//  FestivalWidgetBackground.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetBackground: View {

    var body: some View {
        
        ZStack {
            
            Image("StyledBackground")
                .resizable()
                .scaledToFill()
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.6),
                    Color.black.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
//            LinearGradient(
//                colors: [
//                    WidgetColors.overlay,
//                    .clear
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
        }
        .preferredColorScheme(.dark)
        
    }
    
}
