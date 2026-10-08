import Core
import UIKit
import XCTest
@testable import Events

@MainActor
final class EventDetailLayoutTests: XCTestCase {
    func testTextAndScrollClearanceFollowInsetOnlyChanges() async throws {
        let model = EventDetailsViewModel(
            model: Event(id: 42, name: "Event layout", description: "Details", url: "https://example.com"),
            config: EventDetailViewConfig(showImage: false, showLocation: false)
        )
        let controller = EventDetailViewController(viewModel: model)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        let title = try XCTUnwrap(descendants(of: controller.view).first {
            $0.accessibilityIdentifier == "EventDetail.Title"
        } as? Events.PaddingLabel)
        let scrollView = try XCTUnwrap(descendants(of: controller.view).first { $0 is UIScrollView } as? UIScrollView)

        for insets in [
            UIEdgeInsets(top: 64, left: 96, bottom: 34, right: 0),
            UIEdgeInsets(top: 64, left: 0, bottom: 96, right: 96)
        ] {
            controller.additionalSafeAreaInsets = insets
            await settle(controller.view)
            let safeFrame = controller.view.safeAreaLayoutGuide.layoutFrame
            let textFrame = title.convert(title.bounds.inset(by: title.textInsets), to: controller.view)
            XCTAssertGreaterThanOrEqual(textFrame.minX, safeFrame.minX)
            XCTAssertLessThanOrEqual(textFrame.maxX, safeFrame.maxX)
            XCTAssertEqual(textFrame.minY, safeFrame.minY + 16, accuracy: 1)
            XCTAssertEqual(scrollView.contentInset.bottom, 16, accuracy: 0.5)
            XCTAssertEqual(scrollView.adjustedContentInset.bottom, scrollView.safeAreaInsets.bottom + 16, accuracy: 0.5)
        }
    }

    private func descendants(of view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(of: $0) }
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<5 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
