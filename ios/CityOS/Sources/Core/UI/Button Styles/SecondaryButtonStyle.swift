//
//  SecondaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI

/// Secondary button style using Liquid Glass design pattern
/// Uses modern materials on iOS 18+ with fallback for earlier versions
public struct SecondaryButtonStyle: ButtonStyle {
    
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        LiquidGlassButtonStyle(prominence: .secondary).makeBody(configuration: configuration)
    }
    
}

struct SecondaryButtonStyle_Preview: PreviewProvider {
    
    static var previews: some View {
        
        Button {
            
        } label: {
            Text("\(Image(systemName: "bell.circle.fill")) Remind me")
        }
        .buttonStyle(SecondaryButtonStyle())
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
    }
    
}
