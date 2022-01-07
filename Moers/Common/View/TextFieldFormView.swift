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
import Combine

class TextFieldFormView: UIView, FormView {
    
    public private(set) lazy var textField: HoshiTextField = { ViewFactory.textField() }()
    private lazy var errorStackView: UIStackView = { ViewFactory.stackView() }()
    private var cancellables = Set<AnyCancellable>()
    
    var isEnabled: Bool {
        get {
            return textField.isEnabled
        }
        set {
            textField.isEnabled = newValue
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var textFieldDelegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = textFieldDelegate
        }
    }
    
    var textColor: UIColor? {
        get {
            return textField.textColor
        }
        set {
            textField.textColor = newValue
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
        
        self.textField.publisher(for: \.text)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                if !self.errors.isEmpty {
                    self.displayErrors([])
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
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
