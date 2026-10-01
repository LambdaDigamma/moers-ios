import ModernNetworking
import XCTest
@testable import MMEvents

@MainActor
final class DefaultEventServiceTests: XCTestCase {
    func testShowDecodesEventFromAsyncClient() async throws {
        let event = Event(id: 42, name: "Sample event")
        let loader = EncodingMockLoader(model: Resource(data: event))
        let service = DefaultEventService(loader)
        let response = try await service.show(event: 42, cacheMode: .cached)
        XCTAssertEqual(response.data.id, 42)
        XCTAssertEqual(response.data.name, "Sample event")
    }

    func testIndexDecodesEventsFromAsyncClient() async throws {
        let events = [Event(id: 1, name: "First"), Event(id: 2, name: "Second")]
        let resource = ResourceCollection(data: events, links: ResourceLinks(), meta: ResourceMeta())
        let service = DefaultEventService(EncodingMockLoader(model: resource))
        let response = try await service.index(cacheMode: .cached)
        XCTAssertEqual(response.data.map(\.id), [1, 2])
        XCTAssertEqual(response.data.map(\.name), ["First", "Second"])
    }
}
