//
//  RubbishCollectionItemView.swift
//  Moers
//
//  Created by Lennart Fischer on 21.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class RubbishCollectionItemView: UIView {

    lazy var dateLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        
        return label
        
    }()
    
    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }()
    
    lazy var typeLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        return label
        
    }()
    
    var rubbishCollectionItem: RubbishCollectionItem? {
        didSet {
            
            guard let item = rubbishCollectionItem else { return }
            
            dateLabel.text = item.date
            typeLabel.text = item.type.rawValue
            
            switch item.type {
            case .green: imageView.image = #imageLiteral(resourceName: "greenWaste")
            case .paper: imageView.image = #imageLiteral(resourceName: "paperWaste")
            case .yellow: imageView.image = #imageLiteral(resourceName: "yellowWaste")
            case .residual: imageView.image = #imageLiteral(resourceName: "residualWaste")
            default: break
            }
            
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(dateLabel)
        self.addSubview(imageView)
        self.addSubview(typeLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8),
                           dateLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           dateLabel.heightAnchor.constraint(equalToConstant: 12),
                           typeLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -4),
                           typeLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           typeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           typeLabel.heightAnchor.constraint(equalToConstant: 16),
                           imageView.bottomAnchor.constraint(equalTo: typeLabel.topAnchor, constant: -8),
                           imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.dateLabel.textColor = theme.color
            themeable.typeLabel.textColor = theme.color
            
        }
        
    }
    
}
