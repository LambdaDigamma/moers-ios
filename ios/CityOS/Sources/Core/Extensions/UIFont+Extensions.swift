//
//  UIFont+Extensions.swift
//  
//
//  Created by Lennart Fischer on 14.09.21.
//

#if canImport(UIKit)
import UIKit

extension UIFont {
    
    public static func preferredFont(
        for style: TextStyle,
        weight: Weight,
        compatibleWith traitCollection: UITraitCollection? = nil
    ) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traitCollection)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
    
}

#endif
