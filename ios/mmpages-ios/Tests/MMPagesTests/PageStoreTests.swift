//
//  PageStoreTests.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import XCTest
import GRDB
@testable import MMPages

public final class PageStoreTests: XCTestCase {
    
    public var writer: DatabaseWriter!
    public var store: PageStore!
    
    public override func setUp() {
        
        guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
        
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("migrate") { db in
            
            try db.create(table: "pages", body: { (tableDefinition: TableDefinition) in
                PageTableDefinition.apply(tableDefinition)
            })
            
            try db.create(table: "page_blocks", body: { (tableDefinition: TableDefinition) in
                PageBlockTableDefinition.apply(tableDefinition)
            })
            
        }
        
        try? migrator.migrate(dbQueue)
        
        self.writer = dbQueue
        self.store = PageStore(writer: writer, reader: writer)
        
    }
    
    public func testStorePage() async throws {
        
        let page = Page.stub(withID: 1).toRecord()
        
        let _ = try await store.insert(
            page
        )
        
        try await writer.read { db in
            XCTAssertTrue(try PageRecord.exists(db, key: 1))
        }
        
    }
    
    public func testStorePageBlock() async throws {
        
        let pageBlock = PageBlock.stub(withID: 1).toRecord()
        
        let _ = try await store.insert(
            pageBlock
        )
        
        try await writer.read { db in
            XCTAssertTrue(try PageBlockRecord.exists(db, key: 1))
        }
        
    }
    
    public func testStoreAndRetrievePage() async throws {
        
        let page = Page.stub(withID: 1)
        
        let _ = try await store.insert(
            page.toRecord()
        )
        
        let loaded = try await store.show(pageID: 1)
        
        XCTAssertEqual(loaded.id, page.id.toInt64())
        
    }
    
    public func testLoadingBlocksForPage() async throws {
        
        let otherPage = Page.stub(withID: 8)
        let otherBlocks = (8..<12)
            .map { id in PageBlock.stub(withID: id).setting(\.pageID, to: otherPage.id).toRecord() }
        
        try await store.updateOrCreate(otherBlocks)
        
        let page = Page.stub(withID: 4)
        let blocks = (1..<4)
            .map { id in
                PageBlock
                    .stub(withID: id)
                    .setting(\.pageID, to: page.id)
                    .toRecord()
            }
        
        try await store.updateOrCreate(blocks)
        
        try await writer.read { db in
            
            XCTAssertEqual(try PageBlockRecord.fetchCount(db), 7)
            
            for id in blocks.map({ $0.id }) {
                XCTAssertTrue(try PageBlockRecord.exists(db, key: id))
            }
            
        }
        
        let fetchedBlocks = try await store.fetchBlocks(for: page.id)
        
        XCTAssertEqual(fetchedBlocks.map { $0.id }, [1, 2, 3])
        
        let otherFetchedBlocks = try await store.fetchBlocks(for: otherPage.id)
        
        XCTAssertEqual(otherFetchedBlocks.map { $0.id }, [8, 9, 10, 11])
        
    }
    
}
