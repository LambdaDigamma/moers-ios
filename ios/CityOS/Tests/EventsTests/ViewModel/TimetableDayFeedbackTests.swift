import UIKit
import XCTest
@testable import Events

@MainActor
final class TimetableDayFeedbackTests: XCTestCase {
    private var dates: [Date] {
        (21...23).compactMap {
            Calendar.autoupdatingCurrent.date(from: DateComponents(year: 2030, month: 5, day: $0))
        }
    }

    func testInitialSelectionReloadAndProgrammaticChangesStaySilent() async {
        let feedback = SelectionFeedbackGeneratorSpy()
        let strip = TimetableDayBubbleView(feedbackGenerator: feedback)
        strip.setDates(dates, selectedDate: dates[0])
        strip.setSelectedDate(dates[1], animated: false)
        strip.setDates([dates[2]], selectedDate: dates[2])

        XCTAssertEqual(feedback.selectionCount, 0)
        XCTAssertEqual(feedback.prepareCount, 0)
    }

    func testUserDayChangesProduceOneTickPerChange() async {
        let feedback = SelectionFeedbackGeneratorSpy()
        let strip = TimetableDayBubbleView(feedbackGenerator: feedback)
        strip.setDates(dates, selectedDate: dates[0])
        strip.setSelectedDate(dates[1], animated: false, isUserInitiated: true)
        XCTAssertEqual(feedback.selectionCount, 1)

        // Page-scroll callbacks and the following render can repeat the selected day.
        strip.setSelectedDate(dates[1], animated: false, isUserInitiated: true)
        strip.setDates(dates, selectedDate: dates[1])
        XCTAssertEqual(feedback.selectionCount, 1)

        strip.setSelectedDate(dates[2], animated: false, isUserInitiated: true)
        XCTAssertEqual(feedback.selectionCount, 2)
    }

    func testAnotherTimeOnTheCurrentDayStaysSilent() async throws {
        let feedback = SelectionFeedbackGeneratorSpy()
        let strip = TimetableDayBubbleView(feedbackGenerator: feedback)
        strip.setDates(dates, selectedDate: dates[0])
        let noon = try XCTUnwrap(Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 12, to: dates[0]))
        strip.setSelectedDate(noon, animated: false, isUserInitiated: true)

        XCTAssertEqual(feedback.selectionCount, 0)
    }

    func testUnscheduledPageTicksOnlyWhenSelectionChanges() async {
        let feedback = SelectionFeedbackGeneratorSpy()
        let strip = TimetableDayBubbleView(feedbackGenerator: feedback)
        strip.setDates(dates, selectedDate: dates[0], includesUnscheduled: true)
        strip.setSelectedDate(nil, animated: false, isUserInitiated: true)
        XCTAssertEqual(feedback.selectionCount, 1)

        strip.setSelectedDate(nil, animated: false, isUserInitiated: true)
        XCTAssertEqual(feedback.selectionCount, 1)

        strip.setSelectedDate(dates[1], animated: false, isUserInitiated: true)
        XCTAssertEqual(feedback.selectionCount, 2)
    }

    func testTouchDownPreparesWithoutProducingFeedback() async throws {
        let feedback = SelectionFeedbackGeneratorSpy()
        let strip = TimetableDayBubbleView(feedbackGenerator: feedback)
        strip.setDates(dates, selectedDate: dates[0])
        let scroll = try XCTUnwrap(strip.subviews.first as? UIScrollView)
        let stack = try XCTUnwrap(scroll.subviews.first as? UIStackView)
        let button = try XCTUnwrap(stack.arrangedSubviews.first as? UIButton)
        button.sendActions(for: .touchDown)

        XCTAssertEqual(feedback.prepareCount, 1)
        XCTAssertEqual(feedback.selectionCount, 0)
    }
}
