//
//  FriendCollectionViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 04.05.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class FriendCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel = ViewFactory.label()
    
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
        
        self.addSubview(titleLabel)
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        
    }
    
    private func setupConstraints() {
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.white
        
    }
    
}
