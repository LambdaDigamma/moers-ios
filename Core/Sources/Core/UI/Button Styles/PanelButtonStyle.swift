//
//  PanelButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import SwiftUI

public struct BasicPanelStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.8 : 1)
    }
    
}
