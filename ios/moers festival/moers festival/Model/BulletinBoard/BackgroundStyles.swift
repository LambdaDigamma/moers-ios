//
//  BackgroundStyle.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import BLTNBoard

func BackgroundStyles() -> [(name: String, style: BLTNBackgroundViewStyle)] {
    
    var styles: [(name: String, style: BLTNBackgroundViewStyle)] = [
        ("None", .none),
        ("Dimmed", .dimmed)
    ]
    
    if #available(iOS 10, *) {
        styles.append(("Extra Light", .blurredExtraLight))
        styles.append(("Light", .blurredLight))
        styles.append(("Dark", .blurredDark))
        styles.append(("Extra Dark", .blurred(style: UIBlurEffect.Style(rawValue: 3)!, isDark: true)))
    }
    
    return styles
    
}
