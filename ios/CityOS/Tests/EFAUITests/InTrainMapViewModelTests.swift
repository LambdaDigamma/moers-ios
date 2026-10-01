import XCTest
@testable import EFAUI

@MainActor
final class InTrainMapViewModelTests: XCTestCase {
    func testUnusedModelDoesNotStartLocationAndIsReleased() async {
        let location = RecordingCoreLocationObject()
        var model: InTrainMapViewModel? = InTrainMapViewModel(locationObject: location)
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
        XCTAssertEqual(location.startCount, 0)
    }

    func testStartIsIdempotentAndStopReleasesModel() async {
        let location = RecordingCoreLocationObject()
        var model: InTrainMapViewModel? = InTrainMapViewModel(locationObject: location)
        model?.start()
        model?.start()
        XCTAssertEqual(location.startCount, 1)
        model?.stop()
        XCTAssertEqual(location.stopCount, 1)
        weak let retainedModel = model
        model = nil
        XCTAssertNil(retainedModel)
    }

    func testCancelledLoadDoesNotApplyLateResponse() async throws {
        let service = SuspendedTransitService()
        let model = InTrainMapViewModel(locationObject: RecordingCoreLocationObject())
        model.transitService = service
        let requested = expectation(description: "Transit request started")
        service.requested = requested
        let task = Task { await model.load() }
        let result = await XCTWaiter.fulfillment(of: [requested], timeout: 2)
        XCTAssertEqual(result, .completed)
        task.cancel()
        try await service.finish()
        await task.value
        if case .loading = model.polyline {} else { XCTFail("Cancelled load changed polylines") }
        if case .loading = model.points {} else { XCTFail("Cancelled load changed points") }
    }
}
