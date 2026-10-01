//
//  PageRepositoryTests.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation
import XCTest
import GRDB
import ModernNetworking
@testable import MMPages

@MainActor
public final class PageRepositoryTests: XCTestCase {
    
    func testLoadNetworkNotPresentInDatabase() async throws {
        
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Show", withExtension: "json"))
        
        let service: PageService = DefaultPageService(client: try FixtureHTTPClient(url: url))
        let store = PageStore.inMemory().store
        
        let repository = PageRepository(
            service: service,
            store: store
        )
        
        try await repository.refreshPage(for: 1)
        
        let blocks = try await store.fetchBlocks(for: 1)
        
        XCTAssertEqual(blocks.count, 3)
        
    }
    
}
