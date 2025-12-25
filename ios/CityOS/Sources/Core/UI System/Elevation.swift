//
//  Elevation.swift
//  
//
//  Created by Lennart Fischer on 16.12.20.
//

import Foundation

public enum Elevation {
    case zero, one, two, three, four, five
    
    public var offset: CGSize {
        switch self {
            case .zero: return .zero
            case .one: return CGSize(width: 0, height: 2)
            case .two: return CGSize(width: 0, height: 4)
            case .three: return CGSize(width: 0, height: 6)
            case .four: return CGSize(width: 0, height: 8)
            case .five: return CGSize(width: 0, height: 10)
        }
    }
    
    public var radius: CGFloat {
        switch self {
            case .zero: return 0
            case .one: return 4
            case .two: return 6
            case .three: return 8
            case .four: return 10
            case .five: return 12
        }
    }
    
    public var opacity: Float {
        switch self {
            case .zero: return 0
            case .one: return 0.1
            case .two: return 0.15
            case .three: return 0.15
            case .four: return 0.2
            case .five: return 0.2
        }
    }
}

#if canImport(UIKit)

import UIKit

public extension UIView {
    func setElevation(to elevation: Elevation) {
        layer.shadowOffset = elevation.offset
        layer.shadowRadius = elevation.radius
        layer.shadowOpacity = elevation.opacity
    }
}

#endif
