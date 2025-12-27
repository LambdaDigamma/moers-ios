//
//  PrimaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI

/// Primary button style using Liquid Glass design pattern
/// Uses modern materials on iOS 18+ with fallback for earlier versions
public struct PrimaryButtonStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        LiquidGlassButtonStyle(prominence: .primary).makeBody(configuration: configuration)
    }
    
}

struct PrimaryButtonStyle_Preview: PreviewProvider {
    
    static var previews: some View {
        
        Button("Listen now") {
            
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
    }
    
}
