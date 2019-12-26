//
//  RubbishCollectionView.swift
//  Moers
//
//  Created by Lennart Fischer on 12.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class RubbishCollectionView: UIView {

    // MARK: - UI
    
    private lazy var imageView = { ViewFactory.imageView() }()
    private lazy var typeLabel = { ViewFactory.label() }()
    private lazy var dateLabel = { ViewFactory.label() }()
    
    var rubbishCollectionItem: RubbishPickupItem? {
        didSet {
            
            guard let item = rubbishCollectionItem else { return }
            
            dateLabel.text = item.date.beautify()
            typeLabel.text = RubbishWasteType.localizedForCase(item.type)
            
            switch item.type {
            case .cuttings: imageView.image = #imageLiteral(resourceName: "greenWaste")
            case .paper: imageView.image = #imageLiteral(resourceName: "paperWaste")
            case .plastic: imageView.image = #imageLiteral(resourceName: "yellowWaste")
            case .residual: imageView.image = #imageLiteral(resourceName: "residualWaste")
            case .organic: imageView.image = #imageLiteral(resourceName: "greenWaste")
            }
            
            self.setupAccessibility()
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(dateLabel)
        self.addSubview(typeLabel)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.imageView.contentMode = .scaleAspectFit
        
        self.typeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        self.typeLabel.minimumScaleFactor = 0.5
        self.typeLabel.adjustsFontSizeToFitWidth = true
        self.typeLabel.adjustsFontForContentSizeCategory = true
        
        self.dateLabel.font = UIFont.systemFont(ofSize: 14)
        self.dateLabel.adjustsFontForContentSizeCategory = true
        
    }
    
    private func setupAccessibility() {
        
        guard let item = rubbishCollectionItem else { return }
        
        let localizedDate = DateFormatter.localizedString(from: item.date, dateStyle: .full, timeStyle: .none)
        let localizedType = RubbishWasteType.localizedForCase(item.type)
        
        self.isAccessibilityElement = true
        self.accessibilityElements = []
        self.accessibilityIdentifier = "RubbishItem-\(item.type)"
        self.accessibilityLabel = "\(localizedType) \(String.localized("WasteCollection")) \(localizedDate)"
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            self.heightAnchor.constraint(equalToConstant: 60),
            imageView.topAnchor.constraint(equalTo: typeLabel.topAnchor),
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: self.dateLabel.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            typeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            typeLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
            typeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            dateLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }

}

extension RubbishCollectionView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.dateLabel.textColor = theme.color
        self.typeLabel.textColor = theme.color
    }
    
}
