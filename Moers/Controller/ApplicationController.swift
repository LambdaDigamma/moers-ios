//
//  ApplicationController.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class ApplicationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.default.theme = Theme.lightning
        ThemeManager.default.animated = true
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            UIApplication.shared.statusBarStyle = theme.statusBarStyle
            themeable.view.backgroundColor = theme.backgroundColor
        }
        
        let tabBarController = TabBarController()
        
        (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = tabBarController
        
    }

}
