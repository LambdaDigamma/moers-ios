//
//  NewsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class NewsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("NewsTitle")
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    private func setupConstraints() {
        
        
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }

}
