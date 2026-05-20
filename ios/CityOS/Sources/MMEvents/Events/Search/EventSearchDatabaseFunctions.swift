//
//  EventSearchDatabaseFunctions.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation
import GRDB

public enum EventSearchDatabaseFunctions {

    private static let normalizer = EventSearchTextNormalizer()

    public static func register(in db: Database) {
        db.add(function: normalizeSearchText)
        db.add(function: normalizeArtists)
    }

    public static func configuration(
        _ configuration: Configuration = Configuration()
    ) -> Configuration {
        var configuration = configuration
        configuration.prepareDatabase { db in
            register(in: db)
        }
        return configuration
    }

    private static let normalizeSearchText = DatabaseFunction(
        "mm_events_normalize_search_text",
        argumentCount: 1,
        pure: true
    ) { values in
        normalizer.normalize(String.fromDatabaseValue(values[0]) ?? "")
    }

    private static let normalizeArtists = DatabaseFunction(
        "mm_events_normalize_artists",
        argumentCount: 1,
        pure: true
    ) { values in
        normalizedArtists(from: values[0])
    }

    private static func normalizedArtists(
        from value: DatabaseValue
    ) -> String {

        guard let text = String.fromDatabaseValue(value), !text.isEmpty else {
            return ""
        }

        guard let data = text.data(using: .utf8) else {
            return normalizer.normalize(text)
        }

        if let artists = try? JSONDecoder().decode([String].self, from: data) {
            return normalizer.normalize(artists.joined(separator: " "))
        }

        if let artists = try? JSONDecoder().decode([String?].self, from: data) {
            return normalizer.normalize(artists.compactMap { $0 }.joined(separator: " "))
        }

        return normalizer.normalize(text)

    }

}
