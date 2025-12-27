//
//  EFAPrimaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import SwiftUI

/// EFA Primary Button Style with Liquid Glass design pattern
/// Supports custom accent colors via environment values
/// Note: Currently uses the same implementation across iOS versions to ensure
/// consistent behavior with custom accent colors
public struct EfaPrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.accent) var accent
    @Environment(\.onAccent) var onAccent
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
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


