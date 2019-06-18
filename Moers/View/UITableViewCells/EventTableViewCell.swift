//
//  EventTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class EventTableViewCell: UITableViewCell {

    var event: Event? {
        didSet {
            self.eventView.event = event
        }
    }
    
    private lazy var eventView: EventView = {
        
        let eventView = EventView()
        
        eventView.translatesAutoresizingMaskIntoConstraints = false
        
        return eventView
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(eventView)
        
        self.setupConstraints()
        self.setupTheming()
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
    
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [eventView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
                           eventView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0),
                           eventView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: -0),
                           eventView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
}
