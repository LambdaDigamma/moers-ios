//
//  Extensions.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import CoreLocation

func isSnapshotting() -> Bool {
    return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
}

extension String {
    
    static func localized(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
        
    }
    
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: "Localizable",
                                 bundle: Bundle.main,
                                 value: "Not found",
                                 comment: "")
    }
    
    func localized(in tableName: String = "Localizable") -> String {
        return NSLocalizedString(self,
                                 tableName: tableName,
                                 bundle: Bundle.main,
                                 value: "Not found",
                                 comment: "")
    }
    
}

extension UIViewController {
    
    public var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.topAnchor
        }
    }

    public var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }
    
}

extension UIButton {
    
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
        
    }
    
}

extension UISearchBar {
    
    var textField: UITextField? {
        return self.value(forKey: "searchField") as? UITextField
    }
    
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}
