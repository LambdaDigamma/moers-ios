import BLTNBoard
import Core
import RubbishFeature
import XCTest
@testable import Moers

@MainActor
final class OnboardingLifecycleTests: XCTestCase {
    func testPagesReleaseTheirStoredHandlersAndNextItems() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                withUnsafeCurrentTask { XCTAssertNil($0) }
                OnboardingDeinitializationTaskLocal.$marker.withValue(17) {
                    let factory = OnboardingManager()
                    var pages: [BLTNPageItem] = [
                        factory.makeOnboarding(),
                        factory.makeRubbishStreetPage(),
                        factory.makeRubbishReminderPage(),
                        factory.makeCompletionPage()
                    ]
                    var releasedPages: [() -> BLTNItem?] = []
                    for root in pages {
                        var current: BLTNItem? = root
                        while let page = current {
                            releasedPages.append { [weak page] in page }
                            current = page.next
                        }
                    }
                    pages.removeAll()
                    for page in releasedPages { XCTAssertNil(page()) }
                    XCTAssertEqual(OnboardingDeinitializationTaskLocal.marker, 17)
                }
                XCTAssertEqual(OnboardingDeinitializationTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }

    func testPresentationAppliesAccessibilityIdentifiersToItsItem() async {
        let page = AccessibleBulletinPageItem(title: "Test page")
        page.actionButtonTitle = "Continue"
        page.alternativeButtonTitle = "Back"
        page.titleLabelAccessibilityIdentifier = "TestTitle"
        page.actionButtonAccessibilityIdentifier = "TestContinue"
        page.alternativeButtonAccessibilityIdentifier = "TestBack"
        _ = page.makeArrangedSubviews()
        page.onDisplay()
        XCTAssertEqual(page.titleLabel?.label.accessibilityIdentifier, "TestTitle")
        XCTAssertEqual(page.actionButton?.accessibilityIdentifier, "TestContinue")
        XCTAssertEqual(page.alternativeButton?.accessibilityIdentifier, "TestBack")
    }

    func testStreetPageTeardownCancelsLoading() async {
        let started = expectation(description: "Street load started")
        let cancelled = expectation(description: "Street load cancelled")
        let service = SuspendingOnboardingRubbishService(started: started, cancelled: cancelled)
        let page = RubbishStreetPickerItem(
            title: "Test street", rubbishService: service,
            locationService: OnboardingLocationService(), geocodingService: DefaultGeocodingService()
        )
        page.setUp()
        await fulfillment(of: [started], timeout: 5)
        page.tearDown()
        await fulfillment(of: [cancelled], timeout: 5)
    }

    func testStreetPageReleaseCancelsLoadingWithoutRetainingPage() async {
        let started = expectation(description: "Street load started")
        let cancelled = expectation(description: "Street load cancelled")
        let service = SuspendingOnboardingRubbishService(started: started, cancelled: cancelled)
        var page: RubbishStreetPickerItem? = RubbishStreetPickerItem(
            title: "Test street", rubbishService: service,
            locationService: OnboardingLocationService(), geocodingService: DefaultGeocodingService()
        )
        weak let releasedPage = page
        page?.setUp()
        await fulfillment(of: [started], timeout: 5)
        page = nil
        XCTAssertNil(releasedPage)
        await fulfillment(of: [cancelled], timeout: 5)
    }

    func testStreetPageReleaseCancelsAuthorizationObservation() async {
        let started = expectation(description: "Authorization observation started")
        let terminated = expectation(description: "Authorization observation cancelled")
        let location = OnboardingLocationService(started: started, terminated: terminated)
        var page: RubbishStreetPickerItem? = RubbishStreetPickerItem(
            title: "Test street", rubbishService: StaticRubbishService(),
            locationService: location, geocodingService: DefaultGeocodingService()
        )
        weak let releasedPage = page
        page?.setUp()
        await fulfillment(of: [started], timeout: 5)
        page = nil
        XCTAssertNil(releasedPage)
        await fulfillment(of: [terminated], timeout: 5)
    }

    func testStreetPageReleaseCancelsPendingLocationRequest() async {
        let started = expectation(description: "Location observation started")
        let terminated = expectation(description: "Location observation cancelled")
        let location = OnboardingLocationService(
            status: .authorizedWhenInUse, locationStarted: started, locationTerminated: terminated
        )
        var page: RubbishStreetPickerItem? = RubbishStreetPickerItem(
            title: "Test street", rubbishService: StaticRubbishService(),
            locationService: location, geocodingService: DefaultGeocodingService()
        )
        weak let releasedPage = page
        page?.setUp()
        await fulfillment(of: [started], timeout: 5)
        page = nil
        XCTAssertNil(releasedPage)
        await fulfillment(of: [terminated], timeout: 5)
    }
}
