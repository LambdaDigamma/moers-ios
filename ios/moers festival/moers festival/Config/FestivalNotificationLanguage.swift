//
//  FestivalNotificationLanguage.swift
//  moers festival
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation

nonisolated enum FestivalNotificationLanguage: Equatable {
    case german
    case english

    var topic: String {
        switch self {
            case .german:
                return "all_de"
            case .english:
                return "all_en"
        }
    }

    static var current: FestivalNotificationLanguage {
        return from(languageIdentifier: Bundle.main.preferredLocalizations.first)
    }

    static var languageTopics: Set<String> {
        return Set([german.topic, english.topic])
    }

    static func from(languageIdentifier: String?) -> FestivalNotificationLanguage {
        guard let languageCode = languageIdentifier?
            .split(separator: "-")
            .first?
            .lowercased() else {
            return .english
        }

        switch languageCode {
            case "de":
                return .german
            default:
                return .english
        }
    }
}
