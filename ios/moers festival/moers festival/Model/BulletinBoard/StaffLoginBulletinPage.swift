//
//  StaffLoginBulletinPage.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import BLTNBoard

class StaffLoginBulletinPage: FeedbackPageBulletinItem {

    @objc public var textField: UITextField!
    
    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil
    
    override init(title: String) {
        super.init(title: title)
        
    }
    
    override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        textField = interfaceBuilder.makeTextField(placeholder: "", returnKey: .done, delegate: self)
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2
        
        self.textField.layer.borderColor = AppColors.navigationAccent.cgColor
        self.textField.backgroundColor = UIColor.systemBackground
        self.textField.tintColor = AppColors.navigationAccent
        self.textField.textColor = UIColor.label
        
        return [textField]
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        return nil
    }
    
    override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        textField.resignFirstResponder()
        super.actionButtonTapped(sender: sender)
    }
    
}

extension StaffLoginBulletinPage: UITextFieldDelegate {
    
    @objc open func isInputValid(text: String?) -> Bool {
        
        if text == nil || text!.isEmpty {
            return false
        }
        
        return true
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if isInputValid(text: textField.text) {
            textInputHandler?(self, textField.text)
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "You must enter some text to continue."
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        }
        
    }
    
}
