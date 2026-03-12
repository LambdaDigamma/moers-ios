//
//  ProminentButtonStyle.swift
//  moers festival
//
//  Created by Lennart Fischer on 28.03.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import SwiftUI

struct ProminentButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Self.Configuration) -> some View {
        label(configuration: configuration)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                configuration.isPressed ?
                    Color(AppColors.navigationAccent).opacity(0.8) :
                    Color(AppColors.navigationAccent)
            )
            .cornerRadius(12)
    }
    
    @ViewBuilder func label(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundColor(Color(AppColors.onAccent))
    }
    
}

struct ProminentButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Button("Button", action: {})
            .buttonStyle(ProminentButtonStyle())
            .padding()
            .previewLayout(.sizeThatFits)
        
        Button("Button", action: {})
            .buttonStyle(ProminentButtonStyle())
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        
    }
    
}
