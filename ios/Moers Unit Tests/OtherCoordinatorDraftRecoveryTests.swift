import Core
import MapFeature
import UIKit
import XCTest
@testable import Moers

@MainActor
final class OtherCoordinatorDraftRecoveryTests: XCTestCase {
    private let draftKeys = ["EntryStreet", "EntryLat", "EntryLng"]
    private var previousDraftValues: [String: Any] = [:]
    private var coordinator: OtherCoordinator!
    private var window: UIWindow!
    private weak var previousKeyWindow: UIWindow?
    private var wereAnimationsEnabled = true

    override func setUp() async throws {
        try await super.setUp()
        for key in draftKeys {
            previousDraftValues[key] = UserDefaults.standard.object(forKey: key)
            UserDefaults.standard.removeObject(forKey: key)
        }
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        previousKeyWindow = scene.windows.first { $0.isKeyWindow }
        wereAnimationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        coordinator = OtherCoordinator()
        window = UIWindow(windowScene: scene)
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
    }

    override func tearDown() async throws {
        coordinator?.navigationController.dismiss(animated: false)
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
        coordinator = nil
        previousKeyWindow?.makeKey()
        previousKeyWindow = nil
        UIView.setAnimationsEnabled(wereAnimationsEnabled)
        for key in draftKeys {
            if let value = previousDraftValues[key] {
                UserDefaults.standard.set(value, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        previousDraftValues = [:]
        try await super.tearDown()
    }

    func testSavedStreetPresentsRecoveryAlertWithoutExistingPresentation() async throws {
        coordinator.entryManager.entryStreet = "Test street"
        try await checkRecoveryAlert()
        XCTAssertEqual(coordinator.entryManager.entryStreet, "Test street")
    }

    func testSavedCoordinatePresentsRecoveryAlertWithoutExistingPresentation() async throws {
        coordinator.entryManager.entryLat = 51.45
        coordinator.entryManager.entryLng = 6.63
        try await checkRecoveryAlert()
        XCTAssertEqual(coordinator.entryManager.entryLat, 51.45)
        XCTAssertEqual(coordinator.entryManager.entryLng, 6.63)
    }

    func testEmptyDraftStartsEntryOnboarding() async {
        coordinator.showAddEntry()
        XCTAssertTrue(coordinator.navigationController.topViewController is EntryOnboardingLocationMenuViewController)
        XCTAssertNil(coordinator.navigationController.presentedViewController)
    }

    private func checkRecoveryAlert() async throws {
        let navigation = coordinator.navigationController
        XCTAssertNil(navigation.presentedViewController)
        coordinator.showAddEntry()
        await Task.yield()
        let alert = try XCTUnwrap(navigation.presentedViewController as? UIAlertController)
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertTrue(alert.actions.contains { $0.style == .cancel })
        XCTAssertTrue(alert.actions.contains { $0.style == .default })
        XCTAssertEqual(navigation.viewControllers.count, 1)
    }
}
