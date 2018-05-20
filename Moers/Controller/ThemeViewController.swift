//
//  ThemeViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class ThemeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("ThemeTitle")
        
        self.setupConstraints()
        
    }
    
    private func setupConstraints() {
        
        
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themable, theme) in
            
            themable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }
    

}
