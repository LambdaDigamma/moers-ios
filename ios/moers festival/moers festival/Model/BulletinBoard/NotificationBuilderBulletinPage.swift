//
//  NotificationBuilderPage.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import BLTNBoard

class NotificationBuilderBulletinPage: FeedbackPageBulletinItem {
    
    @objc public var titleTextField: UITextField!
    @objc public var bodyTextField: UITextField!
    
    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        titleTextField = interfaceBuilder.makeTextField(placeholder: "Titel", returnKey: .next, delegate: self)
        titleTextField.keyboardAppearance = .dark
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        titleTextField.layer.cornerRadius = 12
        titleTextField.layer.borderWidth = 2
        
        bodyTextField = interfaceBuilder.makeTextField(placeholder: "Text", returnKey: .done, delegate: self)
        bodyTextField.keyboardAppearance = .dark
        bodyTextField.translatesAutoresizingMaskIntoConstraints = false
        bodyTextField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        bodyTextField.layer.cornerRadius = 12
        bodyTextField.layer.borderWidth = 2
        
        self.titleTextField.layer.borderColor = AppColors.navigationAccent.cgColor
        self.titleTextField.backgroundColor = UIColor.systemBackground
        self.titleTextField.tintColor = AppColors.navigationAccent
        self.titleTextField.textColor = UIColor.label
        self.titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Titel",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
        
        self.bodyTextField.layer.borderColor = AppColors.navigationAccent.cgColor
        self.bodyTextField.backgroundColor = UIColor.systemBackground
        self.bodyTextField.tintColor = AppColors.navigationAccent
        self.bodyTextField.textColor = UIColor.label
        self.bodyTextField.attributedPlaceholder = NSAttributedString(
            string: "Text",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholderText]
        )
        
        return [titleTextField, bodyTextField]
        
    }
    
    override func tearDown() {
        super.tearDown()
        titleTextField?.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        
        if titleTextField.text != "" {
            
            super.actionButtonTapped(sender: sender)
            
        }
        
    }
    
}

extension NotificationBuilderBulletinPage: UITextFieldDelegate {
    
    @objc open func isInputValid(text: String?) -> Bool {
        
        if text == nil || text!.isEmpty {
            return false
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if titleTextField.text != "" {
            
            textField.resignFirstResponder()
            
            return true
            
        } else {
            return false
        }
        
    }
    
}
