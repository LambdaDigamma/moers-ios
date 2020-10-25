//
//  CovidCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import Gestalt

class CovidCollectionViewCell: UICollectionViewCell {
    
    lazy var cardView: CardView = { ViewFactory.cardView() }()
    lazy var incidenceLabel: UILabel = { ViewFactory.label() }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupTheming()
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(cardView)
        self.addSubview(incidenceLabel)
        
//        self.nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
//        self.nameLabel.numberOfLines = 1
//        self.nameLabel.adjustsFontSizeToFitWidth = true
//        self.nameLabel.minimumScaleFactor = 0.7
//        self.brandLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        self.brandLabel.lineBreakMode = .byWordWrapping
//        self.brandLabel.adjustsFontSizeToFitWidth = true
//        self.brandLabel.minimumScaleFactor = 0.5
//        self.addressLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
//        self.addressLabel.lineBreakMode = .byTruncatingHead
//        self.addressLabel.adjustsFontSizeToFitWidth = true
//        self.addressLabel.minimumScaleFactor = 0.5
//        self.priceView.layer.cornerRadius = 4
//        self.priceLabel.textColor = UIColor.white
//        self.priceLabel.font = UIFont.systemFont(ofSize: 28, weight: UIFont.Weight.semibold)
//        self.routeButton.setTitle("Route", for: .normal)
//        self.routeButton.clipsToBounds = true
//        self.routeButton.layer.cornerRadius = 8
//        self.routeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//        self.routeButton.addTarget(self, action: #selector(startRoute), for: .touchUpInside)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [cardView.topAnchor.constraint(equalTo: self.topAnchor),
                           cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           incidenceLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
                           incidenceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                           incidenceLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

extension CovidCollectionViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = UIColor.clear
        self.incidenceLabel.textColor = theme.color
    }
    
}
