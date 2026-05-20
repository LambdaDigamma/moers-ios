//
//  EventSearchViewDefinition.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation
import GRDB

public enum EventSearchViewDefinition {

    public static let viewName = "event_search_view"

    public static func createIfNeeded(in db: Database) throws {
        try db.execute(sql: """
        CREATE VIEW IF NOT EXISTS \(viewName) AS
        SELECT
            e.id AS event_id,
            mm_events_normalize_search_text(e.name) AS normalized_name,
            mm_events_normalize_artists(e.artists) AS normalized_artists,
            mm_events_normalize_search_text(p.name) AS normalized_place_name
        FROM events e
        LEFT JOIN places p ON p.id = e.place_id
        """)
    }

}
