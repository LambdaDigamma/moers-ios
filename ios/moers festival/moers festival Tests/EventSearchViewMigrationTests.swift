//
//  EventSearchViewMigrationTests.swift
//  moers festival Tests
//
//  Created by Codex on 20.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import GRDB
import MMEvents
import XCTest
@testable import moers_festival

final class EventSearchViewMigrationTests: XCTestCase {

    func testAppDatabaseMigrationCreatesEventSearchViewSchema() throws {
        let databaseQueue = try makeDatabaseQueue()

        _ = try AppDatabase(databaseQueue)

        let schema = try databaseQueue.read { db in
            let viewNames = try String.fetchAll(
                db,
                sql: "SELECT name FROM sqlite_master WHERE type = 'view'"
            )
            let columns = try Row.fetchAll(
                db,
                sql: "PRAGMA table_info(\(EventSearchViewDefinition.viewName))"
            )

            return (
                viewNames: Set(viewNames),
                columns: Set(columns.compactMap { $0["name"] as String? })
            )
        }

        XCTAssertTrue(schema.viewNames.contains(EventSearchViewDefinition.viewName))
        XCTAssertEqual(
            schema.columns,
            [
                "event_id",
                "normalized_name",
                "normalized_artists",
                "normalized_place_name"
            ]
        )
    }

    func testAppDatabaseMigrationDerivesSearchValuesFromExistingCachedEvents() throws {
        let databaseQueue = try makeDatabaseQueue()
        let migrator = try AppDatabase(makeDatabaseQueue()).migrator

        try migrator.migrate(databaseQueue, upTo: "events_search_like_indexes")

        try databaseQueue.write { db in
            try db.execute(
                sql: """
                INSERT INTO places (id, name, latitude, longitude)
                VALUES (?, ?, ?, ?)
                """,
                arguments: [1, "Gellért Straße Stage", 51.451, 6.631]
            )
            _ = try Event(
                id: 10,
                name: "Cached Migration Title",
                artists: ["Straße Artist"],
                placeID: 1
            )
            .toRecord()
            .inserted(db)
        }

        try migrator.migrate(databaseQueue)

        let row = try databaseQueue.read { db in
            try Row.fetchOne(
                db,
                sql: """
                SELECT normalized_name, normalized_artists, normalized_place_name
                FROM \(EventSearchViewDefinition.viewName)
                WHERE event_id = ?
                """,
                arguments: [10]
            )
        }

        let searchRow = try XCTUnwrap(row)
        XCTAssertEqual(searchRow["normalized_name"] as String?, "cached migration title")
        XCTAssertEqual(searchRow["normalized_artists"] as String?, "strasse artist")
        XCTAssertEqual(searchRow["normalized_place_name"] as String?, "gellert strasse stage")

        try databaseQueue.write { db in
            try db.execute(
                sql: "UPDATE events SET name = ?, artists = ? WHERE id = ?",
                arguments: ["Updated Migration Title", #"["Updated Artist"]"#, 10]
            )
            try db.execute(
                sql: "UPDATE places SET name = ? WHERE id = ?",
                arguments: ["Updated Bühne", 1]
            )
        }

        let updatedRow = try databaseQueue.read { db in
            try Row.fetchOne(
                db,
                sql: """
                SELECT normalized_name, normalized_artists, normalized_place_name
                FROM \(EventSearchViewDefinition.viewName)
                WHERE event_id = ?
                """,
                arguments: [10]
            )
        }

        let updatedSearchRow = try XCTUnwrap(updatedRow)
        XCTAssertEqual(updatedSearchRow["normalized_name"] as String?, "updated migration title")
        XCTAssertEqual(updatedSearchRow["normalized_artists"] as String?, "updated artist")
        XCTAssertEqual(updatedSearchRow["normalized_place_name"] as String?, "updated buhne")
    }

    private func makeDatabaseQueue() throws -> DatabaseQueue {
        let configuration = EventSearchDatabaseFunctions.configuration()
        return try DatabaseQueue(configuration: configuration)
    }

}
