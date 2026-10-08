import UIKit
import XCTest
@testable import Events
@testable import moers_festival

@MainActor
final class FestivalResizabilityTests: XCTestCase {
    func testEventHeaderUpdatesAfterHeightOnlyResize() async throws {
        let detailView = makeEventDetailView()
        detailView.frame = CGRect(x: 0, y: 0, width: 600, height: 1_000)
        detailView.layoutIfNeeded()
        let header = try imageHeader(in: detailView)
        let tallHeight = header.bounds.height

        detailView.frame.size.height = 500
        detailView.setNeedsLayout()
        detailView.layoutIfNeeded()

        XCTAssertEqual(header.bounds.width, 600, accuracy: 0.5)
        XCTAssertLessThan(header.bounds.height, tallHeight)

        detailView.frame.size.height = 1_000
        detailView.setNeedsLayout()
        detailView.layoutIfNeeded()

        XCTAssertEqual(header.bounds.height, tallHeight, accuracy: 0.5)
    }

    func testEventHeaderWaitsForNonzeroViewportHeight() async throws {
        let detailView = makeEventDetailView()
        let header = try imageHeader(in: detailView)
        let heightConstraint = try XCTUnwrap(header.constraints.first {
            $0.firstAttribute == .height && $0.secondItem == nil
        })
        let initialHeight = heightConstraint.constant
        detailView.frame = CGRect(x: 0, y: 0, width: 600, height: 0)

        detailView.setNeedsLayout()
        detailView.layoutIfNeeded()

        XCTAssertEqual(heightConstraint.constant, initialHeight)

        detailView.frame.size.height = 1_000
        detailView.layoutIfNeeded()

        XCTAssertGreaterThan(header.bounds.height, 0)
    }

    func testSavedScheduleFollowsChangingAsymmetricSafeAreas() async throws {
        let controller = UserScheduleViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }
        controller.loadViewIfNeeded()
        let stack = try XCTUnwrap(controller.view.subviews.compactMap { $0 as? UIStackView }.first)

        for insets in [
            UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 15),
            UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 90),
        ] {
            controller.additionalSafeAreaInsets = insets
            window.layoutIfNeeded()
            controller.view.layoutIfNeeded()
            let safeFrame = controller.view.safeAreaLayoutGuide.layoutFrame

            XCTAssertGreaterThan(safeFrame.minX, 0)
            XCTAssertLessThan(safeFrame.maxX, controller.view.bounds.maxX)
            XCTAssertEqual(stack.frame.minX, safeFrame.minX, accuracy: 0.5)
            XCTAssertEqual(stack.frame.maxX, safeFrame.maxX, accuracy: 0.5)
            XCTAssertGreaterThan(stack.frame.width, 0)
        }
    }

    func testAutomaticEventInsetsKeepImageUnderBarAndNoImageTitleBelowIt() async throws {
        for showsImage in [false, true] {
            let event = Event(id: 91, name: "Inset fixture", description: "Event details", image: showsImage
                ? URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("resize-fixture.jpg") : nil)
            let detailView = EventDetailView(viewModel: EventDetailsViewModel(
                model: event, config: EventDetailViewConfig(showImage: showsImage, showLocation: false)
            ))
            let controller = UIViewController()
            controller.view = detailView
            let navigation = UINavigationController(rootViewController: controller)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
            window.rootViewController = navigation
            window.isHidden = false
            defer { window.isHidden = true }
            let scrollView = try XCTUnwrap(descendants(of: detailView).first { $0 is UIScrollView } as? UIScrollView)
            for insets in [
                UIEdgeInsets(top: 35, left: 70, bottom: 25, right: 15),
                UIEdgeInsets(top: 65, left: 15, bottom: 75, right: 90),
            ] {
                controller.additionalSafeAreaInsets = insets
                await settle(navigation.view)
                scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.adjustedContentInset.top)
                await settle(navigation.view)
                XCTAssertEqual(scrollView.contentInsetAdjustmentBehavior, .automatic)
                XCTAssertEqual(scrollView.contentInset.bottom, 16, accuracy: 0.5)
                XCTAssertEqual(scrollView.adjustedContentInset.bottom, scrollView.safeAreaInsets.bottom + 16, accuracy: 0.5)
                if showsImage {
                    let header = try imageHeader(in: detailView)
                    XCTAssertEqual(header.transform, .identity)
                    XCTAssertEqual(header.convert(header.bounds, to: detailView).minY, 0, accuracy: 1)
                    if #unavailable(iOS 26) {
                        scrollView.contentOffset.y = -scrollView.adjustedContentInset.top - 40
                        await settle(navigation.view)
                        XCTAssertNotEqual(header.transform, .identity)
                        scrollView.contentOffset.y = -scrollView.adjustedContentInset.top
                        await settle(navigation.view)
                        XCTAssertEqual(header.transform, .identity)
                    }
                } else {
                    let title = try XCTUnwrap(descendants(of: detailView).first {
                        $0.accessibilityIdentifier == "EventDetail.Title"
                    } as? Events.PaddingLabel)
                    let textFrame = title.convert(title.bounds.inset(by: title.textInsets), to: detailView)
                    XCTAssertEqual(textFrame.minY, detailView.safeAreaLayoutGuide.layoutFrame.minY + 16, accuracy: 1)
                    XCTAssertGreaterThanOrEqual(textFrame.minX, detailView.safeAreaLayoutGuide.layoutFrame.minX)
                    XCTAssertLessThanOrEqual(textFrame.maxX, detailView.safeAreaLayoutGuide.layoutFrame.maxX)
                }
            }
        }
    }

    func testCountdownMarginsUpdateWithLocalSizeClass() async throws {
        let controller = CountdownViewController(startDate: Date(timeIntervalSince1970: 2_000_000_000))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 600, height: 800))
        window.rootViewController = controller
        window.isHidden = false
        defer { window.isHidden = true }
        controller.loadViewIfNeeded()
        let labels = descendants(of: controller.view).compactMap { $0 as? UILabel }
        XCTAssertEqual(labels.count, 2)
        for sizeClass in [UIUserInterfaceSizeClass.compact, .regular, .compact] {
            controller.traitOverrides.horizontalSizeClass = sizeClass
            await settle(controller.view)
            for label in labels {
                let container = try XCTUnwrap(label.superview)
                let spacing: CGFloat = sizeClass == .regular ? 0 : 16
                XCTAssertEqual(label.frame.minX, spacing, accuracy: 0.5)
                XCTAssertEqual(container.bounds.maxX - label.frame.maxX, spacing, accuracy: 0.5)
                XCTAssertGreaterThan(label.frame.width, 0)
            }
        }
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<8 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private func makeEventDetailView() -> EventDetailView {
        let event = Event(
            id: 1,
            name: "Resize fixture",
            image: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("resize-fixture.jpg")
        )
        return EventDetailView(viewModel: EventDetailsViewModel(model: event))
    }

    private func imageHeader(in view: UIView) throws -> UIView {
        try XCTUnwrap(descendants(of: view).first {
            $0.clipsToBounds
                && $0.subviews.contains(where: { $0 is UIImageView })
                && $0.constraints.contains(where: {
                    $0.firstAttribute == .height && $0.secondItem == nil
                })
        })
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }
}
