//
//  CardPanelView.swift
//  Moers
//
//  Created by Lennart Fischer on 28.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

public struct CardPanelView<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.cardPanelBorder) private var border
    
    private let content: Content
    
    private let cornerRadius = 16
    
    public init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(border?.color ?? .clear, lineWidth: border?.lineWidth ?? 0)
        )
        .shadowSM()
    }
    
}

struct CardPanelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            CardPanelView {
                Text("Just testing")
                    .padding()
            }
            .padding()
            
            CardPanelView {
                Text("Just testing")
                    .padding()
            }
            .padding()
            .colorScheme(.dark)
            
        }
    }
}
