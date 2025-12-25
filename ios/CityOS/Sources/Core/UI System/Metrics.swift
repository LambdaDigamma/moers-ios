//
//  Metrics.swift
//  
//
//  Created by Lennart Fischer on 16.12.20.
//

import Foundation

public extension CGFloat {
    static let tightMargin: CGFloat = 4
    static let standardMargin: CGFloat = 8
    static let mediumMargin: CGFloat = 12
    static let wideMargin: CGFloat = 16
    static let extraWideMargin: CGFloat = 20
}

public enum Margin {
    
    /// This is the equivalent of 4
    public static let tight = CGFloat.tightMargin
    
    /// This is the equivalent of 8
    public static let standard = CGFloat.standardMargin
    
    /// This is the equivalent of 12
    public static let medium = CGFloat.mediumMargin
    
    /// This is the equivalent of 16
    public static let wide = CGFloat.wideMargin
    
    /// This is the equivalent of 20
    public static let extraWide = CGFloat.extraWideMargin
}

#if canImport(UIKit)

import UIKit

public extension UIEdgeInsets {
    
    init(uniform: CGFloat) {
        self.init(top: uniform, left: uniform, bottom: uniform, right: uniform)
    }
    
    static let tightMargin: UIEdgeInsets = .init(uniform: .tightMargin)
    static let standardMargin: UIEdgeInsets = .init(uniform: .standardMargin)
    static let mediumMargin: UIEdgeInsets = .init(uniform: .mediumMargin)
    static let wideMargin: UIEdgeInsets = .init(uniform: .wideMargin)
    static let extraWideMargin: UIEdgeInsets = .init(uniform: .extraWideMargin)
    
}

#endif
