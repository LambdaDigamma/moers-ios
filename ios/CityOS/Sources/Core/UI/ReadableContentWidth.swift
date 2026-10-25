//
//  ReadableContentWidth.swift
//  
//
//  Created by Lennart Fischer on 05.05.23.
//

import SwiftUI
import UIKit

struct ReadableContentWidth: ViewModifier {
    let includeLayoutMargins: Bool
    @State private var maximumWidth: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: maximumWidth)
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { geometry in
                    ReadableContentWidthMeasurement(includeLayoutMargins: includeLayoutMargins) { width in
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
    /// Disable layout margins when the content already supplies its own padding.
    func readableContentWidth(includeLayoutMargins: Bool = true) -> some View {
        modifier(ReadableContentWidth(includeLayoutMargins: includeLayoutMargins))
    }
}
