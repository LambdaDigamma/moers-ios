//
//  EntryOnboardingGeneralViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

#if canImport(UIKit)

import Core
import UIKit

import TextFieldEffects

class EntryOnboardingGeneralViewController: UIViewController {

    lazy var scrollView = { CoreViewFactory.scrollView() }()
    lazy var contentView = { CoreViewFactory.blankView() }()
    lazy var progressView = { CoreViewFactory.onboardingProgressView() }()
    lazy var generalHeaderLabel = { CoreViewFactory.label() }()
    lazy var nameTextField = { CoreViewFactory.textField() }()
    lazy var contactHeaderLabel = { CoreViewFactory.label() }()
    lazy var websiteTextField = { CoreViewFactory.textField() }()
    lazy var phoneTextField = { CoreViewFactory.textField() }()
    
    private var entryManager: EntryManagerProtocol
    
    init(entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.progressView.progress = 0.4
        
        self.nameTextField.text = entryManager.entryName
        self.phoneTextField.text = entryManager.entryPhone
        self.websiteTextField.text = entryManager.entryWebsite
        
        self.checkDataInput()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = String(localized: "Add entry", bundle: .module)
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(progressView)
        self.contentView.addSubview(generalHeaderLabel)
        self.contentView.addSubview(nameTextField)
        self.contentView.addSubview(contactHeaderLabel)
        self.contentView.addSubview(websiteTextField)
        self.contentView.addSubview(phoneTextField)
        
        self.progressView.currentStep = String(localized: "3. General & Contact", bundle: .module)
        self.progressView.progress = 0.2
        
        self.generalHeaderLabel.text = String(localized: "General", bundle: .module).uppercased()
        self.contactHeaderLabel.text = String(localized: "Contact (optional)", bundle: .module).uppercased()
        self.nameTextField.placeholder = String(localized: "Name", bundle: .module)
        self.websiteTextField.placeholder = String(localized: "Website", bundle: .module)
        self.phoneTextField.placeholder = String(localized: "Phone", bundle: .module)
        self.nameTextField.delegate = self
        self.websiteTextField.delegate = self
        self.phoneTextField.delegate = self
        
        self.generalHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.contactHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        
        self.nameTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        self.websiteTextField.autocapitalizationType = .none
        self.websiteTextField.keyboardType = .URL
        self.phoneTextField.keyboardType = .phonePad
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0),
                           contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
                           contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
                           contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                           contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                           contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           progressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                           progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           generalHeaderLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           generalHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           generalHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           nameTextField.topAnchor.constraint(equalTo: generalHeaderLabel.bottomAnchor, constant: 0),
                           nameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           nameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           nameTextField.heightAnchor.constraint(equalToConstant: 55),
                           contactHeaderLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 24),
                           contactHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           contactHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           websiteTextField.topAnchor.constraint(equalTo: contactHeaderLabel.bottomAnchor, constant: 0),
                           websiteTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           websiteTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           websiteTextField.heightAnchor.constraint(equalToConstant: 55),
                           phoneTextField.topAnchor.constraint(equalTo: websiteTextField.bottomAnchor, constant: 4),
                           phoneTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           phoneTextField.heightAnchor.constraint(equalToConstant: 55),
                           phoneTextField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -50)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
    }
    
    // MARK: - Helper
    
    @objc private func adjustForKeyboard(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let value = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = value.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    @objc private func textChanged(_ textField: UITextField) {
        
        checkDataInput()
        
    }
    
    private func invalidateUI() {
        
        self.navigationItem.rightBarButtonItem = nil
        
    }
    
    private func checkDataInput() {
        
        if nameTextField.text != "" {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Next", bundle: .module),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(self.continueOnboarding))
            
        } else {
            
            self.invalidateUI()
            
        }
        
    }
    
    @objc private func continueOnboarding() {
        
        entryManager.entryName = nameTextField.text
        entryManager.entryWebsite = websiteTextField.text
        entryManager.entryPhone = phoneTextField.text
        
        let viewController = EntryOnboardingTagsViewController(entryManager: entryManager)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension EntryOnboardingGeneralViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let textField = textField as? HoshiTextField else { return }
        
        textField.setValidInput(!(textField.text ?? "").isEmpty)
        
    }
    
}

#endif
