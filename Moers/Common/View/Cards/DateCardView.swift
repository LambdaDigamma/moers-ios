//
//  DetailsCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 13.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class DetailsCardView: CardView {

    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.bold)
        
        return label
        
    }()
    
    lazy var subtitleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [subtitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           subtitleLabel.heightAnchor.constraint(equalToConstant: 20),
                           titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
                           titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           titleLabel.heightAnchor.constraint(equalToConstant: 26)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

}
