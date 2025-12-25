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


final class DefaultPostServiceTests: XCTestCase {
    
    func testIndex() async throws {
        
        let url = ResourcesFinder(file: #file).baseURL()?
            .appendingPathComponent("Tests/MMFeedsTests/Resources/Fixtures/Post/Index.json")
        
        let loader = FixtureFileLoader(
            fixtureURL: url
        )
        
        var request = DefaultPostService.indexRequest(
            feedID: 1,
            page: 1,
            perPage: 10
        )
        
        request.host = "archiv.moers-festival.de"
        request.path = "/api/v1/" + request.path
        
        loader.fixtureRequest = request
        
        let service: PostService = DefaultPostService(loader)
        
        let posts = try await service.index(for: 1, page: 1, perPage: 10, cacheMode: .cached)
        
        XCTAssertEqual(posts.data.count, 10)
        XCTAssertEqual(posts.meta.currentPage, 1)
        XCTAssertEqual(posts.meta.from, 1)
        
    }
    
    func testShow() async throws {
        
        let url = ResourcesFinder(file: #file).baseURL()?
            .appendingPathComponent("Tests/MMFeedsTests/Resources/Fixtures/Post/Show.json")
        
        let loader = FixtureFileLoader(
            fixtureURL: url
        )
        
        var request = DefaultPostService.showRequest(postID: 1)
        
        request.scheme = TestingConfig.scheme
        request.host = TestingConfig.host
        request.path = "/api/v1/" + request.path
        
        loader.fixtureRequest = request
        
        let service: PostService = DefaultPostService(loader)
        
        let post = try await service.show(for: 1, cacheMode: .reload)
        
        XCTAssertEqual(post.data.title, "Volunteers gesucht!")
        
    }
    
}
