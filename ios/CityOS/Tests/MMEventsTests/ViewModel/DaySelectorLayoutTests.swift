import Combine
import SwiftUI
import UIKit
import XCTest
@testable import MMEvents

@MainActor
final class DaySelectorLayoutTests: XCTestCase {
    private var dates: [Date] {
        (21...25).compactMap {
            Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: $0, hour: 12))
        }
    }

    func testTwoDigitDaysKeepTheirHeightWhenWidthIsRestricted() async {
        for textSize in [DynamicTypeSize.large, .accessibility3] {
            for date in dates {
                let host = UIHostingController(rootView: DayItem(date: date).dynamicTypeSize(textSize))
                let naturalSize = host.sizeThatFits(in: CGSize(width: 200, height: 400))
                let narrowSize = host.sizeThatFits(in: CGSize(width: 24, height: 400))
                XCTAssertEqual(narrowSize.height, naturalSize.height, accuracy: 1)
                XCTAssertGreaterThanOrEqual(narrowSize.width, 44)
            }
        }
    }

    func testFiveDaysFitProgrammeColumnWithoutIncreasingHeaderHeight() async {
        for locale in ["en", "de"] {
            let host = UIHostingController(rootView: selector(selectedDate: dates[1], locale: locale))
            let naturalHeight = host.sizeThatFits(in: CGSize(width: 800, height: 400)).height
            for width in [CGFloat(308), 340, 420] {
                let size = host.sizeThatFits(in: CGSize(width: width, height: 400))
                XCTAssertEqual(size.height, naturalHeight, accuracy: 1)
                XCTAssertLessThanOrEqual(size.width, width)
            }
        }
    }

    func testResizeEnablesScrollAndKeepsSelectedDayVisible() async throws {
        let host = UIHostingController(rootView: selector(selectedDate: dates[4].addingTimeInterval(3600)))
        let window = mount(host)
        defer { window.isHidden = true }

        for width in [CGFloat(200), 160, 600, 200] {
            await layout(host.view, width: width)
            let scroll = horizontalScrollView(in: host.view)
            if width == 600 {
                XCTAssertNil(scroll)
            } else {
                let scroll = try XCTUnwrap(scroll)
                XCTAssertEqual(scroll.contentOffset.x, scroll.contentSize.width - scroll.bounds.width, accuracy: 1)
                XCTAssertLessThan(scroll.bounds.height, 100)
            }
        }
    }

    func testLargeTextScrollsToChangedSelectionWithoutIncreasingViewportHeight() async throws {
        let host = UIHostingController(rootView: selector(selectedDate: dates[4], textSize: .accessibility3))
        let window = mount(host)
        defer { window.isHidden = true }
        await layout(host.view, width: 308)
        let scroll = try XCTUnwrap(horizontalScrollView(in: host.view))
        XCTAssertGreaterThan(scroll.contentOffset.x, 0)
        XCTAssertLessThan(scroll.bounds.height, 200)

        host.rootView = selector(selectedDate: dates[4], textSize: .accessibility5)
        await layout(host.view, width: 308)
        XCTAssertEqual(scroll.contentOffset.x, scroll.contentSize.width - scroll.bounds.width, accuracy: 1)

        let earlierDate = dates[0].addingTimeInterval(-86_400)
        host.rootView = selector(selectedDate: dates[4], textSize: .accessibility5, displayedDates: [earlierDate] + dates)
        await layout(host.view, width: 308)
        XCTAssertEqual(scroll.contentOffset.x, scroll.contentSize.width - scroll.bounds.width, accuracy: 1)

        host.rootView = selector(selectedDate: dates[0], textSize: .accessibility3)
        await layout(host.view, width: 308)
        XCTAssertEqual(scroll.contentOffset.x, 0, accuracy: 1)
    }

    func testCompactTimetableLeavesSpaceForEventsAtLargeTextSize() async throws {
        let previousFilter = UserDefaults.standard.object(forKey: "timetableFilter")
        defer { UserDefaults.standard.set(previousFilter, forKey: "timetableFilter") }
        let database = MemoryDatabase.default()
        let store = EventStore(writer: database, reader: database)
        let repository = EventRepository(store: store, service: StaticEventService(events: .success([])), pageStore: nil)
        let model = TimetableViewModel(repository: repository)
        model.filter = .empty
        let loaded = expectation(description: "Five timetable dates loaded")
        let subscription = model.daysPublisher.filter { $0.count == 5 }.first().sink { _ in loaded.fulfill() }
        defer { subscription.cancel() }
        try await store.deleteAllAndInsert(dates.enumerated().map { index, date in
            Event.stub(withID: index + 1).setting(\.startDate, to: date).toRecord()
        })
        await fulfillment(of: [loaded], timeout: 2)
        let host = UIHostingController(rootView: CompactEventsView(viewModel: model)
            .environment(TimetableTransmitter())
            .dynamicTypeSize(.accessibility3))
        let window = mount(host)
        defer { window.isHidden = true }
        await layout(host.view, width: 340)
        let scroll = try XCTUnwrap(horizontalScrollView(in: host.view))
        XCTAssertLessThan(scroll.bounds.height, host.view.bounds.height / 2)
        XCTAssertGreaterThan(scroll.contentSize.width, scroll.bounds.width)
    }

    private func selector(
        selectedDate: Date,
        textSize: DynamicTypeSize = .large,
        locale: String = "en",
        displayedDates: [Date]? = nil
    ) -> some View {
        DaySelector(selectedDate: selectedDate, dates: displayedDates ?? dates, onSelectDate: { _ in })
            .dynamicTypeSize(textSize)
            .environment(\.locale, Locale(identifier: locale))
    }

    private func mount<Content: View>(_ host: UIHostingController<Content>) -> UIWindow {
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
        window.rootViewController = container
        window.isHidden = false
        container.addChild(host)
        container.view.addSubview(host.view)
        host.didMove(toParent: container)
        return window
    }

    private func horizontalScrollView(in view: UIView) -> UIScrollView? {
        descendants(of: view).compactMap { $0 as? UIScrollView }.first {
            $0.bounds.width > 0 && $0.contentSize.width > $0.bounds.width + 1 && $0.contentSize.height <= $0.bounds.height + 1
        }
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    private func layout(_ view: UIView, width: CGFloat) async {
        view.frame = CGRect(x: 0, y: 0, width: width, height: 600)
        for _ in 0..<10 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
