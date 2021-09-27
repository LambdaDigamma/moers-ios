//
//  PrimaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.yellow)
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
        
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
