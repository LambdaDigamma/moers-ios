//
//  SecondaryButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
    
    public init() {
        
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .font(.body.weight(.semibold))
            .padding()
            .foregroundColor(.yellow)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.7 : 1)
        
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
