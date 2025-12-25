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


final class EventServiceTests: XCTestCase {
    
    var eventService: LegacyEventService! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        
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
                                 transformer: TransformerFactory.forCodable(ofType: [Event].self))
        
        eventService = DefaultLegacyEventService(mockLoader, cache)
        
    }
    
    override func tearDown() {
        eventService.invalidateCache()
        eventService = nil
    }
    
    func testIndexNetworkRequest() {
        
        let promise = expectation(description: #function)
        
        eventService.loadEventsFromNetwork()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        if let error = error as? DecodingError {
                            print(error)
                        }
                        print(error.localizedDescription)
                    default: break
                }
            }, receiveValue: { events in
                XCTAssertEqual(events.count, 3)
                XCTAssertEqual(events[0].name, "Event 1")
                promise.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [promise], timeout: 1)
        
    }
    
    func testCachedResponseAfterNetworkRequest() {
        
        let promise = expectation(description: #function)
        
        eventService.loadEventsFromNetwork()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure:
                        XCTFail("Failed while loading events")
                    default: break
                }
            }, receiveValue: { events in
                
                self.eventService?.loadEventsFromPersistence()
                    .replaceError(with: [])
                    .sink { (events) in
                        XCTAssertEqual(events.count, 3)
                        XCTAssertEqual(events[0].name, "Event 1")
                        XCTAssertEqual(events[1].name, "Event 2")
                        XCTAssertEqual(events[2].name, "Event 3")
                        promise.fulfill()
                    }
                    .store(in: &self.cancellables)
                
            })
            .store(in: &cancellables)
        
        wait(for: [promise], timeout: 1)
        
        
    }
    
    static var allTests = [
        ("testIndexNetworkRequest", testIndexNetworkRequest),
    ]
}
