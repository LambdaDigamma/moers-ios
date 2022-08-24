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
    
    private var content: Content
    
    public init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    public var body: some View {
        
        ZStack {
            self.content
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
//        .shadow(
//            color: Color.secondarySystemFill.opacity(1),
//            radius: colorScheme == .light ? 8 : 0,
//            x: 2,
//            y: 2
//        )
        
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
