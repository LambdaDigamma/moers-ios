//
//  PostStore.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import XCTest
import GRDB
import MediaLibraryKit
@testable import MMFeeds

public final class PostStoreTests: XCTestCase {
    
    public var writer: DatabaseWriter!
    public var store: PostStore!
    
    public override func setUp() {
        
        guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("migrate") { db in
            
            try db.create(table: "posts", body: { (tableDefinition: TableDefinition) in
                PostTableDefinition.apply(tableDefinition)
            })
            
        }
        
        try? migrator.migrate(dbQueue)
        
        self.writer = dbQueue
        self.store = PostStore(writer: writer, reader: writer)
        
    }
    
    public func testStore() async throws {
        
        let _ = try await store.insert(
            PostRecord(id: 1, title: "Test Record", summary: "Summary")
        )
        
        try await writer.read { db in
            XCTAssertTrue(try PostRecord.exists(db, key: 1))
        }
        
    }
    
    public func testFetch() async throws {
        
        let mediaCollection = MediaCollectionsContainer(collections: [
            "header": [
                Media(
                    id: 1,
                    modelType: "posts",
                    modelID: 1,
                    uuid: UUID(uuidString: "51F5406B-08EE-4517-AB1D-8ADFAF2D35F0"),
                    collectionName: "header",
                    fullURL: nil,
                    name: "posts1.png",
                    fileName: "posts1.png",
                    size: 1000,
                    alt: nil,
                    caption: nil,
                    credits: nil
                )
            ]
        ])
        
        let records = [
            PostRecord(title: "1", summary: "1",
                       pageID: 5,
                       publication: Publication(order: 4, createdAt: Date(), updatedAt: Date()),
                       publishedAt: Date(timeIntervalSinceNow: -60 * 60 * 5),
                       mediaCollections: mediaCollection
                      ),
            PostRecord(title: "2", summary: "2", publishedAt: Date(timeIntervalSinceNow: -60 * 60 * 8)),
            PostRecord(title: "3", summary: "3", publishedAt: Date(timeIntervalSinceNow: -60 * 60 * 10)),
            PostRecord(title: "4", summary: "4", publishedAt: Date(timeIntervalSinceNow: -60 * 60 * 1)),
        ]
        
        try await store.updateOrCreate(records)
        
        let fetched = try await store.fetch()
        
        XCTAssertEqual(fetched[0].title, "4")
        XCTAssertEqual(fetched[1].pageID, 5)
        XCTAssertEqual(fetched[1].title, "1")
        XCTAssertNotNil(fetched[1].mediaCollections?.getFirstMedia(for: "header"))
        XCTAssertNotNil(fetched[1].publication)
        XCTAssertEqual(fetched[2].title, "2")
        XCTAssertEqual(fetched[3].title, "3")
        
    }
    
}
