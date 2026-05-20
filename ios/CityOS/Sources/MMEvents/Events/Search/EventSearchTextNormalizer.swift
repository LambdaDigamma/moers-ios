//
//  EventSearchTextNormalizer.swift
//
//
//  Created by Codex on 19.05.26.
//

import Foundation

public struct EventSearchTextNormalizer: Sendable {

    private static let replacementPairs: [(String, String)] = [
        ("Æ", "AE"),
        ("æ", "ae"),
        ("Œ", "OE"),
        ("œ", "oe"),
        ("Ø", "O"),
        ("ø", "o"),
        ("Ł", "L"),
        ("ł", "l"),
        ("Ð", "D"),
        ("ð", "d"),
        ("Đ", "D"),
        ("đ", "d"),
        ("ß", "ss")
    ]

    public init() {}

    public func normalize(_ text: String) -> String {

        let replacedText = Self.replacementPairs.reduce(text) { currentText, replacement in
            currentText.replacingOccurrences(of: replacement.0, with: replacement.1)
        }

        let foldedText = replacedText
            .folding(
                options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
                locale: Locale(identifier: "de_DE")
            )
            .lowercased()

        return foldedText
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")

    }

}
