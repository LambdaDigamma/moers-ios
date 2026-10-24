import UIKit
import XCTest
@testable import moers_festival

@MainActor
final class LicensesLayoutTests: XCTestCase {
    func testLicenseTextRemainsVisibleInBothColumnsAfterResize() async throws {
        let coordinator = OtherCoordinator()
        let split = try XCTUnwrap(coordinator.rootViewController as? AdaptiveTabSplitViewController)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        split.traitOverrides.horizontalSizeClass = .regular
        window.rootViewController = split
        window.isHidden = false
        defer { window.isHidden = true }
        await settle(split.view)
        coordinator.showLicense()
        await settle(split.view)
        let controller = try XCTUnwrap(coordinator.selectedDetailViewController as? LicensesViewController)
        let licensesView = try XCTUnwrap(controller.view as? LicensesView)
        let textView = licensesView.textView
        XCTAssertFalse(textView.text.isEmpty)

        for size in [CGSize(width: 1_000, height: 800), CGSize(width: 466, height: 678), CGSize(width: 1_000, height: 800)] {
            window.frame.size = size
            split.traitOverrides.horizontalSizeClass = size.width < 600 ? .compact : .regular
            await settle(split.view)
            XCTAssertTrue(coordinator.selectedDetailViewController === controller)
            XCTAssertFalse(textView.hasAmbiguousLayout)

            if let layoutManager = textView.textLayoutManager,
               let documentRange = layoutManager.textContentManager?.documentRange {
                layoutManager.ensureLayout(for: documentRange)
            }
            textView.setContentOffset(CGPoint(x: 0, y: -textView.adjustedContentInset.top), animated: false)
            await settle(split.view)
            try assertVisibleCharacter(at: 0, in: textView, controller: controller)

            let lastCharacter = (textView.text as NSString).rangeOfCharacter(
                from: .whitespacesAndNewlines.inverted, options: .backwards
            )
            textView.setContentOffset(CGPoint(
                x: 0,
                y: max(0, textView.contentSize.height - textView.bounds.height + textView.adjustedContentInset.bottom)
            ), animated: false)
            await settle(split.view)
            try assertVisibleCharacter(at: lastCharacter.location, in: textView, controller: controller)
        }
    }

    private func assertVisibleCharacter(
        at offset: Int, in textView: UITextView, controller: UIViewController,
        file: StaticString = #filePath, line: UInt = #line
    ) throws {
        let start = try XCTUnwrap(textView.position(from: textView.beginningOfDocument, offset: offset))
        let end = try XCTUnwrap(textView.position(from: start, offset: 1))
        let range = try XCTUnwrap(textView.textRange(from: start, to: end))
        let rect = textView.convert(textView.firstRect(for: range), to: controller.view)
        let visibleFrame = textView.convert(textView.bounds, to: controller.view)
            .intersection(controller.view.safeAreaLayoutGuide.layoutFrame)
        XCTAssertFalse(rect.isEmpty, file: file, line: line)
        XCTAssertGreaterThanOrEqual(rect.minX, visibleFrame.minX - 1, file: file, line: line)
        XCTAssertLessThanOrEqual(rect.maxX, visibleFrame.maxX + 1, file: file, line: line)
        XCTAssertGreaterThanOrEqual(rect.minY, visibleFrame.minY - 1, file: file, line: line)
        XCTAssertLessThanOrEqual(rect.maxY, visibleFrame.maxY + 1, file: file, line: line)
    }

    private func settle(_ view: UIView) async {
        for _ in 0..<20 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
