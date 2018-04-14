//
//  Theme.swift
//  Moers
//
//  Created by Lennart Fischer on 14.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

struct Theme: ThemeProtocol {
    
    let color: UIColor
    let backgroundColor: UIColor
    let accentColor: UIColor
    let navigationColor: UIColor
    let seperatorColor: UIColor
    let statusBarStyle: UIStatusBarStyle
    
    static private let darkGray = UIColor(red: 0.137, green: 0.122, blue: 0.125, alpha: 1.00)
    static private let yellow = UIColor(red: 1.000, green: 0.949, blue: 0.200, alpha: 1.00)
    
    static let light = Theme(color: UIColor.black,
                             backgroundColor: UIColor(red: 0.980, green: 0.980, blue: 0.980, alpha: 1.00),
                             accentColor: UIColor.blue,
                             navigationColor: UIColor.white,
                             seperatorColor: UIColor.lightGray,
                             statusBarStyle: .default)
    
    static let dark = Theme(color: UIColor.white,
                            backgroundColor: darkGray,
                            accentColor: yellow,
                            navigationColor: UIColor.black,
                            seperatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
                            statusBarStyle: .lightContent)
    
}