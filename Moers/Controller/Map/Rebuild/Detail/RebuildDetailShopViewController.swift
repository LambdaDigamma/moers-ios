//
//  RebuildDetailShopViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class RebuildDetailShopViewController: UIViewController {

    lazy var topSeparator: UIView = { ViewFactory.blankView() }()
    lazy var callButton: UIButton = { ViewFactory.button() }()
    lazy var websiteButton: UIButton = { ViewFactory.button() }()
    lazy var buttonSeparator: UIView = { ViewFactory.blankView() }()
    lazy var addressHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var streetLabel: UILabel = { ViewFactory.label() }()
    lazy var placeLabel: UILabel = { ViewFactory.label() }()
    lazy var countryLabel: UILabel = { ViewFactory.label() }()
    lazy var addressSeperator: UIView = { ViewFactory.blankView() }()
    lazy var openingHoursHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var mondayHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var mondayLabel: UILabel = { ViewFactory.label() }()
    lazy var tuesdayHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var tuesdayLabel: UILabel = { ViewFactory.label() }()
    lazy var wednesdayHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var wednesdayLabel: UILabel = { ViewFactory.label() }()
    lazy var thursdayHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var thursdayLabel: UILabel = { ViewFactory.label() }()
    lazy var fridayHeaderLabel: UILabel = { ViewFactory.label() }()
    lazy var fridayLabel: UILabel = { ViewFactory.label() }()
    
    var selectedShop: Store? { didSet { selectShop(selectedShop) } }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods

    private func setupUI() {
        
        self.view.addSubview(topSeparator)
        self.view.addSubview(callButton)
        self.view.addSubview(websiteButton)
        
        self.callButton.setTitle(String.localized("CallAction"), for: .normal)
        self.websiteButton.setTitle(String.localized("WebsiteAction"), for: .normal)
        self.callButton.layer.cornerRadius = 8
        self.websiteButton.layer.cornerRadius = 8
        self.callButton.clipsToBounds = true
        self.websiteButton.clipsToBounds = true
        self.callButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.websiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        self.topSeparator.alpha = 0.5
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.topSeparator.backgroundColor = theme.decentColor
            themeable.callButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.callButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.callButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.websiteButton.setTitleColor(theme.backgroundColor, for: .normal)
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [topSeparator.topAnchor.constraint(equalTo: self.view.topAnchor),
                           topSeparator.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           topSeparator.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           topSeparator.heightAnchor.constraint(equalToConstant: 1),
                           callButton.topAnchor.constraint(equalTo: topSeparator.bottomAnchor, constant: 8),
                           callButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           callButton.heightAnchor.constraint(equalToConstant: 50),
                           websiteButton.topAnchor.constraint(equalTo: callButton.topAnchor),
                           websiteButton.leftAnchor.constraint(equalTo: callButton.rightAnchor, constant: 8),
                           websiteButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           websiteButton.heightAnchor.constraint(equalTo: callButton.heightAnchor),
                           websiteButton.widthAnchor.constraint(equalTo: callButton.widthAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func selectShop(_ shop: Store?) {
        
        // TODO: Implement
        
        if shop?.url == nil {
            
            
            
        }
        
    }
    
    @objc private func call() {
        
        guard let _ = selectedShop else { return }
        
//        if let url = shop.phone, UIApplication.shared.canOpenURL(url) {
//
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//
//        }
        
    }
    
    @objc private func openWebsite() {
        
        guard let shop = selectedShop else { return }
        guard let url = URL(string: shop.url ?? "") else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options:  [:], completionHandler: nil)
            
        }
        
    }
    
}
