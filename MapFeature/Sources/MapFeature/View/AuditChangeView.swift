//
//  AuditChangeView.swift
//  Moers
//
//  Created by Lennart Fischer on 01.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt

class AuditChangeView: UIView {
    
    private lazy var leadingSeparator: UIView = { CoreViewFactory.separatorView() }()
    private lazy var changedValueDescriptionLabel: UILabel = { CoreViewFactory.label() }()
    private lazy var trailingSeparator: UIView = { CoreViewFactory.separatorView() }()
    private lazy var oldValueLabel: UILabel = { CoreViewFactory.label() }()
    private lazy var newValueLabel: UILabel = { CoreViewFactory.label() }()
    private lazy var changeSetImageView: UIImageView = { CoreViewFactory.imageView() }()
    
    let valueDescription: String
    let oldValue: String
    let newValue: String
    
    init(valueDescription: String, oldValue: String, newValue: String) {
        
        self.valueDescription = valueDescription
        self.oldValue = oldValue
        self.newValue = newValue
        
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(leadingSeparator)
        self.addSubview(changedValueDescriptionLabel)
        self.addSubview(trailingSeparator)
        self.addSubview(oldValueLabel)
        self.addSubview(newValueLabel)
        
        self.changedValueDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.changedValueDescriptionLabel.text = valueDescription
        self.changedValueDescriptionLabel.textAlignment = .center
        self.oldValueLabel.text = oldValue
        self.oldValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.oldValueLabel.numberOfLines = 0
        self.newValueLabel.text = newValue
        self.newValueLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.newValueLabel.numberOfLines = 0
        self.oldValueLabel.textAlignment = .right
        
        self.changeSetImageView.image = #imageLiteral(resourceName: "changeset")
        self.changeSetImageView.contentMode = .scaleAspectFit
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            changedValueDescriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            changedValueDescriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            leadingSeparator.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            leadingSeparator.centerYAnchor.constraint(equalTo: changedValueDescriptionLabel.centerYAnchor),
            leadingSeparator.trailingAnchor.constraint(equalTo: changedValueDescriptionLabel.leadingAnchor, constant: -8),
            trailingSeparator.centerYAnchor.constraint(equalTo: changedValueDescriptionLabel.centerYAnchor),
            trailingSeparator.leadingAnchor.constraint(equalTo: changedValueDescriptionLabel.trailingAnchor, constant: 8),
            trailingSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            newValueLabel.topAnchor.constraint(equalTo: changedValueDescriptionLabel.bottomAnchor, constant: 4),
            newValueLabel.leadingAnchor.constraint(equalTo: leadingSeparator.leadingAnchor),
            newValueLabel.trailingAnchor.constraint(equalTo: oldValueLabel.leadingAnchor),
            oldValueLabel.topAnchor.constraint(equalTo: newValueLabel.topAnchor),
            oldValueLabel.trailingAnchor.constraint(equalTo: trailingSeparator.trailingAnchor),
            oldValueLabel.heightAnchor.constraint(equalTo: newValueLabel.heightAnchor),
            oldValueLabel.widthAnchor.constraint(equalTo: newValueLabel.widthAnchor),
            oldValueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

extension AuditChangeView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.changedValueDescriptionLabel.textColor = theme.decentColor
        self.oldValueLabel.textColor = UIColor(hexString: "FF0000")
        self.newValueLabel.textColor = UIColor(hexString: "089C3B")
        self.trailingSeparator.backgroundColor = theme.decentColor
        self.leadingSeparator.backgroundColor = theme.decentColor
    }
    
}
