//
//  UIFont+Events.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

extension UIFont {

    static func mmEventPreferredFont(
        forTextStyle textStyle: TextStyle,
        weight: Weight,
        compatibleWith traitCollection: UITraitCollection? = nil
    ) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(
            withTextStyle: textStyle,
            compatibleWith: traitCollection
        )
        var traits = descriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any] ?? [:]
        traits[.weight] = weight.rawValue
        return UIFont(descriptor: descriptor.addingAttributes([.traits: traits]), size: 0)
    }

}
