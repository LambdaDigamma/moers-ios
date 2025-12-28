//
//  PostVideoContentView.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import AVKit

class PostVideoContentView: UIView & UIContentView {
    
    private lazy var backgroundImageView: PlayerView = { ViewFactory.playerView() }()
    private lazy var titleLabel: UILabel = { ViewFactory.label() }()
    private lazy var descriptionLabel: UILabel = { ViewFactory.label() }()
    private lazy var infoBoxContainerView: UIView = { ViewFactory.blankView() }()
    
    internal let cellCornerRadius: CGFloat = 16.0
    
    private var currentConfiguration: PostVideoContentConfiguration!
    
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? PostVideoContentConfiguration else {
                return
            }
            
            apply(configuration: newConfiguration)
        }
    }
    
    // MARK: - Initializer
    
    init(configuration: PostVideoContentConfiguration) {
        
        super.init(frame: .zero)
        self.configuration = configuration
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.addSubview(backgroundImageView)
        self.addSubview(infoBoxContainerView)
        self.addSubview(titleLabel)
        self.addSubview(descriptionLabel)
        
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.contentMode = .scaleAspectFill
        self.backgroundImageView.clipsToBounds = true
        self.backgroundImageView.layer.cornerRadius = cellCornerRadius
        
        self.layer.cornerRadius = cellCornerRadius
        self.layer.cornerCurve = .continuous
        
//        self.titleLabel.font = Typography.font(for: .title)
        self.titleLabel.numberOfLines = 0
        
//        self.descriptionLabel.font = Typography.font(for: .bodySmall)
        self.descriptionLabel.numberOfLines = 0
        
        self.infoBoxContainerView.layer.cornerRadius = cellCornerRadius
        self.infoBoxContainerView.layer.cornerCurve = .continuous
        self.infoBoxContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            heightAnchor.constraint(equalTo: widthAnchor, multiplier: 9 / 16),
            backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            infoBoxContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            infoBoxContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            infoBoxContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: infoBoxContainerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: infoBoxContainerView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: infoBoxContainerView.topAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: infoBoxContainerView.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        titleLabel.textColor = UIColor.white
        descriptionLabel.textColor = UIColor.white
        
        self.clipsToBounds = false
    }
    
    // MARK: - Configiration
    
    private func apply(configuration: PostVideoContentConfiguration) {
        
        guard currentConfiguration != configuration else {
            return
        }
        
        currentConfiguration = configuration
        
        titleLabel.text = configuration.name
        descriptionLabel.text = configuration.description
        
        if let playerItem = configuration.playerItem {
            backgroundImageView.configure(playerItem: playerItem)
        }
        
//        backgroundImageView.image = configuration.image
//        infoBoxContainerView.backgroundColor = configuration.infoBoxColor.withAlphaComponent(0.8)
        
    }
    
}
