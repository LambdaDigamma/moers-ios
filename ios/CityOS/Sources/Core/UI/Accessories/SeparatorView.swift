//
//  SeparatorView.swift
//  MMUI
//
//  Created by Lennart Fischer on 25.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit

public class SeparatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [
            heightAnchor.constraint(equalToConstant: 1)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.separator
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
