//
//  Typography.swift
//  
//
//  Created by Lennart Fischer on 16.12.20.
//


//#if canImport(UIKit)
//
//import SwiftUI
//import UIKit
//
//public enum Typography {
//
//    public enum Family: String {
//        case display = "Display"
//        case rounded = "Rounded"
//        case serif = "Serif"
//
//        func font(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
//
//            let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
//
//            switch self {
//                case .display:
//                    return systemFont
//                case .rounded:
//                    if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
//                        return UIFont(descriptor: descriptor, size: size)
//                    } else {
//                        return systemFont
//                    }
//                case .serif:
//                    if let descriptor = systemFont.fontDescriptor.withDesign(.serif) {
//                        return UIFont(descriptor: descriptor, size: size)
//                    } else {
//                        return systemFont
//                    }
//            }
//        }
//
//    }
//
//    public enum Style {
//
//        case titleExtraLarge
//        case titleLarge
//        case subtitleLarge
//        case title
//        case subtitle
//        case headline
//        case body
//        case headlineSmall
//        case bodySmall
//        case caption
//        case footnote
//        case custom(size: CGFloat, weight: UIFont.Weight)
//
//        var size: CGFloat {
//            switch self {
//                case .titleExtraLarge:
//                    return 34
//                case .titleLarge, .subtitleLarge:
//                    return 24
//                case .title, .subtitle:
//                    return 18
//                case .headline, .body:
//                    return 16
//                case .headlineSmall, .bodySmall:
//                    return 14
//                case .caption, .footnote:
//                    return 12
//                case .custom(let size, _):
//                    return size
//            }
//        }
//
//        var weight: UIFont.Weight {
//            switch self {
//                case .subtitleLarge, .subtitle, .body, .bodySmall, .footnote:
//                    return .regular
//                case .titleExtraLarge, .titleLarge, .title, .headline, .headlineSmall, .caption:
//                    return .semibold
//                case .custom(_, let weight):
//                    return weight
//            }
//        }
//
//    }
//
//    public static func style(_ style: Typography.Style, _ fontFamily: Typography.Family = .display) -> Font {
//        return Font.style(style, fontFamily)
//    }
//
//}
//
//public extension UIFont {
//
//    static func font(ofSize size: CGFloat, weight: UIFont.Weight, font: UIFont) -> UIFont {
//        return fontMetrics(forSize: size).scaledFont(for: font)
//    }
//
//    private static func fontMetrics(forSize size: CGFloat) -> UIFontMetrics {
//
//        #if os(tvOS)
//        switch size {
//
//            case 34: return UIFontMetrics(forTextStyle: .title1)
//            case 24: return UIFontMetrics(forTextStyle: .title2)
//            case 18: return UIFontMetrics(forTextStyle: .title3)
//            case 14, 16: return UIFontMetrics(forTextStyle: .body)
//            case 12: return UIFontMetrics(forTextStyle: .footnote)
//            default: return UIFontMetrics.default
//        }
//        #else
//        switch size {
//            case 34: return UIFontMetrics(forTextStyle: .largeTitle)
//            case 24: return UIFontMetrics(forTextStyle: .title2)
//            case 18: return UIFontMetrics(forTextStyle: .title3)
//            case 14, 16: return UIFontMetrics(forTextStyle: .body)
//            case 12: return UIFontMetrics(forTextStyle: .footnote)
//            default: return UIFontMetrics.default
//        }
//        #endif
//
//    }
//
//}
//
//public extension Font {
//
//    static func style(_ style: Typography.Style, _ fontFamily: Typography.Family = .display) -> Font {
//        let staticFont = fontFamily.font(style.weight, size: style.size)
//        return Font(UIFont.font(ofSize: style.size, weight: style.weight, font: staticFont))
//    }
//
//}
//
//#endif
