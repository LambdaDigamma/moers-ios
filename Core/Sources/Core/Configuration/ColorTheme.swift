//
//  ColorTheme.swift
//  Moers
//
//  Created by Lennart Fischer on 18.08.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit

public enum ColorTheme {
    
    public static let accentColor: UIColor = {
        return UIColor { (traitCollection: UITraitCollection) in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.systemYellow
            } else {
                return UIColor.systemBlue
            }
        }
    }()
    
    public static let onAccentColor: UIColor = {
        return UIColor { (traitCollection: UITraitCollection) in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.black
            } else {
                return UIColor.white
            }
        }
    }()
    
}
