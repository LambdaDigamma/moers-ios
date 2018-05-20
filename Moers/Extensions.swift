//
//  Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation

#if os(OSX)
    
    import Cocoa
    public  typealias PXColor = NSColor
    
#else
    
    import UIKit
    public  typealias PXColor = UIColor
    
#endif

extension String {
    
    var doubleValue: Double {
        
        get {
            
            let s: NSString = self as NSString
            
            return s.doubleValue
            
        }
        
    }
    
    static func localized(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
        
    }
    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
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
    
}

extension Date {
    
    func format(format: String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "DE_de")
        dateFormatter.dateFormat = format
        let date = dateFormatter.string(from: self)
        
        return date
        
    }
    
    static func from(_ dateString: String, withFormat format: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "DE_de")
        
        let date = dateFormatter.date(from: dateString)
        
        return date
        
    }
    
}


struct AppColor {
    
    static let yellow = UIColor(red: 0xFF, green: 0xEB, blue: 0x3B)
    
}

extension UISearchBar {
    
    var textField: UITextField? {
        return self.value(forKey: "searchField") as? UITextField
    }
    
}

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: min(r + percentage / 100, 1.0),
                           green: min(g + percentage / 100, 1.0),
                           blue: min(b + percentage / 100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
}

extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.topAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }
}

extension UIImage {
    
    class func imageResize(imageObj: UIImage, size: CGSize, scaleFactor: CGFloat) -> UIImage? {
        
        let hasAlpha = true
        let scale: CGFloat = 6.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        
        imageObj.draw(in: CGRect(origin: CGPoint(x: (size.width / 2) - (size.width * scaleFactor) / 2, y: (size.height / 2) - (size.height * scaleFactor) / 2), size: CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext() // !!!
        return scaledImage
    }
    
}

public extension String {
    
    func score(_ word: String, fuzziness: Double? = nil) -> Double
    {
        // If the string is equal to the word, perfect match.
        if self == word {
            return 1
        }
        
        //if it's not a perfect match and is empty return 0
        if word.isEmpty || self.isEmpty {
            return 0
        }
        
        var
        runningScore = 0.0,
        charScore = 0.0,
        finalScore = 0.0,
        string = self,
        lString = string.lowercased(),
        strLength = string.count,
        lWord = word.lowercased(),
        wordLength = word.count,
        idxOf: String.Index!,
        startAt = lString.startIndex,
        fuzzies = 1.0,
        fuzzyFactor = 0.0,
        fuzzinessIsNil = true
        
        // Cache fuzzyFactor for speed increase
        if let fuzziness = fuzziness {
            fuzzyFactor = 1 - fuzziness
            fuzzinessIsNil = false
        }
        
        for i in 0 ..< wordLength {
            // Find next first case-insensitive match of word's i-th character.
            // The search in "string" begins at "startAt".
            if let range = lString.range(
                of: String(lWord[lWord.index(lWord.startIndex, offsetBy: i)] as Character),
                options: NSString.CompareOptions.caseInsensitive,
                range: Range<String.Index>(startAt..<lString.endIndex),
                locale: nil
                ) {
                // start index of word's i-th character in string.
                idxOf = range.lowerBound
                if startAt == idxOf {
                    // Consecutive letter & start-of-string Bonus
                    charScore = 0.7
                }
                else {
                    charScore = 0.1
                    
                    // Acronym Bonus
                    // Weighing Logic: Typing the first character of an acronym is as if you
                    // preceded it with two perfect character matches.
                    if string[string.index(idxOf, offsetBy: -1)] == " " {
                        charScore += 0.8
                    }
                }
            }
            else {
                // Character not found.
                if fuzzinessIsNil {
                    // Fuzziness is nil. Return 0.
                    return 0
                }
                else {
                    fuzzies += fuzzyFactor
                    continue
                }
            }
            
            // Same case bonus.
            if (string[idxOf] == word[word.index(word.startIndex, offsetBy: i)]) {
                charScore += 0.1
            }
            
            // Update scores and startAt position for next round of indexOf
            runningScore += charScore
            startAt = string.index(idxOf, offsetBy: 1)
        }
        
        // Reduce penalty for longer strings.
        finalScore = 0.5 * (runningScore / Double(strLength) + runningScore / Double(wordLength)) / fuzzies
        
        if (lWord[lWord.startIndex] == lString[lString.startIndex]) && (finalScore < 0.85) {
            finalScore += 0.15
        }
        
        return finalScore
    }
    
}

public struct Math {
    
    public static func sigmoid(x: CGFloat) -> CGFloat {
        
        return CGFloat(1 / (1 + pow(M_E, Double(-x))))
        
    }
    
}
