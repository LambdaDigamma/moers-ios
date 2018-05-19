//
//  CardView.swift
//  Moers
//
//  Created by Lennart Fischer on 10.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import QuartzCore
import Gestalt

class CardView: UIView {

    public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.applyTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            self.cornerRadius = 12.0
            
            if theme.cardShadow {
                
                self.clipsToBounds = false
                self.shadowColor = UIColor.lightGray
                self.shadowOpacity = 0.6
                self.shadowRadius = 10.0
                self.shadowOffset = CGSize(width: 0, height: 0)
                
            }
            
        }
        
    }
    
}
