import Events
import UIKit
import XCTest
@testable import Moers

@MainActor
final class EventsAdaptiveLayoutTests: XCTestCase {
    func testQuickFiltersGrowAtTheLargestTextSize() async throws {
        for width in [CGFloat(375), 1024] {
            let normalHeight = try await quickFilterHeight(width: width, category: .large)
            let accessibleHeight = try await quickFilterHeight(width: width, category: .accessibilityExtraExtraExtraLarge)
            XCTAssertGreaterThan(accessibleHeight, normalHeight)
        }
    }

    func testSpotlightsGrowAndKeepAllTextAtTheLargestTextSize() async throws {
        for width in [CGFloat(375), 1024] {
            let normalHeight = try await spotlightHeight(width: width, category: .large)
            let accessibleHeight = try await spotlightHeight(width: width, category: .accessibilityExtraExtraExtraLarge)
            XCTAssertGreaterThan(accessibleHeight, normalHeight)
        }
    }

    func testHorizontalSectionsStayInsideAsymmetricSafeAreas() async throws {
        for width in [CGFloat(375), 1024] {
            for category in [UIContentSizeCategory.large, .accessibilityExtraExtraExtraLarge] {
                let (window, collection) = try install(width: width, category: category)
                defer { window.isHidden = true }
                await settle(collection)
                let rootView = try XCTUnwrap(collection.superview)
                let safeFrame = rootView.safeAreaLayoutGuide.layoutFrame
                let viewport = collection.convert(collection.bounds, to: rootView)
                XCTAssertEqual(viewport.minX, safeFrame.minX, accuracy: 1)
                XCTAssertEqual(viewport.maxX, safeFrame.maxX, accuracy: 1)
                XCTAssertTrue(collection.clipsToBounds)

                for scroller in collection.subviews.compactMap({ $0 as? UIScrollView }) {
                    let frame = scroller.convert(scroller.bounds, to: rootView)
                    XCTAssertGreaterThanOrEqual(frame.minX, safeFrame.minX - 1)
                    XCTAssertLessThanOrEqual(frame.maxX, safeFrame.maxX + 1)
                }
            }
        }
    }

    private func quickFilterHeight(width: CGFloat, category: UIContentSizeCategory) async throws -> CGFloat {
        let (window, collection) = try install(width: width, category: category)
        defer { window.isHidden = true }
        await settle(collection)
        let cell = try XCTUnwrap(collection.cellForItem(at: IndexPath(item: 0, section: 0)))
        assertTextFits(in: cell, context: "width \(width), text \(category.rawValue)")
        return cell.bounds.height
    }

    private func spotlightHeight(width: CGFloat, category: UIContentSizeCategory) async throws -> CGFloat {
        let (window, collection) = try install(width: width, category: category)
        defer { window.isHidden = true }
        await settle(collection)
        let path = IndexPath(item: 0, section: 1)
        collection.scrollToItem(at: path, at: .top, animated: false)
        await settle(collection)
        let cell = try XCTUnwrap(collection.cellForItem(at: path))
        assertTextFits(in: cell, context: "width \(width), text \(category.rawValue)")
        if category.isAccessibilityCategory {
            let title = try XCTUnwrap(labels(in: cell).first { $0.text == "Museum tour" })
            XCTAssertEqual(title.numberOfLines, 0)
        }
        return cell.bounds.height
    }

    private func install(
        width: CGFloat,
        category: UIContentSizeCategory
    ) throws -> (UIWindow, UICollectionView) {
        let event = Event(
            id: 1,
            name: "Museum tour",
            startDate: Date(),
            category: "Art",
            image: URL(fileURLWithPath: "/nonexistent-events-layout-test-image")
        )
        let controller = Moers.EventsViewController(eventService: StaticEventService(events: .success([event])))
        controller.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 72)
        let navigation = UINavigationController(rootViewController: controller)
        navigation.traitOverrides.preferredContentSizeCategory = category
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: 1200))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        controller.loadViewIfNeeded()
        let collection = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UICollectionView }.first)
        return (window, collection)
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<12 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func assertTextFits(in cell: UICollectionViewCell, context: String, file: StaticString = #filePath, line: UInt = #line) {
        for label in labels(in: cell) where !(label.text ?? "").isEmpty {
            let fitting = label.sizeThatFits(CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude))
            XCTAssertLessThanOrEqual(
                fitting.height, label.bounds.height + 1,
                "\(context): \(label.text ?? "") in \(label.bounds), cell \(cell.bounds)", file: file, line: line
            )
            let frame = label.convert(label.bounds, to: cell.contentView)
            XCTAssertGreaterThanOrEqual(frame.minY, -1, file: file, line: line)
            XCTAssertLessThanOrEqual(frame.maxY, cell.contentView.bounds.maxY + 1, file: file, line: line)
            XCTAssertGreaterThanOrEqual(frame.minX, -1, file: file, line: line)
            XCTAssertLessThanOrEqual(frame.maxX, cell.contentView.bounds.maxX + 1, file: file, line: line)
        }
    }

    private func labels(in view: UIView) -> [UILabel] {
        guard !view.isHidden else { return [] }
        return (view as? UILabel).map { [$0] } ?? view.subviews.flatMap(labels(in:))
    }
}
