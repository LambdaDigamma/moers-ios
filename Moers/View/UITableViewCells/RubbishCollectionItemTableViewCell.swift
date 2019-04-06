//
//  RubbishCollectionItemTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI

class RubbishCollectionItemTableViewCell: UITableViewCell {

    var item: RubbishCollectionItem? {
        didSet {
            self.rubbishCollectionView.rubbishCollectionItem = item
        }
    }
    
    private lazy var rubbishCollectionView: RubbishCollectionView = {
        
        let rubbishCollectionView = RubbishCollectionView()
        
        rubbishCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return rubbishCollectionView
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(rubbishCollectionView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [rubbishCollectionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: -8),
                           rubbishCollectionView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0),
                           rubbishCollectionView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -0),
                           rubbishCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
}
