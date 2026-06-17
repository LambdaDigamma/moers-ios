//
//  SelectorBulletinPage.swift
//  Moers
//
//  Created by Lennart Fischer on 10.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Core

class SelectorBulletinPage<
    T: RawRepresentable & CaseIterable & Equatable & CaseName
>: FeedbackPageBulletinItem where T.RawValue == String {

    public var onSelect: ((T) -> Void)?
    public var selectedOption: T = T.allCases.first!
    
    private var buttons: [UIButton] = []
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()
    
    init(title: String, preSelected: T?) {
        super.init(title: title)
        
        if let preSelected = preSelected {
            
            self.selectedOption = preSelected
            
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
        
        buttons.forEach { $0.removeTarget(self, action: nil, for: .touchUpInside) }
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        let optionStack = interfaceBuilder.makeGroupStack(spacing: 16)
        
        T.allCases.forEach { (value) in
            
            let button = createOptionCell(title: value.name)
            
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
        
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = title
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.addTarget(self, action: #selector(selectedOption(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(generateFeedback), for: .touchUpInside)
        
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        return button
        
    }
    
    private func applyOptionAppearance(to button: UIButton, isSelected: Bool) {

        if isSelected {
            button.accessibilityTraits.insert(.selected)
        } else {
            button.accessibilityTraits.remove(.selected)
        }

        button.isSelected = false

        if #available(iOS 26, *) {
            applyClearGlassOptionAppearance(to: button, isSelected: isSelected)
        } else {
            applyBorderedOptionAppearance(to: button, isSelected: isSelected)
        }

    }

    @available(iOS 26, *)
    private func applyClearGlassOptionAppearance(to button: UIButton, isSelected: Bool) {

        var configuration = UIButton.Configuration.clearGlass()
        configuration.title = button.accessibilityLabel
        configuration.buttonSize = .large
        configuration.cornerStyle = .capsule
        configuration.titleAlignment = .center
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        configuration.baseForegroundColor = isSelected ? appearance.actionButtonColor : .label
        configuration.automaticallyUpdateForSelection = false

        var background = configuration.background
        background.strokeColor = isSelected ? appearance.actionButtonColor : .tertiaryLabel
        background.strokeWidth = isSelected ? 2 : 1
        configuration.background = background

        let font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var updated = container
            updated.font = font
            return updated
        }

        UIView.transition(with: button, duration: 0.18, options: [.transitionCrossDissolve, .allowUserInteraction]) {
            button.backgroundColor = .clear
            button.layer.borderWidth = 0
            button.configuration = configuration
        }

    }

    private func applyBorderedOptionAppearance(to button: UIButton, isSelected: Bool) {

        let color = isSelected ? appearance.actionButtonColor : UIColor.tertiaryLabel
        let titleColor = isSelected ? appearance.actionButtonColor : UIColor.secondaryLabel

        button.configuration = nil
        button.setTitle(button.accessibilityLabel, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(titleColor, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 27.5
        button.layer.cornerCurve = .continuous
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = isSelected ? 2 : 1

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
        
        applyOptionAppearance(to: button, isSelected: true)
        
    }
    
    private func resetButtonSelections() {
        
        buttons.forEach { (button: UIButton) in
            applyOptionAppearance(to: button, isSelected: false)
        }
        
    }
    
}
