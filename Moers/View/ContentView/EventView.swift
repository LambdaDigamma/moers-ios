//
//  EventView.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class EventView: UIView {

    var event: Event? {
        didSet {
            
            guard let event = event else { return }
            
            nameLabel.text = event.name
            dateLabel.text = event.parsedDate.beautify() + " • " + event.parsedTime
            
        }
    }
    
    lazy var nameLabel: UILabel = { ViewFactory.label() }()
    lazy var dateLabel: UILabel = { ViewFactory.label() }()
    lazy var subtitleLabel: UILabel = { ViewFactory.label() }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        self.addSubview(subtitleLabel)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.numberOfLines = 0
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                           nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                           nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0),
                           dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                           dateLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                           dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0),
                           subtitleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
                           subtitleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                           subtitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -0),
                           subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.nameLabel.textColor = theme.color
            themeable.dateLabel.textColor = theme.color
            themeable.subtitleLabel.textColor = theme.decentColor
            
        }
        
    }
    
}
