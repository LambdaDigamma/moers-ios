//
//  GripperView.swift
//  moers festival
//
//  Created by Lennart Fischer on 16.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit
import SwiftUI

class GripperView: UIView {
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = UIColor.systemGray
        self.setupConstraints()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 2.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [
            self.heightAnchor.constraint(equalToConstant: 5),
            self.widthAnchor.constraint(equalToConstant: 36),
        ].map { 
            $0.priority = .required
            return $0
        }
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

#Preview {
    PreviewContainer<GripperView> {
        return GripperView()
    }
    .padding()
}
