//
//  ReadableContentWidth.swift
//  
//
//  Created by Lennart Fischer on 05.05.23.
//

import SwiftUI
import UIKit

struct ReadableContentWidth: ViewModifier {
    @State private var maximumWidth: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maximumWidth)
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { geometry in
                    ReadableContentWidthMeasurement { width in
                        maximumWidth = width
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
    }
    
}

public extension View {
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidth())
    }
}
