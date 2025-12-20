//
//  View+Extensions.swift
//  Core
//
//  Created by Lennart Fischer on 07.12.25.
//

import SwiftUI

public extension View {
    
    public func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
    
}
