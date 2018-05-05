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
    let decentColor: UIColor
    let navigationColor: UIColor
    let separatorColor: UIColor
    let statusBarStyle: UIStatusBarStyle
    
    static private let darkGray = UIColor(red: 0.137, green: 0.122, blue: 0.125, alpha: 1.00)
    static private let yellow = UIColor(red: 1.000, green: 0.949, blue: 0.200, alpha: 1.00)
    
    static let light = Theme(color: UIColor.black,
                             backgroundColor: UIColor(red: 0.980, green: 0.980, blue: 0.980, alpha: 1.00),
                             accentColor: UIColor.blue,
                             decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
                             navigationColor: UIColor.white,
                             separatorColor: UIColor.lightGray,
                             statusBarStyle: .default)
    
    static let lightJulius = Theme(color: UIColor(red: 0x2C, green: 0x28, blue: 0x29),
                                   backgroundColor: UIColor(hexString: "#000000")!,
                                   accentColor: UIColor(red: 0x2C, green: 0x28, blue: 0x29),
                                   decentColor: UIColor(red: 0x83, green: 0x83, blue: 0x83),
                                   navigationColor: UIColor(red: 0xDC, green: 0x39, blue: 0x32),
                                   separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
                                   statusBarStyle: .default)
    
    static let dark = Theme(color: UIColor.white,
                            backgroundColor: darkGray,
                            accentColor: yellow,
                            decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
                            navigationColor: UIColor.black,
                            separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
                            statusBarStyle: .lightContent)
    
}
