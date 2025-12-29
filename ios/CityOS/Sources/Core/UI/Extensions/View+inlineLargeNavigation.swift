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
        if #available(iOS 17.0, *) {
            self.toolbarTitleDisplayMode(.inlineLarge)
        } else {
            self.navigationBarTitleDisplayMode(.large)
        }
    }
    
}
