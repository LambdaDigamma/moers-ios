//
//  AuditTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 01.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import MMUI
import Gestalt

class AuditTableViewCell: UITableViewCell {

    var audit: Audit? {
        didSet {
            guard let audit = audit else { return }
            self.auditingTypeLabel.text = audit.event.rawValue
            self.dateLabel.text = audit.updatedAt?.beautify(format: "E dd.MM.yyyy • HH:mm") ?? "Zeit nicht bekannt"
        }
    }
    
    private lazy var auditingTypeLabel = { ViewFactory.label() }()
    private lazy var dateLabel = { ViewFactory.label() }()
    private lazy var changesStackView = { ViewFactory.stackView() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(auditingTypeLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(changesStackView)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupChangesStackView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        auditingTypeLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [dateLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           dateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                           dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           auditingTypeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
                           auditingTypeLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                           auditingTypeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           changesStackView.topAnchor.constraint(equalTo: auditingTypeLabel.bottomAnchor, constant: 8),
                           changesStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                           changesStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                           changesStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupChangesStackView() {
        
        changesStackView.arrangedSubviews.forEach { changesStackView.removeArrangedSubview($0) }
        
        for i in 0..<1 {
            
            let auditChangeView = AuditChangeView(valueDescription: "Name:", oldValue: "Alter Name", newValue: "Neuer Name")
            
            changesStackView.addArrangedSubview(auditChangeView)
            
        }
        
    }
    
}

extension AuditTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.auditingTypeLabel.textColor = theme.color
        self.dateLabel.textColor = theme.accentColor
    }
    
}

class AuditChangeView: UIView {
    
    private lazy var changedValueDescriptionLabel: UILabel = { ViewFactory.label() }()
    private lazy var oldValueLabel: UILabel = { ViewFactory.label() }()
    private lazy var newValueLabel: UILabel = { ViewFactory.label() }()
    private lazy var changeSetImageView: UIImageView = { ViewFactory.imageView() }()
    
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
        
        self.addSubview(changedValueDescriptionLabel)
        self.addSubview(oldValueLabel)
        self.addSubview(newValueLabel)
        self.addSubview(changeSetImageView)
        
        self.changedValueDescriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.changedValueDescriptionLabel.text = valueDescription
        self.oldValueLabel.text = oldValue
        self.oldValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.newValueLabel.text = newValue
        self.newValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        
        self.changeSetImageView.image = #imageLiteral(resourceName: "changeset")
        self.changeSetImageView.contentMode = .scaleAspectFit
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            changedValueDescriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            changedValueDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            changedValueDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            newValueLabel.topAnchor.constraint(equalTo: changedValueDescriptionLabel.bottomAnchor, constant: 4),
            newValueLabel.leadingAnchor.constraint(equalTo: changedValueDescriptionLabel.leadingAnchor),
            newValueLabel.trailingAnchor.constraint(equalTo: changedValueDescriptionLabel.trailingAnchor),
            changeSetImageView.topAnchor.constraint(equalTo: newValueLabel.bottomAnchor, constant: 4),
            changeSetImageView.leadingAnchor.constraint(equalTo: changedValueDescriptionLabel.leadingAnchor),
            changeSetImageView.trailingAnchor.constraint(equalTo: changedValueDescriptionLabel.trailingAnchor),
            changeSetImageView.heightAnchor.constraint(equalTo: changeSetImageView.widthAnchor, multiplier: 80 / 600),
            oldValueLabel.topAnchor.constraint(equalTo: changeSetImageView.bottomAnchor, constant: 4),
            oldValueLabel.leadingAnchor.constraint(equalTo: changedValueDescriptionLabel.leadingAnchor),
            oldValueLabel.trailingAnchor.constraint(equalTo: changedValueDescriptionLabel.trailingAnchor),
            oldValueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

extension AuditChangeView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.changedValueDescriptionLabel.textColor = theme.color
        self.oldValueLabel.textColor = UIColor(hexString: "FF0000")
        self.newValueLabel.textColor = UIColor(hexString: "089C3B")
    }
    
}
