//
//  PetrolStationCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 07.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MapKit
import MMAPI

class PetrolStationCollectionViewCell: UICollectionViewCell {
    
    lazy var cardView: CardView = { ViewFactory.cardView() }()
    lazy var nameLabel: UILabel = { ViewFactory.label() }()
    lazy var brandLabel: UILabel = { ViewFactory.label() }()
    lazy var routeButton: UIButton = { ViewFactory.button() }()
    lazy var addressLabel: UILabel = { ViewFactory.label() }()
    lazy var priceView: UIView = { ViewFactory.blankView() }()
    lazy var priceLabel: UILabel = { ViewFactory.label() }()
    
    var petrolStation: PetrolStation? { didSet { setupPetrolStation(petrolStation) } }
    var averagePrice: Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupTheming()
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPetrolStation(_ petrolStation: PetrolStation?) {
        
        guard let petrolStation = petrolStation else { return }
        
        var distance = ""
        
        if let dist = petrolStation.dist {
            distance = String(format:"%.1fkm", dist)
        }
        
        let name = petrolStation.title
        
        let brand = petrolStation.brand + " • " +
                    (petrolStation.isOpen ? String.localized("LocalityOpen") : String.localized("LocalityClosed"))
        
        let address = petrolStation.street.capitalized(with: Locale.autoupdatingCurrent) + " " + (petrolStation.houseNumber ?? "")
        
        self.nameLabel.text = name
        self.brandLabel.text = brand
        self.addressLabel.text = address
        self.routeButton.setTitle("Route (\(distance))", for: .normal)
        
        if let price = petrolStation.price {
            
            self.priceLabel.text = String(format: "%.2f€", price)
            self.priceView.backgroundColor = price <= averagePrice ? #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            
        } else {
            
            self.priceLabel.text = "n/v"
            self.priceView.backgroundColor = self.cardView.backgroundColor?.lighter(by: 10)
            
        }
        
    }
    
    @objc private func startRoute() {
        
        guard let petrolStation = petrolStation else { return }
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: petrolStation.coordinate))
        mapItem.name = petrolStation.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    private func setupUI() {
        
        self.addSubview(cardView)
        self.addSubview(nameLabel)
        self.addSubview(brandLabel)
        self.addSubview(addressLabel)
        self.addSubview(priceView)
        self.addSubview(priceLabel)
        self.addSubview(routeButton)
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        self.nameLabel.numberOfLines = 1
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.7
        self.brandLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.brandLabel.lineBreakMode = .byWordWrapping
        self.brandLabel.adjustsFontSizeToFitWidth = true
        self.brandLabel.minimumScaleFactor = 0.5
        self.addressLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.addressLabel.lineBreakMode = .byTruncatingHead
        self.addressLabel.adjustsFontSizeToFitWidth = true
        self.addressLabel.minimumScaleFactor = 0.5
        self.priceView.layer.cornerRadius = 4
        self.priceLabel.textColor = UIColor.white
        self.priceLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
        self.routeButton.setTitle("Route", for: .normal)
        self.routeButton.clipsToBounds = true
        self.routeButton.layer.cornerRadius = 8
        self.routeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        self.routeButton.addTarget(self, action: #selector(startRoute), for: .touchUpInside)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.backgroundColor = UIColor.clear
            themeable.nameLabel.textColor = theme.color
            themeable.brandLabel.textColor = theme.decentColor
            themeable.addressLabel.textColor = theme.decentColor
            themeable.routeButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.routeButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.routeButton.setTitleColor(theme.cardBackgroundColor, for: .normal)
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [cardView.topAnchor.constraint(equalTo: self.topAnchor),
                           cardView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           cardView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                           nameLabel.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 16),
                           nameLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -16),
                           brandLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                           brandLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
                           brandLabel.rightAnchor.constraint(equalTo: priceView.leftAnchor, constant: -8),
                           addressLabel.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 8),
                           addressLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
                           addressLabel.rightAnchor.constraint(equalTo: priceView.leftAnchor, constant: -8),
                           priceView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                           priceView.widthAnchor.constraint(equalToConstant: 100),
                           priceView.heightAnchor.constraint(equalToConstant: 44),
                           priceView.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
                           priceLabel.centerXAnchor.constraint(equalTo: priceView.centerXAnchor),
                           priceLabel.centerYAnchor.constraint(equalTo: priceView.centerYAnchor),
                           routeButton.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12),
                           routeButton.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
                           routeButton.rightAnchor.constraint(equalTo: nameLabel.rightAnchor),
                           routeButton.heightAnchor.constraint(equalToConstant: 40),
                           routeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
