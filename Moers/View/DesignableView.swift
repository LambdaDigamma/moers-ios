//
//  DesignableView.swift
//  Moers
//
//  Created by Lennart Fischer on 17.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {

    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        
        didSet {
            
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            
        }
        
    }

}
