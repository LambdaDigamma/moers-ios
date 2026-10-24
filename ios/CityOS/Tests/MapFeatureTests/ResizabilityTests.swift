import Core
import ModernNetworking
import UIKit
import XCTest
@testable import MapFeature

@MainActor
final class ResizabilityTests: XCTestCase {
    func testFormControlsFollowAsymmetricInsetsAndLayoutDirection() async {
        let controller = EntryOnboardingGeneralViewController(entryManager: EntryManager(loader: HTTPLoader()))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 1024, height: 768))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        for direction: UISemanticContentAttribute in [.forceLeftToRight, .forceRightToLeft] {
            controller.view.semanticContentAttribute = direction
            for insets in [
                UIEdgeInsets(top: 0, left: 96, bottom: 0, right: 0),
                UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 96)
            ] {
                controller.additionalSafeAreaInsets = insets
                controller.view.setNeedsLayout()
                controller.view.layoutIfNeeded()
                let safeFrame = controller.view.safeAreaLayoutGuide.layoutFrame
                for field in [controller.nameTextField, controller.websiteTextField, controller.phoneTextField] {
                    let frame = field.convert(field.bounds, to: controller.view)
                    XCTAssertEqual(frame.minX, safeFrame.minX + 16, accuracy: 1)
                    XCTAssertEqual(frame.maxX, safeFrame.maxX - 16, accuracy: 1)
                }
            }
        }
    }

    func testKeyboardNotificationsFromAnotherWindowDoNotAddInsets() async {
        let controller = EntryOnboardingGeneralViewController(entryManager: EntryManager(loader: HTTPLoader()))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        controller.view.layoutIfNeeded()
        let originalInset = controller.scrollView.contentInset

        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 0, width: 1024, height: 900))]
        )
        window.frame.size.width = 600
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.scrollView.contentInset, originalInset)
        XCTAssertGreaterThan(controller.scrollView.bounds.height, 0)
    }

    func testSearchNotificationsFromAnotherWindowDoNotAddInsets() async {
        let controller = LFSearchViewController()
        controller.loadViewIfNeeded()
        let originalInset = controller.tableView.contentInset
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 0, width: 1024, height: 900)),
                UIResponder.keyboardAnimationDurationUserInfoKey: NSNumber(value: 0)
            ]
        )
        XCTAssertEqual(controller.tableView.contentInset, originalInset)
    }
}
