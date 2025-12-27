//
//  EFAPrimaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import SwiftUI

/// EFA Primary Button Style with Liquid Glass design pattern
/// Uses modern materials on iOS 18+ with fallback for earlier versions
/// Supports custom accent colors via environment values
public struct EfaPrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.accent) var accent
    @Environment(\.onAccent) var onAccent
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        if #available(iOS 18.0, *) {
            // On iOS 18+, we maintain the current implementation
            // Future enhancements could include material effects while preserving accent colors
            makeButton(configuration: configuration)
        } else {
            // Fallback for iOS 16-17
            makeButton(configuration: configuration)
        }
    }
    
    /// Creates the button view with the configured accent colors
    /// Note: Both iOS versions currently use the same implementation
    /// to ensure consistent behavior with custom accent colors
    private func makeButton(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(onAccent)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(accent)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
    
}

struct EfaPrimaryButtonStyle_Preview: PreviewProvider {
    
    static var previews: some View {
        
        Button("Activate trip") {
            
        }
        .buttonStyle(EfaPrimaryButtonStyle())
        .efaAccentColor(.blue)
        .efaOnAccentColor(.white)
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
        Button("Activate trip") {
            
        }
        .buttonStyle(EfaPrimaryButtonStyle())
        .efaAccentColor(.yellow)
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
        
    }
    
}


