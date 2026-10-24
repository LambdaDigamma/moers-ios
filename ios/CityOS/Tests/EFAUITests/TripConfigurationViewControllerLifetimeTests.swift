import UIKit
import XCTest
@testable import EFAUI

@MainActor
final class TripConfigurationViewControllerLifetimeTests: XCTestCase {
    func testUnusedPlannerIsReleased() async {
        weak var releasedController: TripConfigurationViewController?
        autoreleasepool {
            var controller: TripConfigurationViewController? = TripConfigurationViewController()
            releasedController = controller
            controller = nil
        }
        XCTAssertNil(releasedController)
    }

    func testSynchronousReleasePreservesTaskLocalScope() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                TripPlannerTaskLocal.$marker.withValue(17) {
                    weak var releasedController: TripConfigurationViewController?
                    autoreleasepool {
                        var controller: TripConfigurationViewController? = TripConfigurationViewController()
                        releasedController = controller
                        controller = nil
                    }
                    XCTAssertNil(releasedController)
                    XCTAssertEqual(TripPlannerTaskLocal.marker, 17)
                }
                XCTAssertEqual(TripPlannerTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }
}
