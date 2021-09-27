//
//  ShortcutsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 04.01.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import IntentsUI
import MMUI

class ShortcutsViewController: UIViewController {

    lazy var intentStackView = { ViewFactory.stackView() }()
    
    private var textColor: UIColor = .black
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Siri Shortcuts"
        
        if #available(iOS 12.0, *) {
        
            self.setupTheming()
            self.setupUI()
            self.setupConstraints()
            
        }
            
    }
    
    // MARK: - Private Methods
    
    @available(iOS 12.0, *)
    private func setupUI() {
        
        self.view.addSubview(intentStackView)
        
        intentStackView.axis = .vertical
        intentStackView.distribution = .fillEqually
        intentStackView.spacing = 8
        
        let activity = UserManager.shared.nextRubbishActivity()
        let shortcut = INShortcut(userActivity: activity)
        
        let firstStack = makeIntentStack(name: "Abfall", shortcut: shortcut)
        
        intentStackView.addArrangedSubview(firstStack)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [intentStackView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           intentStackView.leadingAnchor.constraint(equalTo: self.safeLeftAnchor, constant: 16),
                           intentStackView.trailingAnchor.constraint(equalTo: self.safeRightAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }

    @available(iOS 12.0, *)
    private func makeIntentStack(name: String, shortcut: INShortcut) -> UIStackView {
        
        let stackView = ViewFactory.stackView()
        let label = ViewFactory.label()
        let button = INUIAddVoiceShortcutButton(style: .blackOutline)
        
        label.text = name
        label.textColor = self.textColor
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        button.shortcut = shortcut
        button.delegate = self
        
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.insertArrangedSubview(label, at: 0)
        stackView.insertArrangedSubview(button, at: 1)
        
        return stackView
        
    }
    
}

@available(iOS 12.0, *)
extension ShortcutsViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
    
}

@available(iOS 12.0, *)
extension ShortcutsViewController: INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ShortcutsViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.textColor = theme.color
    }
    
}
