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
import MMCommon
import Core

class SelectorBulletinPage<
    T: RawRepresentable & CaseIterable & Equatable & CaseName
>: FeedbackPageBulletinItem where T.RawValue == String {

    public var onSelect: ((T) -> Void)?
    public var selectedOption: T = T.allCases.first!
    
    private var buttons: [UIButton] = []
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()
    
    var accentColor: UIColor?
    var decentColor: UIColor?
    
    init(title: String, preSelected: T?) {
        super.init(title: title)
        
        if let preSelected = preSelected {
            
            self.selectedOption = preSelected
            
        }
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        buttons.forEach { $0.removeTarget(self, action: nil, for: .touchUpInside) }
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        let optionStack = interfaceBuilder.makeGroupStack(spacing: 16)
        
        T.allCases.forEach { (value) in
            
            let button = createOptionCell(title: value.name)
            
//            if value == selectedOption {
//                self.setButtonSelection(button)
//                self.selectedOption(button)
//            }
            
            optionStack.addArrangedSubview(button)
            buttons.append(button)
            
        }
        
        self.resetButtonSelections()
        
        let index = Array(T.allCases).firstIndex(of: selectedOption) ?? 0
        
        self.setButtonSelection(buttons[index])
        self.selectedOption(buttons[index])
        
        return [optionStack]
        
    }
    
    private func createOptionCell(title: String) -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = title
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(selectedOption(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(generateFeedback), for: .touchUpInside)
        
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        return button
        
    }
    
    @objc private func selectedOption(_ button: UIButton) {
        
        let index = self.buttons.firstIndex(of: button) ?? 0
        
        let option = Array(T.allCases)[index]
        
        self.selectedOption = option
        self.onSelect?(option)
        
        self.resetButtonSelections()
        self.setButtonSelection(button)
        
    }
    
    @objc private func generateFeedback() {
        
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
        
    }
    
    private func setButtonSelection(_ button: UIButton) {
        
        button.layer.borderColor = accentColor?.cgColor
        button.setTitleColor(accentColor, for: .normal)
        
    }
    
    private func resetButtonSelections() {
        
        buttons.forEach { (button: UIButton) in
            button.layer.borderColor = decentColor?.cgColor
            button.setTitleColor(decentColor, for: .normal)
        }
        
    }
    
}

extension SelectorBulletinPage: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.accentColor = theme.accentColor
        self.decentColor = theme.decentColor
    }
    
}
