import XCTest
@testable import MapFeature

@MainActor
final class SearchDrawerViewControllerLifetimeTests: XCTestCase {
    func testDistanceUpdatesDoNotKeepLoadedSearchAlive() async {
        weak var releasedController: SearchDrawerViewController?
        autoreleasepool {
            var controller: SearchDrawerViewController? = SearchDrawerViewController()
            controller?.loadViewIfNeeded()
            controller?.didReceiveCameras([Camera.stub(withID: 1)])
            releasedController = controller
            controller = nil
        }
        try? await Task.sleep(for: .milliseconds(100))
        XCTAssertNil(releasedController)
    }

    func testDataSourceDoesNotRetainController() async {
        autoreleasepool {
            var controller: SearchDrawerViewController? = SearchDrawerViewController()
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
                    var controller: SearchDrawerViewController? = SearchDrawerViewController()
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
