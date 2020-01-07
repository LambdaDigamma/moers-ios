//
//  TextFieldFormRow.swift
//  Moers
//
//  Created by Lennart Fischer on 04.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import TextFieldEffects
import MMUI
import Gestalt

class TextFieldFormView: UIView, FormView {
    
    public private(set) lazy var textField: HoshiTextField = { ViewFactory.textField() }()
    private lazy var errorStackView: UIStackView = { ViewFactory.stackView() }()
    
    var isEnabled: Bool {
        set {
            textField.isEnabled = newValue
        }
        get {
            return textField.isEnabled
        }
    }
    var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }
    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var textFieldDelegate: UITextFieldDelegate? = nil {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }
    var textColor: UIColor? {
        set {
            textField.textColor = newValue
        }
        get {
            return textField.textColor
        }
    }
    
    private var errors: [String] = []
    
    public init() {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.addSubview(textField)
        self.addSubview(errorStackView)
        
        self.errorStackView.distribution = .fillProportionally
        
        
        self.textField.reactive.text.receive(on: DispatchQueue.main).observeNext { (_) in
            if !self.errors.isEmpty {
                self.displayErrors([])
                print("Changes")
            }
        }.dispose(in: bag)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 55),
            errorStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            errorStackView.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            errorStackView.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            errorStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // MARK: - Data Handling
    
    func displayErrors(_ errors: [String]) {
        
        self.errors = errors
        
        print(errorStackView.arrangedSubviews.count)
        errorStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        errorStackView.layoutIfNeeded()
        
        textField.borderInactiveColor = UIColor(hexString: "FF0000")
        
        for error in errors {
            
            let label = ViewFactory.label()
            label.text = error
            label.textColor = UIColor(hexString: "FF0000")
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            errorStackView.addArrangedSubview(label)
            
        }
        
    }
    
    func currentData() -> Codable {
        return textField.text ?? ""
    }
    
}

extension TextFieldFormView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        let applyTheming: ((HoshiTextField) -> Void) = { textField in
            
            if textField.isEnabled {
                textField.borderActiveColor = theme.accentColor
            } else {
                textField.borderActiveColor = theme.decentColor
            }
            
            textField.borderInactiveColor = theme.decentColor
            textField.placeholderColor = theme.color
            textField.textColor = theme.color.darker(by: 10)
            textField.tintColor = theme.accentColor
            textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            textField.autocorrectionType = .no
            
        }
        
        self.backgroundColor = theme.backgroundColor
        
        applyTheming(textField)
        
    }
    
}
