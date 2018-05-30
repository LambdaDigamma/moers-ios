//
//  SwitchTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 26.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class SwitchTableViewCell: UITableViewCell {
    
    lazy var descriptionLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    lazy var switchControl: UISwitch = {
        
        let switchControl = UISwitch()
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchChanged(switchControl:)), for: .valueChanged)
        
        return switchControl
        
    }()
    
    var action: ((Bool) -> ())?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(switchControl)
        self.addSubview(descriptionLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           descriptionLabel.rightAnchor.constraint(equalTo: switchControl.leftAnchor, constant: -8),
                           descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           switchControl.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           switchControl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           switchControl.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.descriptionLabel.textColor = theme.color
            
        }
        
    }

    @objc func switchChanged(switchControl: UISwitch) {
        action?(switchControl.isOn)
    }
    
}
