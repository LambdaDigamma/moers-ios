//
//  SponsorCollectionViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 04.05.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class SponsorCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView = ViewFactory.imageView()
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.addSubview(imageView)
        
        self.imageView.contentMode = .scaleAspectFit
        
    }
    
    private func setupConstraints() {
        
        let constraints = [imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.white
        
    }
    
}
