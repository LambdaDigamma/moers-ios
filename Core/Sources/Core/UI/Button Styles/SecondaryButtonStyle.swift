//
//  SecondaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) var isEnabled
    
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        
        let opacity = isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.5
        
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(.yellow)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .opacity(opacity)
        
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
