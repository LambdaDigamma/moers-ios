//
//  RubbishCollectionItemTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI
import RubbishFeature

class RubbishCollectionItemTableViewCell: UITableViewCell {

    var item: RubbishPickupItem? {
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
        
        let constraints = [
            rubbishCollectionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: -8),
            rubbishCollectionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0),
            rubbishCollectionView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -0),
            rubbishCollectionView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension RubbishCollectionItemTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
    }
    
}
