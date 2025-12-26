//
//  EntryOnboardingLocationMenuViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit

import Core
import Factory

public class EntryOnboardingLocationMenuViewController: UIViewController {
    
    @LazyInjected(\.entryManager) var entryManager
    
    private lazy var progressView: OnboardingProgressView = { CoreViewFactory.onboardingProgressView() }()
    private lazy var addressButton: UIButton = { CoreViewFactory.button() }()
    private lazy var locationButton: UIButton = { CoreViewFactory.button() }()
    private lazy var infoLabel: UILabel = { CoreViewFactory.label() }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }

    public override func viewDidAppear(_ animated: Bool) {
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
        
        let viewController = MapLocationPickerViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

