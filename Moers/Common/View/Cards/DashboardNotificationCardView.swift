//
//  DashboardNotificationCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 12.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class DashboardNotificationCardView: CardView {

    lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }()
    
    lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        
        return label
        
    }()
    
    lazy var subtitleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
        
        return label
        
    }()
    
    var image: UIImage? = nil {
        didSet {
            if let image = image {
                imageView.image = image
                imageWidthConstraint?.constant = 50
                imageLeftConstraint?.constant = 16
            } else {
                imageWidthConstraint?.constant = 0
                imageLeftConstraint?.constant = 0
            }
        }
    }

    var imageWidthConstraint: NSLayoutConstraint?
    var imageLeftConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           imageView.heightAnchor.constraint(equalToConstant: 50),
                           titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
                           titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                           subtitleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
                           subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                           subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        imageWidthConstraint?.isActive = true
        
        imageLeftConstraint = imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        imageLeftConstraint?.isActive = true
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension DashboardNotificationCardView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.titleLabel.textColor = theme.color
        self.subtitleLabel.textColor = theme.color.lighter()
    }
    
}
