//
//  PageRepository.swift
//  
//
//  Created by Lennart Fischer on 07.04.23.
//

import Foundation
import GRDB
import Combine
import Factory

public extension Container {
    var pageRepository: Factory<PageRepository> {
        Factory(self) {
            
            guard let dbQueue = try? DatabaseQueue(path: ":memory:") else { fatalError() }
            
            return PageRepository(
                service: MockPageService(result: .success(Page.stub(withID: 1))),
                store: .init(writer: dbQueue, reader: dbQueue)
            )
            
        }.singleton
    }
}

public class PageRepository {
    
    public let service: PageService
    public let store: PageStore
    
    public init(
        service: PageService,
        store: PageStore
    ) {
        self.service = service
        self.store = store
    }
    
    // MARK: - UI Sources
    
    public func pagePublisher(pageID: Page.ID) -> AnyPublisher<Page?, Error> {

        let pageObserver = store.pageObserver(pageID: pageID)
        let contentObserver = store.pageContentObserver(pageID: pageID)
        
        return Publishers
            .Zip(pageObserver, contentObserver)
            .map { (pageRecord: PageRecord?, pageBlocks: [PageBlockRecord]) -> Page? in
                
                if let pageRecord {
                    var page = pageRecord.toBase()
                    page.blocks = pageBlocks.map { $0.toBase() }
                    return page
                }
                
                return nil
                
            }
            .eraseToAnyPublisher()
        
    }
    
    // MARK: - Networking
    
    /// Refreshes the page while skipping all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    public func refreshPage(for pageID: Page.ID) async throws {
        
        let resource = try await service.show(for: pageID, cacheMode: .revalidate)
        
        try await updateStore(page: resource.data)
        
    }
    
    /// Reloads the page while going through all client cache layers
    /// and writes all new data to disk so that the database observation
    /// as the single source of truth can reload the user interface.
    ///
    /// It throws an error when an error occurs while loading the
    /// data from the network.
    public func reloadPage(for pageID: Page.ID) async throws {
        
        let resource = try await service.show(for: pageID, cacheMode: .cached)
        
        try await updateStore(page: resource.data)
        
    }
    
    // MARK: - Database Handling
    
    /// Write the page and its page blocks to disk.
    ///
    /// Throws any errors from the underlying database implementation.
    private func updateStore(page: Page) async throws {
        
        try await store.updateOrCreate([page.toRecord()])
        try await store.updateOrCreate(page.blocks.map { $0.toRecord() })
        
    }
    
}
