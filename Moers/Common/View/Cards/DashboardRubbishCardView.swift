//
//  DashboardRubbishCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 12.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class DashboardRubbishCardView: TitleCardView {

    // MARK: - UI
    
    var itemView1 = RubbishCollectionView()
    var itemView2 = RubbishCollectionView()
    var itemView3 = RubbishCollectionView()
    
    lazy var rubbishList: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [itemView1, itemView2, itemView3])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel.text = String.localized("DashboardTitleRubbishCollection")
        
        self.addSubview(rubbishList)
        
        self.setupConstraints()
        self.setupTheming()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.titleLabel.textColor = theme.color
            themeable.backgroundColor = theme.cardBackgroundColor
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [rubbishList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                           rubbishList.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           rubbishList.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           rubbishList.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]

        NSLayoutConstraint.activate(constraints)
        
    }
    
}
