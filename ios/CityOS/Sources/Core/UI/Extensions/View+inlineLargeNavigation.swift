//
//  View+inlineLargeNavigation.swift
//  CityOS
//
//  Created by Lennart Fischer on 29.12.25.
//

import SwiftUI


extension View {
    
    @ViewBuilder
    public func inlineLargeNavigation() -> some View {
#if os(tvOS)
        self
#else
        if #available(iOS 26.0, *) {
            self.toolbarTitleDisplayMode(.inlineLarge)
                .scrollEdgeEffectStyle(.soft, for: .all)
        } else {
            self.toolbarTitleDisplayMode(.inlineLarge)
        }
#endif
    }
    
}
