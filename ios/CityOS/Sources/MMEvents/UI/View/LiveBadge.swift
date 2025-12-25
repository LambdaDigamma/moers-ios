//
//  LiveBadge.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import SwiftUI

public struct LiveBadge: View {
    
    @State private var isAnimating: Bool = false
    
    public init() {
        
    }
    
    public var body: some View {
        
        HStack(spacing: 6) {
            
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6, alignment: .center)
                .opacity(isAnimating ? 1.0 : 0.4)
                .animation(
                    Animation.linear(duration: 0.7).repeatForever(),
                    value: isAnimating
                )
                .onAppear {
                    self.isAnimating = true
                }
            
            Text("Live")
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
            
        }
        .padding(.horizontal, 6)
        .padding(.leading, 2)
        .padding(.vertical, 2)
        .background(Color.red)
        .cornerRadius(4)
        
    }
    
}

struct LiveBadge_Previews: PreviewProvider {
    static var previews: some View {
        
        LiveBadge()
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
        
        LiveBadge()
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
    }
}
