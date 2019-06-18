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

    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }()
    
    lazy var dateLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    lazy var typeLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        
        return label
        
    }()
    
    var rubbishCollectionItem: RubbishCollectionItem? {
        didSet {
            
            guard let item = rubbishCollectionItem else { return }
            
            dateLabel.text = item.parsedDate.beautify()
            typeLabel.text = RubbishWasteType.localizedForCase(item.type)
            
            switch item.type {
            case .green: imageView.image = #imageLiteral(resourceName: "greenWaste")
            case .paper: imageView.image = #imageLiteral(resourceName: "paperWaste")
            case .yellow: imageView.image = #imageLiteral(resourceName: "yellowWaste")
            case .residual: imageView.image = #imageLiteral(resourceName: "residualWaste")
            case .organic: imageView.image = #imageLiteral(resourceName: "greenWaste")
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(dateLabel)
        self.addSubview(typeLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [self.heightAnchor.constraint(equalToConstant: 60),
                           imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
                           typeLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
                           typeLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
                           typeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           dateLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                           dateLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8),
                           dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.dateLabel.textColor = theme.color
            themeable.typeLabel.textColor = theme.color
            
        }
        
    }

}
