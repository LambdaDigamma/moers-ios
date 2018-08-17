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
    
    let identifier: String
    let color: UIColor
    let backgroundColor: UIColor
    let navigationBarColor: UIColor
    let tabBarColor: UIColor
    let accentColor: UIColor
    let decentColor: UIColor
    let separatorColor: UIColor
    let statusBarStyle: UIStatusBarStyle
    let cardShadow: Bool
    let cardBackgroundColor: UIColor
    
    static private let darkGray = UIColor(red: 0.137, green: 0.122, blue: 0.125, alpha: 1.00)
    static private let yellow = UIColor(red: 1.000, green: 0.949, blue: 0.200, alpha: 1.00)
    
    static public let all: [Theme] = [dark, lightning, darkOrange/*, mono, red*/]
    
    static let dark = Theme(identifier: "Mein Moers",
                            color: UIColor.white,
                            backgroundColor: darkGray,
                            navigationBarColor: UIColor.black,
                            tabBarColor: UIColor.black,
                            accentColor: yellow,
                            decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
                            separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
                            statusBarStyle: .lightContent,
                            cardShadow: false,
                            cardBackgroundColor: darkGray.darker(by: 2)!)
    
    static let darkOrange = Theme(identifier: "Dark Orange",
                                  color: UIColor.white,
                                  backgroundColor: darkGray,
                                  navigationBarColor: UIColor.black,
                                  tabBarColor: UIColor.black,
                                  accentColor: UIColor.orange,
                                  decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
                                  separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
                                  statusBarStyle: .lightContent,
                                  cardShadow: false,
                                  cardBackgroundColor: darkGray.darker(by: 2)!)
    
    
    
    
    
    
    
//    static let light = Theme(color: UIColor.black,
//                             backgroundColor: UIColor(red: 0.980, green: 0.980, blue: 0.980, alpha: 1.00),
//                             navigationBarColor: UIColor.white,
//                             tabBarColor: UIColor.white,
//                             accentColor: UIColor.blue,
//                             decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
//                             separatorColor: UIColor.lightGray,
//                             statusBarStyle: .default,
//                             cardShadow: true)
    
    static let lightning = Theme(identifier: "Lightning",
                                 color: UIColor.black,
                                 backgroundColor: UIColor.white,
                                 navigationBarColor: UIColor.white,
                                 tabBarColor: UIColor.white,
                                 accentColor: UIColor(hexString: "#C0392B")!,
                                 decentColor: UIColor.lightGray,
                                 separatorColor: UIColor.lightGray,
                                 statusBarStyle: .default,
                                 cardShadow: true,
                                 cardBackgroundColor: UIColor.white)
    
    static let mono = Theme(identifier: "Mono",
                            color: UIColor.black,
                            backgroundColor: UIColor.white,
                            navigationBarColor: UIColor.black,
                            tabBarColor: UIColor.black,
                            accentColor: UIColor.white,
                            decentColor: UIColor.lightGray,
                            separatorColor: UIColor.lightGray,
                            statusBarStyle: .lightContent,
                            cardShadow: true,
                            cardBackgroundColor: UIColor.white)
    
    static let red = Theme(identifier: "Red",
                          color: UIColor.black,
                          backgroundColor: UIColor.white,
                          navigationBarColor: UIColor(hexString: "#424242")!,
                          tabBarColor: UIColor(hexString: "#424242")!,
                          accentColor: UIColor.white,
                          decentColor: UIColor.lightGray,
                          separatorColor: UIColor.lightGray,
                          statusBarStyle: .lightContent,
                          cardShadow: true,
                          cardBackgroundColor: UIColor.white)
    
//    static let lightJulius = Theme(color: UIColor(red: 0x2C, green: 0x28, blue: 0x29),
//                                   backgroundColor: UIColor(hexString: "#000000")!,
//                                   navigationBarColor: UIColor(red: 0xDC, green: 0x39, blue: 0x32),
//                                   tabBarColor: UIColor.white,
//                                   accentColor: UIColor(red: 0x2C, green: 0x28, blue: 0x29),
//                                   decentColor: UIColor(red: 0x83, green: 0x83, blue: 0x83),
//                                   separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
//                                   statusBarStyle: .default,
//                                   cardShadow: true)
    
    
    
    
    
}
