import UIKit
import XCTest
import FactoryKit
@testable import Events

@MainActor
final class TimetableDayBubbleLayoutTests: XCTestCase {
    private var dates: [Date] {
        (21...25).compactMap {
            Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: $0, hour: 12))
        }
    }

    func testSelectionBeforeFirstLayoutIsVisible() async throws {
        let strip = TimetableDayBubbleView()
        strip.setDates(dates, selectedDate: dates.last)
        let window = mount(strip)
        defer { window.isHidden = true }
        await layout(strip, width: 160)
        try assertSelectionVisible(in: strip)
    }

    func testSelectedDayStaysVisibleAfterWidthChanges() async throws {
        let strip = TimetableDayBubbleView()
        let window = mount(strip)
        defer { window.isHidden = true }
        strip.setDates(dates, selectedDate: dates.last)

        for width in [CGFloat(600), 160, 340, 200] {
            await layout(strip, width: width)
            try assertSelectionVisible(in: strip)
        }
    }

    func testPaletteReleasesItsContent() async throws {
        weak var releasedContent: UIView?
        try autoreleasepool {
            let content = UIView()
            releasedContent = content
            _ = try XCTUnwrap(NavigationBarPalette.make(contentView: content, preferredHeight: 60))
        }
        XCTAssertNil(releasedContent)
    }

    func testActiveFilterKeepsItsClearActionWhenThereAreNoDates() async {
        let previousFilter = UserDefaults.standard.object(forKey: "timetableFilter")
        defer {
            UserDefaults.standard.set(previousFilter, forKey: "timetableFilter")
            Container.shared.eventRepository.reset()
        }
        let database = MemoryDatabase.default()
        let repository = EventRepository(
            store: EventStore(writer: database, reader: database),
            service: StaticEventService(events: .success([])),
            pageStore: nil
        )
        Container.shared.eventRepository.register { repository }
        let model = TimetableViewModel(repository: repository)
        model.filter = EventFilter(venueIDs: [99])

        let controller = TimetableViewController()
        controller.loadViewIfNeeded()

        XCTAssertNotNil(controller.navigationItem.timetableBottomPalette)
    }

    private func assertSelectionVisible(in strip: TimetableDayBubbleView) throws {
        let scroll = try XCTUnwrap(strip.subviews.first as? UIScrollView)
        let button = try XCTUnwrap(descendants(of: scroll).compactMap { $0 as? UIButton }.first { $0.isSelected })
        let frame = button.convert(button.bounds, to: scroll)
        XCTAssertGreaterThanOrEqual(frame.minX, scroll.bounds.minX - 1)
        XCTAssertLessThanOrEqual(frame.maxX, scroll.bounds.maxX + 1)
        XCTAssertGreaterThanOrEqual(button.bounds.height, 44)
    }

    private func mount(_ strip: UIView) -> UIWindow {
        let controller = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        window.rootViewController = controller
        controller.view.addSubview(strip)
        window.isHidden = false
        return window
    }

    private func layout(_ strip: UIView, width: CGFloat) async {
        strip.frame = CGRect(x: 0, y: 100, width: width, height: 80)
        for _ in 0..<3 {
            strip.setNeedsLayout()
            strip.layoutIfNeeded()
            await Task.yield()
        }
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }
}
