//
//  CommunityCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 25.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class CommunityCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "trophy").tinted(color: UIColor.black)
        
        return imageView
        
    }()
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.textAlignment = .center
        label.text = String.localized("LeaderboardTitle")
        
        return label
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.layer.cornerRadius = 10
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [self.contentView.heightAnchor.constraint(equalTo: self.contentView.widthAnchor),
                           self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8),
                           self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8),
                           self.imageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.5),
                           self.imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                           self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                           self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8),
                           self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                           self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)]

        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.cornerRadius = 12.0
            themeable.backgroundColor = theme.cardBackgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.imageView.tintColor = theme.color
            themeable.imageView.image = themeable.imageView.image?.tinted(color: theme.color)
            
            if theme.cardShadow {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.6
                themeable.shadowRadius = 10.0
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            } else {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.0
                themeable.shadowRadius = 0.0
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            }
            
        }
        
    }
    
}

extension UICollectionViewCell {
    
    public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}
