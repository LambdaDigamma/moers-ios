//
//  UserTypeSelectorBulletinPage.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt

class UserTypeSelectorBulletinPage: FeedbackPageBulletinItem {
    
    private var touristButton: UIButton!
    private var citizenButton: UIButton!
    
    public var selectedType: User.UserType = .tourist
    
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()
    
    override func tearDown() {
        touristButton?.removeTarget(self, action: nil, for: .touchUpInside)
        citizenButton?.removeTarget(self, action: nil, for: .touchUpInside)
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        let optionStack = interfaceBuilder.makeGroupStack(spacing: 16)
        
        touristButton = createOptionCell(title: String.localized("Tourist"), isSelected: true)
        touristButton.addTarget(self, action: #selector(selectedTourist), for: .touchUpInside)
        
        citizenButton = createOptionCell(title: String.localized("Citizen"), isSelected: false)
        citizenButton.addTarget(self, action: #selector(selectedCitizen), for: .touchUpInside)
        
        optionStack.addArrangedSubview(touristButton)
        optionStack.addArrangedSubview(citizenButton)
        
        return [optionStack]
        
    }
    
    private func createOptionCell(title: String, isSelected: Bool) -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = title
        
        if isSelected {
            button.accessibilityTraits |= UIAccessibilityTraitSelected
        } else {
            button.accessibilityTraits &= ~UIAccessibilityTraitSelected
        }
        
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        ThemeManager.default.apply(theme: Theme.self, to: button) { (themeable, theme) in
            
            let buttonColor = isSelected ? theme.accentColor : theme.decentColor
            
            themeable.layer.borderColor = buttonColor.cgColor
            themeable.setTitleColor(buttonColor, for: .normal)
            
        }
        
        return button
        
    }
    
    @objc private func selectedTourist() {
        
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        
        ThemeManager.default.apply(theme: Theme.self, to: touristButton) { (themeable, theme) in
            
            let touristButtonColor = theme.accentColor
            themeable.layer.borderColor = touristButtonColor.cgColor
            themeable.setTitleColor(touristButtonColor, for: .normal)
            themeable.accessibilityTraits |= UIAccessibilityTraitSelected
            
        }
        
        ThemeManager.default.apply(theme: Theme.self, to: citizenButton) { (themeable, theme) in
            
            let citizenButtonColor = theme.decentColor
            themeable.layer.borderColor = citizenButtonColor.cgColor
            themeable.setTitleColor(citizenButtonColor, for: .normal)
            themeable.accessibilityTraits |= UIAccessibilityTraitSelected
            
        }
        
        selectedType = .tourist
        
        register()
        
    }
    
    @objc private func selectedCitizen() {
        
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        
        ThemeManager.default.apply(theme: Theme.self, to: touristButton) { (themeable, theme) in
            
            let touristButtonColor = theme.decentColor
            themeable.layer.borderColor = touristButtonColor.cgColor
            themeable.setTitleColor(touristButtonColor, for: .normal)
            themeable.accessibilityTraits |= UIAccessibilityTraitSelected
            
        }
        
        ThemeManager.default.apply(theme: Theme.self, to: citizenButton) { (themeable, theme) in
            
            let citizenButtonColor = theme.accentColor
            themeable.layer.borderColor = citizenButtonColor.cgColor
            themeable.setTitleColor(citizenButtonColor, for: .normal)
            themeable.accessibilityTraits |= UIAccessibilityTraitSelected
            
        }
        
        selectedType = .citizen
        
        register()
        
    }
    
    private func register() {
        
        let user = User(type: selectedType, id: nil, name: nil, description: nil)
        
        UserManager.shared.register(user)
        
    }
    
    override func actionButtonTapped(sender: UIButton) {
        
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        
        manager?.displayNextItem()
        
    }
    
}
