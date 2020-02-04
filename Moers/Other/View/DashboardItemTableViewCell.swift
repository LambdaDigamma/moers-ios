//
//  DashboardItemTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 15.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import Gestalt

class DashboardItemTableViewCell: UITableViewCell {

//    var 

    private func setupTheming() {
        
        
        
    }
    
}

extension DashboardItemTableViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backgroundColor = theme.cardBackgroundColor
        self.textLabel?.textColor = theme.color
    }
    
}
