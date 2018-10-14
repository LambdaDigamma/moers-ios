//
//  EntryOnboardingLocationMenuViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class EntryOnboardingLocationMenuViewController: UIViewController {

    lazy var infoLabel: UILabel = { ViewFactory.label() }()
    lazy var addressButton: UIButton = { ViewFactory.button() }()
    lazy var locationButton: UIButton = { ViewFactory.button() }()
    
    // MARK: - UIViewController Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Eintrag hinzufügen"
        
        self.view.addSubview(infoLabel)
        self.view.addSubview(addressButton)
        self.view.addSubview(locationButton)
        
        self.infoLabel.text = "Es gibt zwei Möglichkeiten, einen neuen Eintrag hinzufügen: \nWenn Du gerade neben dem Ort stehst, kannst ihn am aktuellen Standort hinzufügen. \nAndernfalls kannst Du einen Ort an einer Adresse hinzufügen."
        self.infoLabel.numberOfLines = 0
        self.infoLabel.font = UIFont.systemFont(ofSize: 12)
        self.addressButton.setTitle("Eintrag an Adresse hinzufügen", for: .normal)
        self.locationButton.setTitle("Eintrag an aktueller Position hinzufügen", for: .normal)
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
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.infoLabel.textColor = theme.color
            themeable.addressButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.locationButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.addressButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.locationButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [locationButton.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           locationButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           locationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           locationButton.heightAnchor.constraint(equalToConstant: 45),
                           addressButton.topAnchor.constraint(equalTo: self.locationButton.bottomAnchor, constant: 16),
                           addressButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           addressButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           addressButton.heightAnchor.constraint(equalToConstant: 45),
                           infoLabel.topAnchor.constraint(equalTo: addressButton.bottomAnchor, constant: 16),
                           infoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           infoLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func enterAddress() {
        
        let viewController = UIViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func enterLocation() {
        
        let viewController = MapLocationPickerViewController()
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}
