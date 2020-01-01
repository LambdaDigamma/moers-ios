//
//  Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar {
    
    var textField: UITextField? {
        return self.value(forKey: "searchField") as? UITextField
    }
    
}


extension Bundle {
    
    private var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    private var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    var bundleID: String {
        return Bundle.main.bundleIdentifier?.lowercased() ?? ""
    }
    
    var versionString: String {
        var scheme = ""
        
        if bundleID.contains(".dev") {
            scheme = "Dev"
        } else if bundleID.contains(".staging") {
            scheme = "Staging"
        }
        
        let returnValue = "Version \(releaseVersionNumber) (\(buildVersionNumber)) \(scheme)"
        
        return returnValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

public extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
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
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.leadingAnchor
        } else {
            return view.leadingAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.trailingAnchor
        } else {
            return view.trailingAnchor
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

protocol Formattable {
    func format(pattern: String) -> String
}
extension Formattable where Self: CVarArg {
    func format(pattern: String) -> String {
        return String(format: pattern, arguments: [self])
    }
}
extension Int: Formattable { }
extension Double: Formattable { }
extension Float: Formattable { }

func prettifyDistance(distance: Double) -> String {
    
    if distance >= 1000 {
        return Double(distance / 1000).format(pattern: "%.1f") + "km"
    } else {
        return "\(Int(distance))m"
    }
    
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
