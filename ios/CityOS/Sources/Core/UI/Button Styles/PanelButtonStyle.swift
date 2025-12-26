//
//  PanelButtonStyle.swift
//  
//
//  Created by Lennart Fischer on 10.02.22.
//

import SwiftUI

public struct BasicPanelStyle: ButtonStyle {
    
    public init() { }
    
    public func makeBody(configuration: BasicPanelStyle.Configuration) -> some View {
        BasicPanelStyleView(configuration: configuration)
    }
    
    public struct BasicPanelStyleView: View {
        
        @SwiftUI.Environment(\.isEnabled) var isEnabled
        
        public let configuration: BasicPanelStyle.Configuration
        
        public init(configuration: BasicPanelStyle.Configuration) {
            self.configuration = configuration
        }
        
        public var body: some View {
            configuration
                .label
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
        
    }
    
}
