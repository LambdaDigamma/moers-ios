//
//  BranchCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class BranchCollectionViewCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = { ViewFactory.label() }()
    lazy var imageView: UIImageView = { ViewFactory.imageView() }()
    lazy var buttonView: UIView = { ViewFactory.blankView() }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(titleLabel)
        self.addSubview(imageView)
        self.addSubview(buttonView)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.minimumScaleFactor = 0.5
        self.titleLabel.textAlignment = .center
        self.buttonView.layer.cornerRadius = 31
        self.buttonView.clipsToBounds = true
        self.buttonView.backgroundColor = AppColor.yellow
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.titleLabel.textColor = theme.color
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [titleLabel.heightAnchor.constraint(equalToConstant: 22),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
                           titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
                           buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor),
                           buttonView.widthAnchor.constraint(equalTo: buttonView.heightAnchor),
                           buttonView.topAnchor.constraint(equalTo: self.topAnchor),
                           buttonView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),
                           buttonView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                           imageView.widthAnchor.constraint(equalTo: buttonView.widthAnchor),
                           imageView.heightAnchor.constraint(equalTo: buttonView.heightAnchor),
                           imageView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
                           imageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
