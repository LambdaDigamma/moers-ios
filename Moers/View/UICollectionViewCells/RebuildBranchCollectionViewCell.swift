//
//  RebuildBranchCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class RebuildBranchCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
        
    }()
    
    lazy var buttonView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.buttonView.layer.cornerRadius = 31
        self.buttonView.clipsToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [titleLabel.heightAnchor.constraint(equalToConstant: 22),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
                           titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
                           buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor),
                           
                           buttonView.topAnchor.constraint(equalTo: self.topAnchor),
                           buttonView.centerXAnchor.constraint(equalTo: self.centerXAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
