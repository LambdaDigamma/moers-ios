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
            
            self.dateLabel.text = "vor " + (audit.updatedAt?.timeAgo() ?? "n/v")
            
            switch audit.event {
                
            case .created:
                self.auditingTypeLabel.text = "Eintrag erstellt"
//                self.auditingTypeLabel.textColor = UIColor(hexString: "089C3B")
                self.auditingTypeImageView.image = #imageLiteral(resourceName: "changeset_add")
                
            case .updated:
                self.auditingTypeLabel.text = "Eintrag aktualisiert"
//                self.auditingTypeLabel.textColor = UIColor(hexString: "089C3B")
                self.auditingTypeImageView.image = #imageLiteral(resourceName: "changeset_update")
                
            case .deleted:
                self.auditingTypeLabel.text = "Eintrag gelöscht"
//                self.auditingTypeLabel.textColor = UIColor(hexString: "FF0000")
                self.auditingTypeImageView.image = nil
                self.auditingTypeImageView.image = #imageLiteral(resourceName: "changeset_delete")
                
            case .restored:
                self.auditingTypeLabel.text = "Eintrag widerhergestellt"
//                self.auditingTypeLabel.textColor = UIColor(hexString: "089C3B")
                self.auditingTypeImageView.image = #imageLiteral(resourceName: "changeset_add")
            
            }
            
            self.setupChangesStackView()
            
        }
    }
    
    private lazy var dateLabel = { ViewFactory.label() }()
    private lazy var auditingTypeImageView = { ViewFactory.imageView() }()
    private lazy var auditingTypeLabel = { ViewFactory.label() }()
    private lazy var changeSetHeader = { ViewFactory.label() }()
    private lazy var changesStackView = { ViewFactory.stackView() }()
    
    private let lookupTable: [String: String] = [
        "name": String.localized("AuditingEntryName"),
        "lat": String.localized("AuditingEntryLatitude"),
        "lng": String.localized("AuditingEntryLongitude"),
        "tags": String.localized("AuditingEntryTags"),
        "street": String.localized("AuditingEntryStreet"),
        "house_number": String.localized("AuditingEntryHouseNumber"),
        "postcode": String.localized("AuditingEntryPostcode"),
        "place": String.localized("AuditingEntryPlace"),
        "monday": String.localized("AuditingEntryMonday"),
        "tuesday": String.localized("AuditingEntryTuesday"),
        "wednesday": String.localized("AuditingEntryWednesday"),
        "thursday": String.localized("AuditingEntryThursday"),
        "friday": String.localized("AuditingEntryFriday"),
        "saturday": String.localized("AuditingEntrySaturday"),
        "sunday": String.localized("AuditingEntrySunday"),
        "other": String.localized("AuditingEntryOther"),
        "url": String.localized("AuditingEntryWebsite"),
        "phone": String.localized("AuditingEntryPhone"),
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(auditingTypeLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(changesStackView)
        self.contentView.addSubview(changeSetHeader)
        self.contentView.addSubview(auditingTypeImageView)
        
        self.auditingTypeImageView.contentMode = .scaleAspectFit
        self.auditingTypeLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        self.dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.changeSetHeader.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.changesStackView.axis = .vertical
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [
            dateLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            auditingTypeImageView.centerYAnchor.constraint(equalTo: auditingTypeLabel.centerYAnchor, constant: -1),
            auditingTypeImageView.leadingAnchor.constraint(equalTo: dateLabel.leadingAnchor),
            auditingTypeImageView.heightAnchor.constraint(equalToConstant: 16),
            auditingTypeImageView.widthAnchor.constraint(equalTo: auditingTypeImageView.heightAnchor),
            auditingTypeLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            auditingTypeLabel.leadingAnchor.constraint(equalTo: auditingTypeImageView.trailingAnchor, constant: 8),
            auditingTypeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            changeSetHeader.topAnchor.constraint(equalTo: auditingTypeLabel.bottomAnchor, constant: 8),
            changeSetHeader.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            changeSetHeader.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            changesStackView.topAnchor.constraint(equalTo: changeSetHeader.bottomAnchor, constant: 8),
            changesStackView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            changesStackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            changesStackView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    private func setupChangesStackView() {
        
        changesStackView.arrangedSubviews.forEach { changesStackView.removeArrangedSubview($0) }
        
        guard let audit = audit else { return }
        
        if audit.event == .updated {
            
            self.changeSetHeader.text = "Änderungsprotokoll:"
            
            for change in audit.newValues.baseValues {
                
                let newGenericValue = change.value
                let oldGenericValue = audit.oldValues.baseValues[change.key] ?? nil
                
                var newValueRepresentation = "n/v"
                
                if let newGenericValue = newGenericValue {
                    switch newGenericValue {
                    case .string(let value):
                        newValueRepresentation = value
                    case .double(let value):
                        newValueRepresentation = value.format(pattern: "%.2f")
                    case .integer(let value):
                        newValueRepresentation = String(value)
                    }
                }
                
                var oldValueRepresentation = "n/v"
                
                if let oldGenericValue = oldGenericValue {
                    switch oldGenericValue {
                    case .string(let value):
                        oldValueRepresentation = value
                    case .double(let value):
                        oldValueRepresentation = value.format(pattern: "%.2f")
                    case .integer(let value):
                        oldValueRepresentation = String(value)
                    }
                }
                
                let valueDescription = lookupTable[change.key] ?? change.key.uppercased(with: Locale.current)
                
                let auditChangeView = AuditChangeView(valueDescription: valueDescription,
                                                      oldValue: oldValueRepresentation,
                                                      newValue: newValueRepresentation)

                changesStackView.addArrangedSubview(auditChangeView)

            }
            
        } else {
            self.changeSetHeader.text = ""
        }
        
    }
    
}

extension AuditTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        self.changeSetHeader.textColor = theme.color
        self.auditingTypeLabel.textColor = theme.color
        self.dateLabel.textColor = theme.decentColor
    }
    
}
