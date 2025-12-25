//
//  PageStore.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import Foundation
import GRDB
import Factory
import Combine

public class PageStore {
    
    private let writer: DatabaseWriter
    private let reader: DatabaseReader
    
    public init(
        writer: DatabaseWriter,
        reader: DatabaseReader
    ) {
        self.writer = writer
        self.reader = reader
    }
    
    // MARK: - Pages
    
    public func fetch() async throws -> [PageRecord] {
        
        try await reader.read { db in
            return try PageRecord
                .order(PageRecord.Columns.publishedAt.desc)
                .fetchAll(db)
        }
        
    }
    
    public func fetch() -> AnyPublisher<[PageRecord], Error> {
        
        reader.readPublisher { db in
            return try PageRecord
                .order(PageRecord.Columns.publishedAt.desc)
                .fetchAll(db)
        }.eraseToAnyPublisher()
        
    }
    
    public func show(pageID: Page.ID) async throws -> PageRecord {
        
        try await reader.read({ db in
            
            return try PageRecord.find(db, key: pageID)
            
        })
        
    }
    
    public func insert(_ page: PageRecord) async throws -> PageRecord {
        
        try await writer.write { db in
            return try page.inserted(db)
        }
        
    }
    
    @discardableResult
    public func updateOrCreate(_ pages: [PageRecord]) async throws -> [PageRecord] {
        
        try await writer.write({ db in
            
            var updatedPages: [PageRecord] = []
            
            for page in pages {
                updatedPages.append(try page.inserted(db, onConflict: .replace))
            }
            
            return updatedPages
            
        })
        
    }
    
    public func delete(_ page: PageRecord) async throws -> Bool {
        
        try await writer.write { db in
            return try page.delete(db)
        }
        
    }
    
    public func pageContentObserver(pageID: Page.ID) -> AnyPublisher<[PageBlockRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PageBlockRecord
                    .filter(PageBlockRecord.Columns.pageID == pageID)
                    .order(PageBlockRecord.Columns.order.ascNullsLast)
                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
    public func pageObserver(pageID: Page.ID) -> AnyPublisher<PageRecord?, Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PageRecord
                    .filter(key: pageID.databaseValue)
                    .fetchOne(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
    public func changeObserver() -> AnyPublisher<[PageRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PageRecord
                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
    // MARK: - Block
    
    public func fetchBlocks(for pageID: Page.ID) async throws -> [PageBlockRecord] {

        try await reader.read { db in
            return try PageBlockRecord
                .order(PageBlockRecord.Columns.publishedAt.desc)
                .filter(PageBlockRecord.Columns.pageID == pageID)
                .fetchAll(db)
        }
        
    }
    
    public func insert(_ pageBlock: PageBlockRecord) async throws -> PageBlockRecord {
        
        try await writer.write { db in
            return try pageBlock.inserted(db)
        }
        
    }
    
    @discardableResult
    public func updateOrCreate(_ pageBlocks: [PageBlockRecord]) async throws -> [PageBlockRecord] {
        
        try await writer.write({ db in
            
            var updated: [PageBlockRecord] = []
            
            for pageBlock in pageBlocks {
                updated.append(try pageBlock.inserted(db, onConflict: .replace))
            }
            
            return updated
            
        })
        
    }
    
}
