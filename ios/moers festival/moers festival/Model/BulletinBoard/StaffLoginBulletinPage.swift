//
//  StaffLoginBulletinPage.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

@preconcurrency import UIKit
import BLTNBoard

nonisolated class StaffLoginBulletinPage: FeedbackPageBulletinItem {

    @objc public var textField: UITextField!

    @objc public var textInputHandler: ((BLTNActionItem, String?) -> Void)? = nil

    nonisolated override init(title: String) {
        super.init(title: title)
    }

    nonisolated override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {

        textField = interfaceBuilder.makeTextField(placeholder: "", returnKey: .done, delegate: self)
        textField.keyboardAppearance = .dark
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2

        self.textField.layer.borderColor = UIColor.systemYellow.cgColor
        self.textField.backgroundColor = UIColor.systemBackground
        self.textField.tintColor = UIColor.systemYellow
        self.textField.textColor = UIColor.label

        return [textField]

    }

    nonisolated override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        return nil
    }

    nonisolated override func tearDown() {
        super.tearDown()
        textField?.delegate = nil
    }

    nonisolated override func actionButtonTapped(sender: UIButton) {
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
