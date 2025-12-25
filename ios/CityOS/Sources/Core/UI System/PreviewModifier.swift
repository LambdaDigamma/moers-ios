//
//  PreviewModifier.swift
//  
//
//  Created by Lennart Fischer on 18.12.20.
//

import Foundation

#if DEBUG
import SwiftUI

struct PreviewProviderModifier: ViewModifier {
    
    /// Whether or not a basic light mode preview is included in the group.
    var includeLightMode: Bool
    
    /// Whether or not a basic dark mode preview is included in the group.
    var includeDarkMode: Bool
    
    /// Whether or not right-to-left layout preview is included in the group.
    var includeRightToLeftMode: Bool
    
    /// Whether or not a preview with large text is included in the group.
    var includeLargeTextMode: Bool
    
    func body(content: Content) -> some View {
        Group {
            if includeLightMode {
                content
                    .previewDisplayName("Light Mode")
                    .environment(\.colorScheme, .light)
            }
            
            if includeDarkMode {
                content
                    .previewDisplayName("Dark Mode")
                    .environment(\.colorScheme, .dark)
            }
            
            if includeRightToLeftMode {
                content
                    .previewDisplayName("Right To Left")
                    .environment(\.layoutDirection, .rightToLeft)
            }
            
            if includeLargeTextMode {
                content
                    .previewDisplayName("Extra Extra Large")
                    .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
            }
        }
    }
    
}

extension View {
    
    /// Creates a group of views with various environment settings that are useful for previews.
    ///
    /// - Parameters:
    ///   - includeLightMode: Whether or not a basic light mode preview is included in the group.
    ///   - includeDarkMode: Whether or not a basic dark mode preview is included in the group.
    ///   - includeRightToLeftMode: Whether or not a right-to-left layout preview is included in the group.
    ///   - includeLargeTextMode: Whether or not a preview with large text is included in the group.
    func makeForPreviewProvider(includeLightMode: Bool = true, includeDarkMode: Bool = true, includeRightToLeftMode: Bool = true, includeLargeTextMode: Bool = true) -> some View {
        modifier(
            PreviewProviderModifier(
                includeLightMode: includeLightMode,
                includeDarkMode: includeDarkMode,
                includeRightToLeftMode: includeRightToLeftMode,
                includeLargeTextMode: includeLargeTextMode
            )
        )
    }
    
}
#endif
