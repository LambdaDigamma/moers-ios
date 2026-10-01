import CoreLocation
import XCTest
@testable import ParkingFeature

nonisolated final class ParkingTimerConcurrencyTests: XCTestCase {
    @MainActor
    func testNewTimerRequestsLocationWhenObservationStarts() async {
        let service = RecordingLocationService()
        service.requestedLocation = CLLocation(latitude: 51.45, longitude: 6.63)
        let model = ParkingTimerViewModel()
        model.locationService = service

        XCTAssertEqual(service.subscriptionCount, 0)
        XCTAssertEqual(service.requestCount, 0)

        let requested = expectation(description: "Location requested")
        service.requested = requested
        let task = Task { await model.observeLocation() }
        let result = await XCTWaiter.fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(result, .completed)
        service.finish()
        await task.value

        XCTAssertEqual(service.requestCount, 1)
        XCTAssertEqual(model.carPosition?.latitude, 51.45)
        XCTAssertEqual(model.carPosition?.longitude, 6.63)
    }

    @MainActor
    func testCancellationEndsPendingLocationObservation() async {
        let service = RecordingLocationService()
        let model = ParkingTimerViewModel()
        model.locationService = service
        let requested = expectation(description: "Location requested")
        let terminated = expectation(description: "Reader cancelled")
        service.requested = requested
        service.terminated = terminated
        let task = Task { await model.observeLocation() }
        let result = await XCTWaiter.fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(result, .completed)

        task.cancel()
        await task.value
        let termination = await XCTWaiter.fulfillment(of: [terminated], timeout: 2)
        XCTAssertEqual(termination, .completed)
        XCTAssertNil(model.carPosition)
    }

    @MainActor
    func testDisabledAndRestoredTimersDoNotRequestLocation() async {
        let service = RecordingLocationService()
        let model = ParkingTimerViewModel()
        model.locationService = service
        model.saveParkingLocation = false
        await model.observeLocation()

        let restored = ParkingTimerViewModel(data: .init(endDate: Date(), shouldSendNotifications: false))
        restored.locationService = service
        await restored.observeLocation()
        XCTAssertEqual(service.requestCount, 0)
        XCTAssertEqual(service.subscriptionCount, 0)
    }

    @MainActor
    func testPendingLocationDoesNotChangeStartedTimer() async {
        let service = RecordingLocationService()
        let model = ParkingTimerViewModel()
        model.locationService = service
        let requested = expectation(description: "Location requested")
        service.requested = requested
        let task = Task { await model.loadCurrentLocation() }
        let result = await XCTWaiter.fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(result, .completed)

        model.timerStarted = true
        service.send(CLLocation(latitude: 51.45, longitude: 6.63))
        await task.value
        XCTAssertNil(model.carPosition)
    }

    @MainActor
    func testDiscardedModelHasNoLocationReaderAndIsReleased() async {
        let service = RecordingLocationService()
        var model: ParkingTimerViewModel? = ParkingTimerViewModel()
        model?.locationService = service
        weak var retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
        XCTAssertEqual(service.subscriptionCount, 0)
    }
}
