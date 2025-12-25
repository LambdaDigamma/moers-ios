//
//  DefaultEventServiceTests.swift
//  
//
//  Created by Lennart Fischer on 07.04.23.
//

import Foundation
import XCTest
import ModernNetworking
import Combine
@testable import MMPages


final class DefaultEventServiceTests: XCTestCase {
    
    func testShow() async throws {
        
        let url = ResourcesFinder(file: #file).baseURL()?
            .appendingPathComponent("Tests/MMEventsTests/Resources/Fixtures/Events/Show.json")
        
//        let loader = FixtureFileLoader(
//            fixtureURL: url
//        )
//
//        var request = DefaultPageService.showRequest(pageID: 1)
//
//        request.scheme = TestingConfig.scheme
//        request.host = TestingConfig.host
//        request.path = "/api/v1/" + request.path
//
//        loader.fixtureRequest = request
//
//        let service: PageService = DefaultPageService(loader)
//
//        let resource = try await service.show(for: 1, cacheMode: .cached)
//
//        XCTAssertEqual(resource.data.blocks.count, 3)
        
    }
    
}
