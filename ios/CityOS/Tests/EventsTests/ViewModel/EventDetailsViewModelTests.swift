import Combine
import Foundation
import XCTest
@testable import Events

@MainActor
final class EventDetailsViewModelTests: XCTestCase {
    func testRepeatedTeaserIsHiddenAndExplicitSubtitleUpdates() async {
        let model = EventDetailsViewModel(model: Event(id: 1, name: "Event", description: "Opening paragraph. More details.", teaser: "Opening paragraph."))
        var subtitle: String?
        let subscription = model.subtitle.sink { subtitle = $0 }
        defer { subscription.cancel() }
        XCTAssertNil(subtitle)
        model.setNewEvent(Event(id: 1, name: "Event", subtitle: "Special anniversary"))
        XCTAssertEqual(subtitle, "Special anniversary")
    }

    func testFestivalPresentationRetainsTicketContextAfterConfigChanges() async {
        let event = Event(id: 1, name: "Festival", startDate: Date(), extras: EventExtras(location: "Venue", needsFestivalTicket: true))
        let model = EventDetailsViewModel(model: event)
        var subtitle: String?
        let subscription = model.subtitle.sink { subtitle = $0 }
        defer { subscription.cancel() }
        XCTAssertNil(subtitle)
        model.setNewConfig(EventDetailViewConfig(showsFestivalSubtitle: true))
        XCTAssertEqual(subtitle, EventViewModel(event: event).detailSubtitle)
        XCTAssertTrue(subtitle?.contains("ticket") == true)
        model.setNewConfig(EventDetailViewConfig())
        XCTAssertNil(subtitle)
    }

    func testFestivalPresentationOptionRetainsCodableCompatibility() async throws {
        let legacy = try JSONDecoder().decode(EventDetailViewConfig.self, from: Data("{}".utf8))
        XCTAssertFalse(legacy.showsFestivalSubtitle)
        let config = EventDetailViewConfig(showsFestivalSubtitle: true)
        let decoded = try JSONDecoder().decode(EventDetailViewConfig.self, from: JSONEncoder().encode(config))
        XCTAssertTrue(decoded.showsFestivalSubtitle)
    }

    func testOnlyHTTPWebsitesOfferTheWebsiteAction() async {
        let model = EventDetailsViewModel(model: nil)
        var isVisible = false
        let subscription = model.showMore.sink { isVisible = $0 }
        defer { subscription.cancel() }
        for url in ["relative/path", "javascript:alert(1)", "file:///tmp/event"] {
            model.setNewEvent(Event(id: 1, name: "Event", url: url))
            XCTAssertFalse(isVisible)
            XCTAssertNil(model.webURL)
        }
        model.setNewEvent(Event(id: 1, name: "Event", url: "https://example.com/event"))
        XCTAssertTrue(isVisible)
        XCTAssertEqual(model.webURL?.host, "example.com")
    }
}
