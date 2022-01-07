//
//  CardPanelView.swift
//  Moers
//
//  Created by Lennart Fischer on 28.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

struct CardPanelView<Content: View>: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var content: Content
    
    init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }
    
    var body: some View {
        
        ZStack {
            self.content
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(radius: colorScheme == .light ? 8 : 0)
        
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
