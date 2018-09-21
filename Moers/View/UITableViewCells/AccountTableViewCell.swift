//
//  AccountTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class AccountTableViewCell: UITableViewCell {

    lazy var avatarImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "avatar")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
        
    }()
    
    lazy var nameLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
        label.text = "Lennart Fischer"
        
        return label
        
    }()
    
    lazy var descriptionLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        label.text = "Mein Moers Entwickler"
        
        return label
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(descriptionLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.avatarImageView.layer.cornerRadius = 30
        self.accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func update() {
        
        let user = UserManager.shared.user
        
        if let name = user.name {
            nameLabel.text = name
            descriptionLabel.text = user.description ?? ""
        } else {
            nameLabel.text = String.localized("LoginCellTitle")
            descriptionLabel.text = String.localized("LoginCellDescription")
        }
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [avatarImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 2),
                           avatarImageView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           avatarImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -2),
                           avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
                           nameLabel.bottomAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
                           nameLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 16),
                           nameLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                           descriptionLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 16),
                           descriptionLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           self.contentView.heightAnchor.constraint(equalToConstant: 80)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            if UserManager.shared.user.id == nil {
                themeable.nameLabel.textColor = theme.accentColor
                themeable.avatarImageView.image = #imageLiteral(resourceName: "user").tinted(color: theme.color.darker(by: 10)!)
            } else {
                themeable.nameLabel.textColor = theme.color
                themeable.avatarImageView.image = #imageLiteral(resourceName: "user").tinted(color: theme.color.darker(by: 10)!)
            }
            
            themeable.descriptionLabel.textColor = theme.color
        }
        
    }
    
}
