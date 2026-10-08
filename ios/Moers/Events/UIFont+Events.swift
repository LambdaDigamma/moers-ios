//
//  UIFont+Events.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

extension UIFont {

    static func mmEventPreferredFont(forTextStyle textStyle: TextStyle, weight: Weight) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)

        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }

}
