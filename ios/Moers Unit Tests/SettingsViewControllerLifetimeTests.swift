import Core
import UIKit
import XCTest
@testable import Moers

@MainActor
final class SettingsViewControllerLifetimeTests: XCTestCase {
    private let userKeys = ["userType", "userName", "userID", "userDescription"]
    private var previousUserValues: [String: Any] = [:]

    override func setUp() async throws {
        try await super.setUp()
        for key in userKeys {
            previousUserValues[key] = UserDefaults.standard.object(forKey: key)
        }
    }

    override func tearDown() async throws {
        for key in userKeys {
            if let value = previousUserValues[key] {
                UserDefaults.standard.set(value, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        previousUserValues = [:]
        try await super.tearDown()
    }

    func testTouristSettingsReleaseAfterLoadingRows() async {
        await checkSettingsRelease(for: .tourist)
    }

    func testCitizenSettingsReleaseAfterLoadingRows() async {
        await checkSettingsRelease(for: .citizen)
    }

    private func checkSettingsRelease(for userType: User.UserType) async {
        UserManager.shared.register(User(type: userType, id: nil, name: nil, description: nil))
        weak var releasedController: SettingsViewController?
        autoreleasepool {
            let controller = SettingsViewController()
            controller.loadViewIfNeeded()
            let snapshot = controller.dataSource?.snapshot()
            XCTAssertEqual(snapshot?.sectionIdentifiers.contains(.rubbish), userType == .citizen)
            XCTAssertEqual(snapshot?.numberOfItems, userType == .citizen ? 5 : 2)
            releasedController = controller
        }
        for _ in 0..<4 {
            try? await Task.sleep(for: .milliseconds(20))
        }
        XCTAssertNil(releasedController, "Settings must release when its owner releases it.")
    }
}
