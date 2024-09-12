//
//  TitleCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 12.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class TitleCardView: CardView {

    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        
        return label
        
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           titleLabel.heightAnchor.constraint(equalToConstant: 26)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
    }
    
}
