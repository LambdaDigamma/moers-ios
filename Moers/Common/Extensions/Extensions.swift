//
//  Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import MMAPI
import MMCommon

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

extension UIViewController {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.topAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.leadingAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.trailingAnchor
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
