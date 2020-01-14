//
//  SwitchTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 26.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class SwitchTableViewCell: UITableViewCell {
    
    lazy var descriptionLabel = { ViewFactory.label() }()
    
    lazy var switchControl: UISwitch = {
        
        let switchControl = UISwitch()
        
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(switchChanged(switchControl:)), for: .valueChanged)
        
        return switchControl
        
    }()
    
    var action: ((Bool) -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(switchControl)
        self.contentView.addSubview(descriptionLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [descriptionLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           descriptionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                           descriptionLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -8),
                           descriptionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           switchControl.topAnchor.constraint(equalTo: margins.topAnchor),
                           switchControl.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           switchControl.bottomAnchor.constraint(equalTo: margins.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }

    @objc func switchChanged(switchControl: UISwitch) {
        action?(switchControl.isOn)
    }
    
}

extension SwitchTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.descriptionLabel.textColor = theme.color
    }
    
}
