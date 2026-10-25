import SwiftUI
import UIKit
import XCTest
@testable import Core

@MainActor
final class ReadableContentWidthTests: XCTestCase {
    func testWidthFollowsAResizeWithoutAnOrientationNotification() async {
        var textSize = CGSize.zero
        let host = UIHostingController(rootView: ScrollView {
            Text(String(repeating: "Readable text must follow the width of its own window. ", count: 120))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.size, initial: true) { _, size in
                            textSize = size
                        }
                    }
                }
                .readableContentWidth()
        })
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1200, height: 800))
        window.rootViewController = container
        window.makeKeyAndVisible()
        container.addChild(host)
        container.view.addSubview(host.view)
        host.didMove(toParent: container)
        defer { window.isHidden = true }

        await layout(host.view, width: 320)
        let narrowSize = textSize
        XCTAssertGreaterThan(narrowSize.width, 0)
        XCTAssertLessThan(narrowSize.width, 320)
        XCTAssertGreaterThan(narrowSize.height, host.view.bounds.height)

        await layout(host.view, width: 1024)
        XCTAssertGreaterThan(textSize.width, narrowSize.width)
        XCTAssertLessThan(textSize.width, 1024)
        XCTAssertGreaterThan(textSize.height, 40)

        await layout(host.view, width: 320)
        XCTAssertEqual(textSize.width, narrowSize.width, accuracy: 1)
        XCTAssertEqual(textSize.height, narrowSize.height, accuracy: 1)
    }

    private func layout(_ view: UIView, width: CGFloat) async {
        view.frame = CGRect(x: 0, y: 0, width: width, height: 640)
        for _ in 0..<10 {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    func testDynamicTypeChangesUseTheAttachedHostWithoutResize() async throws {
        var textWidth: CGFloat = 0
        let content = Text(String(repeating: "Readable text. ", count: 120))
            .frame(maxWidth: .infinity)
            .background {
                GeometryReader { geometry in
                    Color.clear.onChange(of: geometry.size, initial: true) { _, size in
                        textWidth = size.width
                    }
                }
            }
            .readableContentWidth()
        let host = UIHostingController(rootView: content.dynamicTypeSize(.small))
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_000, height: 800))
        window.rootViewController = container
        window.isHidden = false
        defer { window.isHidden = true }
        container.addChild(host)
        container.view.addSubview(host.view)
        host.didMove(toParent: container)
        host.traitOverrides.horizontalSizeClass = .regular
        await layout(host.view, width: 1_000)
        let measurement = try XCTUnwrap(descendants(of: host).compactMap {
            $0 as? ReadableContentWidthMeasurementController
        }.first)
        XCTAssertNotNil(measurement.parent)
        XCTAssertEqual(measurement.traitCollection.horizontalSizeClass, .regular)
        XCTAssertEqual(measurement.traitCollection.preferredContentSizeCategory, .small)

        host.rootView = content.dynamicTypeSize(.accessibility4)
        await layout(host.view, width: 1_000)
        XCTAssertEqual(measurement.traitCollection.preferredContentSizeCategory, .accessibilityExtraExtraLarge)
        let reference = UIViewController()
        container.addChild(reference)
        container.view.addSubview(reference.view)
        reference.didMove(toParent: container)
        reference.view.frame = measurement.view.frame
        reference.traitOverrides.horizontalSizeClass = .regular
        reference.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraLarge
        reference.view.layoutIfNeeded()
        XCTAssertEqual(textWidth, reference.view.readableContentGuide.layoutFrame.width, accuracy: 1)
    }

    func testQueuedWidthUsesLatestLayoutAndStopsAfterRemoval() async throws {
        var reports: [CGFloat] = []
        let measurement = ReadableContentWidthMeasurementController()
        measurement.onWidthChange = { reports.append($0) }
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_200, height: 800))
        window.rootViewController = container
        window.isHidden = false
        defer { window.isHidden = true }
        container.addChild(measurement)
        container.view.addSubview(measurement.view)
        measurement.didMove(toParent: container)
        await layout(measurement.view, width: 400)
        let initial = try XCTUnwrap(reports.last)
        let count = reports.count
        measurement.view.frame.size.width = 1_000
        measurement.view.layoutIfNeeded()
        measurement.view.frame.size.width = 400
        measurement.view.layoutIfNeeded()
        await Task.yield()
        XCTAssertEqual(reports.last, initial)
        XCTAssertEqual(reports.count, count)
        measurement.view.frame.size.width = 1_000
        measurement.view.layoutIfNeeded()
        measurement.stopReportingWidth()
        await Task.yield()
        XCTAssertEqual(reports.count, count)
    }

    func testPaddedContentUsesOneMarginAndKeepsTheNativeWidthLimit() async throws {
        var textWidth: CGFloat = 0
        let content = Text(String(repeating: "Readable event text. ", count: 100))
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { textWidth = $0 }
            .padding(.horizontal, 16)
        let host = UIHostingController(rootView: content
            .readableContentWidth(includeLayoutMargins: false)
            .dynamicTypeSize(.small))
        let container = UIViewController()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1_200, height: 800))
        window.rootViewController = container
        window.isHidden = false
        defer { window.isHidden = true }
        container.addChild(host)
        container.view.addSubview(host.view)
        host.didMove(toParent: container)
        host.traitOverrides.horizontalSizeClass = .regular
        host.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 50)

        await layout(host.view, width: 320)
        let availableWidth = host.view.safeAreaLayoutGuide.layoutFrame.width
        XCTAssertEqual(textWidth, availableWidth - 32, accuracy: 1)
        let measurement = try XCTUnwrap(descendants(of: host).compactMap {
            $0 as? ReadableContentWidthMeasurementController
        }.first)
        XCTAssertFalse(measurement.viewRespectsSystemMinimumLayoutMargins)

        host.rootView = content.readableContentWidth().dynamicTypeSize(.small)
        await layout(host.view, width: 320)
        XCTAssertTrue(measurement.viewRespectsSystemMinimumLayoutMargins)
        XCTAssertLessThan(textWidth, availableWidth - 32)

        host.rootView = content.readableContentWidth(includeLayoutMargins: false).dynamicTypeSize(.small)
        await layout(host.view, width: 320)
        XCTAssertEqual(textWidth, availableWidth - 32, accuracy: 1)

        await layout(host.view, width: 1_024)
        let reference = UIViewController()
        reference.viewRespectsSystemMinimumLayoutMargins = false
        container.addChild(reference)
        container.view.addSubview(reference.view)
        reference.didMove(toParent: container)
        reference.view.directionalLayoutMargins = .zero
        reference.view.frame = measurement.view.frame
        reference.traitOverrides.horizontalSizeClass = .regular

        for size in [DynamicTypeSize.small, .accessibility4] {
            host.rootView = content.readableContentWidth(includeLayoutMargins: false).dynamicTypeSize(size)
            await layout(host.view, width: 1_024)
            reference.traitOverrides.preferredContentSizeCategory = UIContentSizeCategory(size)
            reference.view.layoutIfNeeded()
            XCTAssertEqual(textWidth, reference.view.readableContentGuide.layoutFrame.width - 32, accuracy: 1)
        }
    }

    private func descendants(of controller: UIViewController) -> [UIViewController] {
        controller.children.flatMap { [$0] + descendants(of: $0) }
    }
}
