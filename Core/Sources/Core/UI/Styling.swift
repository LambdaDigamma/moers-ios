//
//  Styling.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

#if canImport(UIKit)

import Foundation
import UIKit

public enum Styling {
    
    public static func applyStyling(
        navigationController: UINavigationController,
        statusBarStyle: UIStatusBarStyle = .darkContent
    ) {
        
        navigationController.navigationBar.barTintColor = UIColor.systemBackground
        navigationController.navigationBar.tintColor = UIColor.systemYellow
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.prefersLargeTitles = true
        
        if statusBarStyle == .lightContent {
            navigationController.navigationBar.barStyle = .black
        } else {
            navigationController.navigationBar.barStyle = .default
        }
        
    }
    
}

#endif
