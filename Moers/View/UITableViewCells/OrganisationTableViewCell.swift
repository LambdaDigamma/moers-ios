//
//  OrganisationTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 25.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Kingfisher

class OrganisationTableViewCell: UITableViewCell {

    var organisation: Organisation? {
        didSet {
            self.nameLabel.text = organisation?.name
            self.subtitleLabel.text = "\(Int.random(in: 10...35)) Mitglieder" // "Letzte Änderung: " + (organisation?.createdAt?.beautify(format: "dd.MM.yyyy") ?? "")
            self.iconImageView.image = #imageLiteral(resourceName: "group").withRenderingMode(.alwaysTemplate)
//            self.iconImageView.kf.setImage(with: organisation?.iconURL)
        }
    }
    
    private lazy var iconImageView = { ViewFactory.imageView() }()
    private lazy var nameLabel = { ViewFactory.label() }()
    private lazy var subtitleLabel = { ViewFactory.label() }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(subtitleLabel)
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
        
        self.iconImageView.layer.cornerRadius = 5
        self.iconImageView.clipsToBounds = true
        self.iconImageView.contentMode = .scaleAspectFit
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [iconImageView.topAnchor.constraint(equalTo: margins.topAnchor),
                           iconImageView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           iconImageView.widthAnchor.constraint(equalTo: margins.heightAnchor),
                           iconImageView.heightAnchor.constraint(equalToConstant: 50),
                           iconImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           nameLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           nameLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 8),
                           nameLabel.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                           subtitleLabel.leftAnchor.constraint(equalTo: iconImageView.rightAnchor, constant: 8),
                           /*subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor)*/]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.nameLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.color
            themeable.iconImageView.tintColor = theme.color
            
        }
        
    }

}
