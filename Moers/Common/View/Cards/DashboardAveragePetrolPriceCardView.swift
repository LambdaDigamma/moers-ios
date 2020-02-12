//
//  DashboardAveragePetrolPriceCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 22.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class DashboardAveragePetrolPriceCardView: CardView {

    public lazy var locationLabel = { ViewFactory.label() }()
    private lazy var locationImageView = { ViewFactory.imageView() }()
    private lazy var locationDescriptionLabel = { ViewFactory.label() }()
    private lazy var averageImageView = { ViewFactory.imageView() }()
    private lazy var priceLabel = { ViewFactory.label() }()
    private lazy var petrolTypeLabel = { ViewFactory.label() }()
    private lazy var infoLabel = { ViewFactory.label() }()
    
    public var price: Double = 0 {
        didSet {
            priceLabel.text = String(format:"%.2f€", price)
        }
    }
    
    public var numberOfStations: Int = 0 {
        didSet {
            infoLabel.text = "\(numberOfStations) \(String.localized("DashboardPetrolStationInfo"))"
            setNeedsDisplay()
            setNeedsLayout()
        }
    }
    
    public var petrolType: PetrolType = .diesel {
        didSet {
            let type = String.localized("PetrolDescription") + " " + PetrolType.localizedForCase(petrolType)
            petrolTypeLabel.text = type.uppercased()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(locationImageView)
        self.addSubview(locationDescriptionLabel)
        self.addSubview(locationLabel)
        self.addSubview(averageImageView)
        self.addSubview(priceLabel)
        self.addSubview(infoLabel)
        self.addSubview(petrolTypeLabel)
        
        self.setupUI()
        self.setupAccessibility()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.locationImageView.contentMode = .scaleAspectFit
        self.locationImageView.image = #imageLiteral(resourceName: "location")
        
        self.locationDescriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        self.locationDescriptionLabel.text = String.localized("CurrentLocation")
        self.locationDescriptionLabel.adjustsFontSizeToFitWidth = true
        self.locationDescriptionLabel.minimumScaleFactor = 0.70
        self.locationDescriptionLabel.adjustsFontForContentSizeCategory = true
        
        self.locationLabel.font = UIFont.boldSystemFont(ofSize: 32)
        self.locationLabel.text = "Moers"
        self.locationLabel.adjustsFontSizeToFitWidth = true
        self.locationLabel.minimumScaleFactor = 0.70
        self.locationLabel.adjustsFontForContentSizeCategory = true
        
        self.averageImageView.image = #imageLiteral(resourceName: "average")
        self.averageImageView.contentMode = .scaleAspectFit
        
        self.priceLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: UIFont.Weight.bold)
        self.priceLabel.adjustsFontForContentSizeCategory = true
        
        let type = String.localized("PetrolDescription") + " " + "Diesel"
        
        self.petrolTypeLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        self.petrolTypeLabel.text = type.uppercased()
        self.petrolTypeLabel.adjustsFontForContentSizeCategory = true
        
        self.infoLabel.font = UIFont.systemFont(ofSize: 14)
        self.infoLabel.text = "8 \(String.localized("DashboardPetrolStationInfo"))"
        self.infoLabel.numberOfLines = 0
        self.infoLabel.adjustsFontForContentSizeCategory = true
        
    }
    
    private func setupAccessibility() {
        
        accessibilityElements = []
        
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = "DashboardPetrol"
        self.accessibilityLabel = "Overview of current petrol prices at your location: "
        
        self.accessibilityLabel =
            String.localized("") +
            "\"\(locationLabel.text ?? String.localized("Unknown"))\""
            
        
        self.accessibilityHint = String.localized("DashboardAction")
        
    }
    
    private func setupConstraints() {
        
        let constraints = [locationImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           locationImageView.heightAnchor.constraint(equalToConstant: 16),
                           locationImageView.widthAnchor.constraint(equalTo: locationImageView.heightAnchor),
                           locationImageView.centerYAnchor.constraint(equalTo: locationDescriptionLabel.centerYAnchor),
                           locationDescriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           locationDescriptionLabel.leadingAnchor.constraint(equalTo: locationImageView.trailingAnchor, constant: 8),
                           locationDescriptionLabel.trailingAnchor.constraint(equalTo: averageImageView.leadingAnchor, constant: -8),
                           locationLabel.topAnchor.constraint(equalTo: locationDescriptionLabel.bottomAnchor, constant: 8),
                           locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           locationLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -16),
                           averageImageView.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -4),
                           averageImageView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
                           averageImageView.heightAnchor.constraint(equalToConstant: 15),
                           averageImageView.widthAnchor.constraint(equalTo: averageImageView.heightAnchor),
                           priceLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
                           priceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           priceLabel.heightAnchor.constraint(equalToConstant: 32),
                           priceLabel.widthAnchor.constraint(equalToConstant: 104),
                           petrolTypeLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: 4),
                           petrolTypeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           petrolTypeLabel.bottomAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: -16),
                           infoLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
                           infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           infoLabel.heightAnchor.constraint(equalToConstant: 36),
                           infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)]
        
        constraints.forEach { $0.priority = UILayoutPriority.required }
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: self)
        
    }
    
}

extension DashboardAveragePetrolPriceCardView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        
        self.applyBaseStyling(theme: theme)
        
        self.locationImageView.image = #imageLiteral(resourceName: "location").tinted(color: theme.color)
        self.locationDescriptionLabel.textColor = theme.color
        self.locationLabel.textColor = theme.color
        self.priceLabel.textColor = theme.color
        self.infoLabel.textColor = theme.decentColor //.darker(by: 20)
        self.petrolTypeLabel.textColor = theme.decentColor //.darker(by: 20)
        self.averageImageView.image = #imageLiteral(resourceName: "average").tinted(color: theme.color)
        
    }
    
}
