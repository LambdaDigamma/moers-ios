//
//  EntryOnboardingOpeningHoursViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import Gestalt
import TextFieldEffects

class EntryOnboardingOpeningHoursViewController: UIViewController {

    lazy var scrollView = { CoreViewFactory.scrollView() }()
    lazy var contentView = { CoreViewFactory.blankView() }()
    lazy var progressView = { CoreViewFactory.onboardingProgressView() }()
    lazy var openingHoursHeaderLabel = { CoreViewFactory.label() }()
    lazy var openingHoursStackView = { CoreViewFactory.stackView() }()
    lazy var mondayOHTextField = { CoreViewFactory.textField() }()
    lazy var tuesdayOHTextField = { CoreViewFactory.textField() }()
    lazy var wednesdayOHTextField = { CoreViewFactory.textField() }()
    lazy var thursdayOHTextField = { CoreViewFactory.textField() }()
    lazy var fridayOHTextField = { CoreViewFactory.textField() }()
    lazy var saturdayOHTextField = { CoreViewFactory.textField() }()
    lazy var sundayOHTextField = { CoreViewFactory.textField() }()
    lazy var otherOHTextField = { CoreViewFactory.textField() }()
    lazy var openingHoursInfoLabel = { CoreViewFactory.label() }()
    
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
        self.setupOpeningHours()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        progressView.progress = 0.8
        
        mondayOHTextField.text = entryManager.entryMondayOH
        tuesdayOHTextField.text = entryManager.entryTuesdayOH
        wednesdayOHTextField.text = entryManager.entryWednesdayOH
        thursdayOHTextField.text = entryManager.entryThursdayOH
        fridayOHTextField.text = entryManager.entryFridayOH
        saturdayOHTextField.text = entryManager.entrySaturdayOH
        sundayOHTextField.text = entryManager.entrySundayOH
        otherOHTextField.text = entryManager.entryOtherOH
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = String.localized("EntryOnboardingOpeningHoursViewControllerTitle")
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(progressView)
        self.contentView.addSubview(openingHoursHeaderLabel)
        self.contentView.addSubview(openingHoursStackView)
        self.contentView.addSubview(openingHoursInfoLabel)
        
        self.openingHoursHeaderLabel.text = String.localized("EntryOnboardingOpeningHoursViewControllerOpeningHours")
        self.mondayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerMonday")
        self.tuesdayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerTuesday")
        self.wednesdayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerWednesday")
        self.thursdayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerThursday")
        self.fridayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerFriday")
        self.saturdayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerSaturday")
        self.sundayOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerSunuday")
        self.otherOHTextField.placeholder = String.localized("EntryOnboardingOpeningHoursViewControllerOther")
        
        self.openingHoursInfoLabel.text = String.localized("EntryOnboardingOpeningHoursViewControllerInfo")
        
        self.mondayOHTextField.delegate = self
        self.tuesdayOHTextField.delegate = self
        self.wednesdayOHTextField.delegate = self
        self.thursdayOHTextField.delegate = self
        self.fridayOHTextField.delegate = self
        self.saturdayOHTextField.delegate = self
        self.sundayOHTextField.delegate = self
        self.otherOHTextField.delegate = self
        
        self.openingHoursHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.openingHoursInfoLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        self.openingHoursInfoLabel.numberOfLines = 0
        
        self.progressView.currentStep = String.localized("EntryOnboardingOpeningHoursViewControllerCurrentStep")
        self.progressView.progress = 0.6
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localized("EntryOnboardingOpeningHoursViewControllerNext"),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(continueOnboarding))
        
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
                           openingHoursHeaderLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           openingHoursHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           openingHoursHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           mondayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           tuesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           wednesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           thursdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           fridayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           saturdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           sundayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           otherOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           openingHoursStackView.topAnchor.constraint(equalTo: openingHoursHeaderLabel.bottomAnchor, constant: 0),
                           openingHoursStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           openingHoursStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           openingHoursStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
                           openingHoursInfoLabel.topAnchor.constraint(equalTo: openingHoursStackView.bottomAnchor, constant: 20),
                           openingHoursInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           openingHoursInfoLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
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
    
    @objc private func continueOnboarding() {
        
        entryManager.entryMondayOH = mondayOHTextField.text
        entryManager.entryTuesdayOH = tuesdayOHTextField.text
        entryManager.entryWednesdayOH = wednesdayOHTextField.text
        entryManager.entryThursdayOH = thursdayOHTextField.text
        entryManager.entryFridayOH = fridayOHTextField.text
        entryManager.entrySaturdayOH = saturdayOHTextField.text
        entryManager.entrySundayOH = sundayOHTextField.text
        entryManager.entryOtherOH = otherOHTextField.text
        
        let viewController = EntryOnboardingOverviewViewController(entryManager: entryManager)
        
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

extension EntryOnboardingOpeningHoursViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        let applyTheming: ((HoshiTextField) -> Void) = { textField in
            
            textField.borderActiveColor = theme.accentColor
            textField.borderInactiveColor = theme.decentColor
            textField.placeholderColor = theme.color
            textField.textColor = theme.color
            textField.tintColor = theme.accentColor
            textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            textField.autocorrectionType = .no
            
        }
        
        self.view.backgroundColor = theme.backgroundColor
        self.openingHoursHeaderLabel.textColor = theme.color
        self.progressView.accentColor = theme.accentColor
        self.progressView.decentColor = theme.decentColor
        self.progressView.textColor = theme.color
        
        self.openingHoursInfoLabel.textColor = theme.color
        
        applyTheming(self.mondayOHTextField)
        applyTheming(self.tuesdayOHTextField)
        applyTheming(self.wednesdayOHTextField)
        applyTheming(self.thursdayOHTextField)
        applyTheming(self.fridayOHTextField)
        applyTheming(self.saturdayOHTextField)
        applyTheming(self.sundayOHTextField)
        applyTheming(self.otherOHTextField)
        
    }
    
}
