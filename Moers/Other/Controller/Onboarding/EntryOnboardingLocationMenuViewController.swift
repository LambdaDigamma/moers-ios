//
//  EntryOnboardingLocationMenuViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI
import MMAPI

class EntryOnboardingLocationMenuViewController: UIViewController {

    private lazy var progressView: OnboardingProgressView = { ViewFactory.onboardingProgressView() }()
    private lazy var addressButton: UIButton = { ViewFactory.button() }()
    private lazy var locationButton: UIButton = { ViewFactory.button() }()
    private lazy var infoLabel: UILabel = { ViewFactory.label() }()
    
    private let locationManager: LocationManagerProtocol
    private let entryManager: EntryManagerProtocol
    
    init(locationManager: LocationManagerProtocol, entryManager: EntryManagerProtocol) {
        self.locationManager = locationManager
        self.entryManager = entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        
        progressView.progress = 0
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = String.localized("EntryOnboardingLocationMenuViewControllerTitle")
        
        self.view.addSubview(progressView)
        self.view.addSubview(addressButton)
        self.view.addSubview(locationButton)
        self.view.addSubview(infoLabel)
        
        self.infoLabel.text = String.localized("EntryOnboardingLocationMenuViewControllerInfo")
        self.infoLabel.numberOfLines = 0
        self.infoLabel.font = UIFont.systemFont(ofSize: 12)
        self.addressButton.setTitle(String.localized("EntryOnboardingLocationMenuViewControllerAddressAction"), for: .normal)
        self.locationButton.setTitle(String.localized("EntryOnboardingLocationMenuViewControllerLocationAction"), for: .normal)
        self.addressButton.titleLabel?.numberOfLines = 0
        self.locationButton.titleLabel?.numberOfLines = 0
        self.addressButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.locationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        self.addressButton.titleLabel?.textAlignment = .center
        self.locationButton.titleLabel?.textAlignment = .center
        self.addressButton.layer.cornerRadius = 8
        self.locationButton.layer.cornerRadius = 8
        self.locationButton.clipsToBounds = true
        self.addressButton.clipsToBounds = true
        self.locationButton.addTarget(self, action: #selector(enterLocation), for: .touchUpInside)
        self.addressButton.addTarget(self, action: #selector(enterAddress), for: .touchUpInside)
        
        self.progressView.currentStep = String.localized("EntryOnboardingLocationMenuViewControllerCurrentStep")
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [progressView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 20),
                           progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           locationButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           locationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           locationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           locationButton.heightAnchor.constraint(equalToConstant: 45),
                           addressButton.topAnchor.constraint(equalTo: self.locationButton.bottomAnchor, constant: 16),
                           addressButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           addressButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           addressButton.heightAnchor.constraint(equalToConstant: 45),
                           infoLabel.topAnchor.constraint(equalTo: addressButton.bottomAnchor, constant: 16),
                           infoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           infoLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func enterAddress() {
        
        let viewController = EntryOnboardingAddressViewController(entryManager: entryManager)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func enterLocation() {
        
        let viewController = MapLocationPickerViewController(locationManager: locationManager, entryManager: entryManager)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension EntryOnboardingLocationMenuViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.infoLabel.textColor = theme.color
        self.addressButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.locationButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.addressButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
        self.locationButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
        self.progressView.accentColor = theme.accentColor
        self.progressView.decentColor = theme.decentColor
        self.progressView.textColor = theme.color
    }
    
}
