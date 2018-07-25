//
//  LoginViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import BetterSegmentedControl
import TextFieldEffects

class LoginViewController: UIViewController {

    lazy var typeLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.bold)
        label.text = "Login"
        label.textAlignment = .center
        
        return label
        
    }()
    
    lazy var typeSwitch: BetterSegmentedControl = {
        
        let typeSwitch = BetterSegmentedControl(frame: .zero, titles: ["Login", "Sign Up"], index: 0, options: nil)
        
        typeSwitch.translatesAutoresizingMaskIntoConstraints = false
        typeSwitch.addTarget(self, action: #selector(switchedType(control:)), for: .valueChanged)
        
        return typeSwitch
        
    }()
    
    lazy var infoLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Werde Teil der Community und bekomme Zugriff auf erweiterte Funktionen!"
        
        return label
        
    }()
    
    lazy var emailTextField: HoshiTextField = {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(didEndEditingEmailTextField(textField:)), for: .editingDidEnd)
        
        return textField
        
    }()
    
    lazy var passwordTextField: HoshiTextField = {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(didEndEditingPasswordTextField(textField:)), for: .editingDidEnd)
        
        return textField
        
    }()
    
    lazy var actionButton: UIButton = {
        
        let button = UIButton(type: UIButtonType.custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOGIN", for: .normal)
        button.layer.cornerRadius = 50 / 2
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        button.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        return button
        
    }()
    
    lazy var closeButton: UIButton = {
        
        let button = UIButton(type: UIButtonType.custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return button
        
    }()
    
    private var enabledColor: UIColor?
    private var disabledColor: UIColor?
    
    private var actionButtonEnabled: Bool = false {
        didSet {
            if actionButtonEnabled {
                actionButton.isEnabled = true
                actionButton.setBackgroundColor(color: enabledColor ?? UIColor.clear, forState: .normal)
            } else {
                actionButton.isEnabled = false
                actionButton.setBackgroundColor(color: disabledColor ?? UIColor.clear, forState: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(closeButton)
        self.view.addSubview(typeLabel)
        self.view.addSubview(typeSwitch)
        self.view.addSubview(infoLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(actionButton)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.actionButtonEnabled = false
        
    }
    
    @objc private func switchedType(control: BetterSegmentedControl) {
        
        if control.index == 0 {
            typeLabel.text = "Login"
            actionButton.setTitle("LOGIN", for: .normal)
        } else {
            typeLabel.text = "Sign Up"
            actionButton.setTitle("SIGN UP", for: .normal)
        }
        
    }
    
    @objc private func close() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func didEndEditingEmailTextField(textField: HoshiTextField) {
        self.validateInputs()
    }
    
    @objc private func didEndEditingPasswordTextField(textField: HoshiTextField) {
        self.validateInputs()
    }
    
    @objc private func login() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        API.shared.login(email: email, password: password) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            API.shared.getUser { (error, user) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let user = user else { return }
                
                UserManager.shared.register(user)
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [closeButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 8),
                           closeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           closeButton.widthAnchor.constraint(equalToConstant: 20),
                           closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
                           typeLabel.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 40),
                           typeLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           typeLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           typeSwitch.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 32),
                           typeSwitch.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           typeSwitch.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           typeSwitch.heightAnchor.constraint(equalToConstant: 50),
                           infoLabel.topAnchor.constraint(equalTo: typeSwitch.bottomAnchor, constant: 16),
                           infoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           infoLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           emailTextField.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 32),
                           emailTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           emailTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           emailTextField.heightAnchor.constraint(equalToConstant: 55),
                           passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 8),
                           passwordTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           passwordTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           passwordTextField.heightAnchor.constraint(equalToConstant: 55),
                           actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
                           actionButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           actionButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           actionButton.heightAnchor.constraint(equalToConstant: 50)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.enabledColor = theme.accentColor
            themeable.disabledColor = theme.accentColor.darker(by: 10)
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.typeLabel.textColor = theme.color
            themeable.closeButton.setImage(#imageLiteral(resourceName: "cancel").tinted(color: theme.decentColor), for: .normal)
            themeable.infoLabel.textColor = theme.color
            themeable.emailTextField.placeholderColor = theme.decentColor
            themeable.emailTextField.borderActiveColor = theme.accentColor
            themeable.emailTextField.borderInactiveColor = theme.decentColor
            themeable.emailTextField.tintColor = theme.accentColor
            themeable.emailTextField.textColor = theme.color
            themeable.emailTextField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            themeable.passwordTextField.placeholderColor = theme.decentColor
            themeable.passwordTextField.borderActiveColor = theme.accentColor
            themeable.passwordTextField.borderInactiveColor = theme.decentColor
            themeable.passwordTextField.tintColor = theme.accentColor
            themeable.passwordTextField.textColor = theme.color
            themeable.passwordTextField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            
            themeable.typeSwitch.options = [.backgroundColor(theme.backgroundColor.darker(by: 5)!),
                                            .bouncesOnChange(true),
                                            .cornerRadius(25),
                                            .selectedTitleColor(theme.backgroundColor.darker(by: 5)!),
                                            .indicatorViewBackgroundColor(theme.decentColor),
                                            .titleColor(theme.color)]
            
            themeable.actionButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.actionButton.setBackgroundColor(color: theme.accentColor.darker(by: 20)!, forState: .highlighted)
            themeable.actionButton.setTitleColor(theme.backgroundColor, for: .normal)
            
        }
        
    }
    
    private func validateInputs() {
        
        if emailTextField.text != nil {
            emailTextField.borderInactiveColor = UIColor.red
            actionButtonEnabled = false
        }
        
        if passwordTextField.text != nil {
            passwordTextField.borderInactiveColor = UIColor.red
            actionButtonEnabled = false
        }
        
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if isValidEmail(email) {
            emailTextField.borderInactiveColor = UIColor.green
        }
        
        if isValidPassword(password) {
            passwordTextField.borderInactiveColor = UIColor.green
        }
        
        if isValidEmail(email) && isValidPassword(password) {
            actionButtonEnabled = true
        }
        
    }

    func isValidEmail(_ email: String) -> Bool {
        
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        
        return pred.evaluate(with: email)
        
    }
    
    func isValidPassword(_ password: String) -> Bool {
        
        return password.count >= 6
        
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
