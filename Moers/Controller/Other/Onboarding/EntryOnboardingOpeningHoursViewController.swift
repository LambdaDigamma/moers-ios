//
//  EntryOnboardingOpeningHoursViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TextFieldEffects

class EntryOnboardingOpeningHoursViewController: UIViewController {

    lazy var scrollView = { ViewFactory.scrollView() }()
    lazy var contentView = { ViewFactory.blankView() }()
    lazy var progressView = { ViewFactory.onboardingProgressView() }()
    lazy var openingHoursHeaderLabel = { ViewFactory.label() }()
    lazy var openingHoursStackView = { ViewFactory.stackView() }()
    lazy var mondayOHTextField = { ViewFactory.textField() }()
    lazy var tuesdayOHTextField = { ViewFactory.textField() }()
    lazy var wednesdayOHTextField = { ViewFactory.textField() }()
    lazy var thursdayOHTextField = { ViewFactory.textField() }()
    lazy var fridayOHTextField = { ViewFactory.textField() }()
    lazy var saturdayOHTextField = { ViewFactory.textField() }()
    lazy var sundayOHTextField = { ViewFactory.textField() }()
    lazy var otherOHTextField = { ViewFactory.textField() }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupOpeningHours()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        progressView.progress = 0.8
        
        mondayOHTextField.text = EntryManager.shared.entryMondayOH
        tuesdayOHTextField.text = EntryManager.shared.entryTuesdayOH
        wednesdayOHTextField.text = EntryManager.shared.entryWednesdayOH
        thursdayOHTextField.text = EntryManager.shared.entryThursdayOH
        fridayOHTextField.text = EntryManager.shared.entryFridayOH
        saturdayOHTextField.text = EntryManager.shared.entrySaturdayOH
        sundayOHTextField.text = EntryManager.shared.entrySundayOH
        otherOHTextField.text = EntryManager.shared.entryOtherOH
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Eintrag hinzufügen"
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(progressView)
        self.contentView.addSubview(openingHoursHeaderLabel)
        self.contentView.addSubview(openingHoursStackView)
        
        self.openingHoursHeaderLabel.text = "ÖFFNUNGSZEITEN (optional)"
        self.mondayOHTextField.placeholder = "Montag"
        self.tuesdayOHTextField.placeholder = "Dienstag"
        self.wednesdayOHTextField.placeholder = "Mittwoch"
        self.thursdayOHTextField.placeholder = "Donnerstag"
        self.fridayOHTextField.placeholder = "Freitag"
        self.saturdayOHTextField.placeholder = "Samstag"
        self.sundayOHTextField.placeholder = "Sonntag"
        self.otherOHTextField.placeholder = "Sonstiges"
        
        self.mondayOHTextField.delegate = self
        self.tuesdayOHTextField.delegate = self
        self.wednesdayOHTextField.delegate = self
        self.thursdayOHTextField.delegate = self
        self.fridayOHTextField.delegate = self
        self.saturdayOHTextField.delegate = self
        self.sundayOHTextField.delegate = self
        self.otherOHTextField.delegate = self
        
        self.openingHoursHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        
        self.progressView.currentStep = "5. Öffnungszeiten eingeben"
        self.progressView.progress = 0.6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Weiter", style: .plain, target: self, action: #selector(continueOnboarding))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0),
                           contentView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
                           contentView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
                           contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                           contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                           contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           progressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                           progressView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           progressView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           openingHoursHeaderLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           openingHoursHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           openingHoursHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           mondayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           tuesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           wednesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           thursdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           fridayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           saturdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           sundayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           otherOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           openingHoursStackView.topAnchor.constraint(equalTo: openingHoursHeaderLabel.bottomAnchor, constant: 0),
                           openingHoursStackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           openingHoursStackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           openingHoursStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            let applyTheming: ((HoshiTextField) -> Void) = { textField in
                
                textField.borderActiveColor = theme.accentColor
                textField.borderInactiveColor = theme.decentColor
                textField.placeholderColor = theme.color
                textField.textColor = theme.color
                textField.tintColor = theme.accentColor
                textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
                textField.autocorrectionType = .no
                
            }
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.openingHoursHeaderLabel.textColor = theme.color
            themeable.progressView.accentColor = theme.accentColor
            themeable.progressView.decentColor = theme.decentColor
            themeable.progressView.textColor = theme.color
            
            applyTheming(themeable.mondayOHTextField)
            applyTheming(themeable.tuesdayOHTextField)
            applyTheming(themeable.wednesdayOHTextField)
            applyTheming(themeable.thursdayOHTextField)
            applyTheming(themeable.fridayOHTextField)
            applyTheming(themeable.saturdayOHTextField)
            applyTheming(themeable.sundayOHTextField)
            applyTheming(themeable.otherOHTextField)
            
        }
        
    }

    private func setupOpeningHours() {
        
        let columnStackView: ((HoshiTextField, HoshiTextField) -> UIStackView) = { textField1, textField2 in
            
            let stackView = UIStackView()
            
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            
            stackView.addArrangedSubview(textField1)
            stackView.addArrangedSubview(textField2)
            
            return stackView
            
        }
        
        openingHoursStackView.alignment = .fill
        openingHoursStackView.axis = .vertical
        openingHoursStackView.distribution = .fillEqually
        openingHoursStackView.spacing = 8
        
        openingHoursStackView.addArrangedSubview(columnStackView(mondayOHTextField, tuesdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(wednesdayOHTextField, thursdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(fridayOHTextField, saturdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(sundayOHTextField, otherOHTextField))
        
    }
    
    // MARK: - Helper
    
    @objc private func adjustForKeyboard(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    @objc private func continueOnboarding() {
        
        EntryManager.shared.entryMondayOH = mondayOHTextField.text
        EntryManager.shared.entryTuesdayOH = tuesdayOHTextField.text
        EntryManager.shared.entryWednesdayOH = wednesdayOHTextField.text
        EntryManager.shared.entryThursdayOH = thursdayOHTextField.text
        EntryManager.shared.entryFridayOH = fridayOHTextField.text
        EntryManager.shared.entrySaturdayOH = saturdayOHTextField.text
        EntryManager.shared.entrySundayOH = sundayOHTextField.text
        EntryManager.shared.entryOtherOH = otherOHTextField.text
        
        let viewController = EntryOnboardingOverviewViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension EntryOnboardingOpeningHoursViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let textField = textField as? HoshiTextField else { return }
        
        textField.setValidInput(!(textField.text ?? "").isEmpty)
        
    }
    
}
