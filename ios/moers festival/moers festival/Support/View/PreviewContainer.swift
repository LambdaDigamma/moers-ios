//
//  PreviewContainer.swift
//  moers festival
//
//  Created by Lennart Fischer on 16.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import UIKit

struct PreviewContainer<T: UIView>: UIViewRepresentable {
    
    let view: T
    
    init(_ viewBuilder: @escaping () -> T) {
        view = viewBuilder()
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> T {
        return view
    }
    
    func updateUIView(_ view: T, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
