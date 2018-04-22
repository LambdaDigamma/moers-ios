//
//  DashboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class DashboardViewController: UIViewController {

    // MARK: - UI
    
    lazy var rubbishCollectionHeaderLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = String.localized("DashboardTitleRubbishCollection")
        
        return label
        
    }()
    
    lazy var moreRubbishButton: UIButton = {
        
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitle(String.localized("DashboardMoreRubbish"), for: .normal)
        
        return button
        
    }()
    
    var itemView1 = RubbishCollectionItemView()
    var itemView2 = RubbishCollectionItemView()
    var itemView3 = RubbishCollectionItemView()
    
    lazy var rubbishList: UIStackView = {

        let stackView = UIStackView(arrangedSubviews: [itemView1, itemView2, itemView3])

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView

    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(rubbishCollectionHeaderLabel)
        self.view.addSubview(moreRubbishButton)
        self.view.addSubview(rubbishList)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.loadData()
        
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let constraints = [rubbishCollectionHeaderLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
                           rubbishCollectionHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 14),
                           rubbishCollectionHeaderLabel.rightAnchor.constraint(equalTo: moreRubbishButton.leftAnchor, constant: -8),
                           moreRubbishButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
                           moreRubbishButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -14),
                           moreRubbishButton.widthAnchor.constraint(equalToConstant: 40),
                           moreRubbishButton.heightAnchor.constraint(equalToConstant: 20),
                           rubbishList.topAnchor.constraint(equalTo: moreRubbishButton.bottomAnchor, constant: 8),
                           rubbishList.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 14),
                           rubbishList.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -14),
                           rubbishList.heightAnchor.constraint(equalToConstant: 120)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.rubbishCollectionHeaderLabel.textColor = theme.color
            themeable.moreRubbishButton.setTitleColor(theme.color, for: .normal)
            
        }
        
    }

    public func loadData() {
        
        RubbishManager.shared.loadItems(completion: { (items) in
            
            if items.count >= 1 {
                self.itemView1.rubbishCollectionItem = items[0]
            } else if items.count >= 2 {
                self.itemView2.rubbishCollectionItem = items[1]
            } else if items.count >= 3 {
                self.itemView3.rubbishCollectionItem = items[2]
            }
        })
        
    }
    
}
