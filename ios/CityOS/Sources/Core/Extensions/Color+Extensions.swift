//
//  Color+Extensions.swift
//  
//
//  Created by Lennart Fischer on 03.02.22.
//

import SwiftUI

// from https://stackoverflow.com/questions/56874133/use-hex-color-in-swiftui#56874327
public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if canImport(UIKit)

import UIKit

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
            case 3:
                chars = chars.flatMap { [$0, $0] }
                fallthrough
            case 6:
                chars = ["F","F"] + chars
                fallthrough
            case 8:
                alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
                red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
                green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
                blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
            default:
                return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(
                red: min(r + percentage / 100, 1.0),
                green: min(g + percentage / 100, 1.0),
                blue: min(b + percentage / 100, 1.0),
                alpha: a
            )
        } else {
            return nil
        }
    }
    
}

#endif
