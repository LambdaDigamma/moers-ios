import XCTest
@testable import MapFeature

@MainActor
final class ContentViewControllerLifetimeTests: XCTestCase {
    func testDataSourceDoesNotRetainController() async {
        autoreleasepool {
            var controller: ContentViewController? = ContentViewController()
            controller?.loadViewIfNeeded()
            weak let releasedController = controller
            controller = nil
            XCTAssertNil(releasedController)
        }
    }

    func testControllerCanReleaseOutsideSwiftTask() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                autoreleasepool {
                    var controller: ContentViewController? = ContentViewController()
                    controller?.loadViewIfNeeded()
                    weak let releasedController = controller
                    controller = nil
                    XCTAssertNil(releasedController)
                }
                continuation.resume()
            }
        }
    }
}
