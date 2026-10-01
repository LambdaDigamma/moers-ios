//
//  EventServiceTest.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import XCTest
import ModernNetworking
import Combine
import Cache
@testable import MMEvents


@MainActor
final class EventServiceTests: XCTestCase {
    
    var eventService: LegacyEventService! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() async throws {
        
        let t = ResourceCollection(data: [
            Event.stub(withID: 1)
                .setting(\.name, to: "Event 1")
                .setting(\.startDate, to: Date().addingTimeInterval(60 * 5)),
            Event.stub(withID: 2)
                .setting(\.name, to: "Event 2")
                .setting(\.startDate, to: Date().addingTimeInterval(60 * 10)),
            Event.stub(withID: 3)
                .setting(\.name, to: "Event 3")
                .setting(\.startDate, to: Date().addingTimeInterval(60 * 15)),
        ], links: ResourceLinks(), meta: ResourceMeta())
        
        let mockLoader = EncodingMockLoader(model: t)
        
        let cache = try! Storage<String, [Event]>(diskConfig: DiskConfig(name: "EventService"),
                                 memoryConfig: MemoryConfig(),
                                 fileManager: .default,
                                 transformer: TransformerFactory.forCodable(ofType: [Event].self))
        
        eventService = DefaultLegacyEventService(mockLoader, cache)
        
    }
    
    override func tearDown() async throws {
        eventService.invalidateCache()
        eventService = nil
    }
    
    func testIndexNetworkRequest() async throws {
        let events = try await eventService.loadEventsFromNetwork()
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events[0].name, "Event 1")
    }

    func testCachedResponseAfterNetworkRequest() async throws {
        _ = try await eventService.loadEventsFromNetwork()
        let events = try await eventService.loadEventsFromPersistence()
        XCTAssertEqual(events.count, 3)
        XCTAssertEqual(events.map(\.name), ["Event 1", "Event 2", "Event 3"])
    }
}
