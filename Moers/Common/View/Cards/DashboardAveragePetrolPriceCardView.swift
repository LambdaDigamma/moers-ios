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

    private lazy var locationImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "location")
        
        return imageView
        
    }()
    
    private lazy var locationDescriptionLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.text = String.localized("CurrentLocation")
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.70
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    public lazy var locationLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.text = "Moers"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.70
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    private lazy var averageImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "average")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }()
    
    private lazy var priceLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 34, weight: UIFont.Weight.bold)
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    private lazy var petrolTypeLabel: UILabel = {
        
        let label = UILabel()
        
        let type = String.localized("PetrolDescription") + " " + PetrolType.localizedForCase(PetrolManager.shared.petrolType)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.text = type.uppercased()
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    private lazy var infoLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "8 \(String.localized("DashboardPetrolStationInfo"))"
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
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
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [locationImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           locationImageView.heightAnchor.constraint(equalToConstant: 16),
                           locationImageView.widthAnchor.constraint(equalTo: locationImageView.heightAnchor),
                           locationImageView.centerYAnchor.constraint(equalTo: locationDescriptionLabel.centerYAnchor),
                           locationDescriptionLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           locationDescriptionLabel.leftAnchor.constraint(equalTo: locationImageView.rightAnchor, constant: 8),
                           locationDescriptionLabel.rightAnchor.constraint(equalTo: averageImageView.leftAnchor, constant: -8),
                           locationLabel.topAnchor.constraint(equalTo: locationDescriptionLabel.bottomAnchor, constant: 8),
                           locationLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           locationLabel.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -16),
                           averageImageView.rightAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: -4),
                           averageImageView.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
                           averageImageView.heightAnchor.constraint(equalToConstant: 15),
                           averageImageView.widthAnchor.constraint(equalTo: averageImageView.heightAnchor),
                           priceLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
                           priceLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           priceLabel.heightAnchor.constraint(equalToConstant: 32),
                           priceLabel.widthAnchor.constraint(equalToConstant: 104),
                           petrolTypeLabel.leftAnchor.constraint(equalTo: priceLabel.leftAnchor, constant: 4),
                           petrolTypeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           petrolTypeLabel.bottomAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: -16),
                           infoLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
                           infoLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           infoLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           infoLabel.heightAnchor.constraint(equalToConstant: 36),
                           infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)]
        
        constraints.forEach { $0.priority = UILayoutPriority.required }
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.locationImageView.image = #imageLiteral(resourceName: "location").tinted(color: theme.color)
            themeable.locationDescriptionLabel.textColor = theme.color
            themeable.locationLabel.textColor = theme.color
            themeable.priceLabel.textColor = theme.color
            themeable.infoLabel.textColor = theme.decentColor //.darker(by: 20)
            themeable.petrolTypeLabel.textColor = theme.decentColor //.darker(by: 20)
            themeable.averageImageView.image = #imageLiteral(resourceName: "average").tinted(color: theme.color)
            
        }
        
    }
    
}
