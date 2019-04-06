//
//  OrganisationHeader.swift
//  Moers
//
//  Created by Lennart Fischer on 24.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI

class OrganisationHeader: UIView {
    
    var organisation: Organisation? {
        didSet {
            
            guard let organisation = organisation else { return }
            
            nameLabel.text = organisation.name
            descriptionLabel.text = organisation.description
            imageView.image = #imageLiteral(resourceName: "MoersAppIcon") //#imageLiteral(resourceName: "cfn")
            imageView.contentMode = .scaleAspectFit
            
        }
    }
    
    lazy var imageView = { ViewFactory.imageView() }()
    lazy var nameLabel = { ViewFactory.label() }()
    lazy var descriptionLabel = { ViewFactory.label() }()
    lazy var followButton = { FollowButton(frame: .zero) }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(imageView)
        self.addSubview(nameLabel)
        self.addSubview(descriptionLabel)
        self.addSubview(followButton)
        
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.borderWidth = 1
        self.imageView.contentMode = .scaleAspectFill
        
        self.nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.nameLabel.numberOfLines = 0
        
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        self.descriptionLabel.numberOfLines = 0
        
        self.followButton.isUserInteractionEnabled = true
        self.followButton.setTitle("Folgen", for: .normal)
        self.followButton.addTarget(self, action: #selector(pressedFollow(_:)), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        
        followButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                           imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           imageView.widthAnchor.constraint(equalToConstant: 75),
                           imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                           nameLabel.topAnchor.constraint(equalTo: imageView.topAnchor),
                           nameLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 16),
                           nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                           descriptionLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor, constant: 0),
                           descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
                           followButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
                           followButton.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
                           followButton.heightAnchor.constraint(equalToConstant: 30),
                           followButton.widthAnchor.constraint(equalToConstant: 100),
                           followButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.nameLabel.textColor = theme.color
            themeable.descriptionLabel.textColor = theme.decentColor
            themeable.imageView.layer.borderColor = theme.color.cgColor
            themeable.imageView.backgroundColor = UIColor.white
            themeable.followButton.tintColor = theme.accentColor
            
        }
        
    }
    
    @objc private func pressedFollow(_ button: FollowButton) {
        
        button.isFilled = !button.isFilled
        
        if button.isFilled {
            button.setTitle("Folgt", for: .normal)
        } else {
            button.setTitle("Folgen", for: .normal)
        }
        
        print("Button is now filled: \(button.isFilled)")
        
    }
    
}

