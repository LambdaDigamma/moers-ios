//
//  DefaultPostServiceTests.swift
//  
//
//  Created by Lennart Fischer on 10.01.21.
//

import Foundation
import XCTest
import ModernNetworking
import Combine
import Cache
@testable import MMFeeds


@MainActor
final class DefaultPostServiceTests: XCTestCase {
    
    func testIndex() async throws {
        
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Index", withExtension: "json"))
        
        let service: PostService = DefaultPostService(client: try FixtureHTTPClient(url: url))

        let posts = try await service.index(for: 1, page: 1, perPage: 10, cacheMode: .cached)
        
        XCTAssertEqual(posts.data.count, 10)
        XCTAssertEqual(posts.meta.currentPage, 1)
        XCTAssertEqual(posts.meta.from, 1)
        
    }
    
    func testShow() async throws {
        
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Show", withExtension: "json"))
        
        let service: PostService = DefaultPostService(client: try FixtureHTTPClient(url: url))

        let post = try await service.show(for: 1, cacheMode: .reload)
        
        XCTAssertEqual(post.data.title, "Volunteers gesucht!")
        
    }
    
}
