//
//  NavigationBarPalette.swift
//
//
//  Created by Claude on 24.10.26.
//

#if !os(tvOS)

import Obfuscation
import UIKit

/// Hosts a view in the navigation bar's bottom palette, like the Fitness+ filter bubbles.
///
/// This uses private UIKit API. Names are obfuscated with `#Obfuscate` and every call is guarded,
/// so a missing symbol degrades to "no palette" instead of crashing.
public enum NavigationBarPalette {

    public static func make(contentView: UIView, preferredHeight: CGFloat) -> UIView? {
        let paletteClass = NSClassFromString(#Obfuscate("_UINavigationBarPalette")) as? UIView.Type
        let initSelector = NSSelectorFromString(#Obfuscate("initWithContentView:"))

        guard let paletteClass, paletteClass.instancesRespond(to: initSelector) else { return nil }

        let allocated = paletteClass.perform(NSSelectorFromString("alloc"))?.takeRetainedValue()
        let palette = allocated?.perform(initSelector, with: contentView)?.takeUnretainedValue() as? UIView
        palette?.clipsToBounds = false

        if let palette {
            setPreferredHeight(preferredHeight, of: palette)
        }

        return palette
    }

    public static func setPreferredHeight(_ height: CGFloat, of palette: UIView) {
        let selector = NSSelectorFromString(#Obfuscate("setPreferredHeight:"))
        guard palette.responds(to: selector) else { return }

        // The selector takes a CGFloat, which `perform(_:with:)` cannot pass.
        typealias Setter = @convention(c) (AnyObject, Selector, CGFloat) -> Void
        let implementation = palette.method(for: selector)
        unsafeBitCast(implementation, to: Setter.self)(palette, selector, height)
    }

}

extension UINavigationItem {

    public var timetableBottomPalette: UIView? {
        get {
            let key = #Obfuscate("_bottomPalette")
            guard responds(to: NSSelectorFromString(key)) else { return nil }
            return value(forKey: key) as? UIView
        }
        set {
            let selector = NSSelectorFromString(#Obfuscate("_setBottomPalette:"))
            guard responds(to: selector) else { return }
            perform(selector, with: newValue)
        }
    }

}

#endif
