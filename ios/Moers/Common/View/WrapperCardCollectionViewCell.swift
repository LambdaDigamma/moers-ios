//
//  WrapperCardCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 07.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class WrapperCardCollectionViewCell: UICollectionViewCell {
    
    var view: UIView? {
        didSet {
            self.subviews.forEach { $0.removeFromSuperview() }
            self.setup()
        }
    }
    
    private func setup() {
        
        guard let view = view else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        
        let constraints = [view.topAnchor.constraint(equalTo: self.topAnchor),
                           view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           view.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
