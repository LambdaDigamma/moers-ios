//
//  SelectorBulletinPage.swift
//  Moers
//
//  Created by Lennart Fischer on 10.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt

class SelectorBulletinPage<T: RawRepresentable & EnumCollection & Localizable>: FeedbackPageBulletinItem where T.RawValue == String {

    public var onSelect: ((T) -> Void)?
    public var selectedOption: T = T.allValues.first!
    
    private var buttons: [UIButton] = []
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()
    
    override func tearDown() {
        super.tearDown()
        
        buttons.forEach { $0.removeTarget(self, action: nil, for: .touchUpInside) }
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        let optionStack = interfaceBuilder.makeGroupStack(spacing: 16)
        
        T.allValues.forEach { (value) in
            
            let button = createOptionCell(title: T.localizedForCase(value))
            
            optionStack.addArrangedSubview(button)
            buttons.append(button)
            
        }
        
        self.resetButtonSelections()
        
        if let button = self.buttons.first {
            self.setButtonSelection(button)
            self.selectedOption(button)
        }
        
        return [optionStack]
        
    }
    
    private func createOptionCell(title: String) -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = title
        button.accessibilityTraits &= ~UIAccessibilityTraitSelected
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(selectedOption(_:)), for: .touchUpInside)
        
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        return button
        
    }
    
    @objc private func selectedOption(_ button: UIButton) {
        
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        
        let index = self.buttons.index(of: button) ?? 0
        
        let option = T.allValues[index]
        
        self.selectedOption = option
        self.onSelect?(option)
        
        self.resetButtonSelections()
        self.setButtonSelection(button)
        
    }
    
    private func setButtonSelection(_ button: UIButton) {
        
        ThemeManager.default.apply(theme: Theme.self, to: button) { (themeable, theme) in
            
            let accentColor = theme.accentColor
            
            themeable.layer.borderColor = accentColor.cgColor
            themeable.setTitleColor(accentColor, for: .normal)
            themeable.accessibilityTraits |= UIAccessibilityTraitSelected
            
        }
        
    }
    
    private func resetButtonSelections() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.buttons.forEach({ (button) in
                
                let decentColor = theme.decentColor
                
                button.layer.borderColor = decentColor.cgColor
                button.setTitleColor(decentColor, for: .normal)
                button.accessibilityTraits &= ~UIAccessibilityTraitSelected
                
            })
            
        }
        
    }
    
}
