import Combine
import XCTest
@testable import Core

@MainActor
final class ModelDeinitializationTests: XCTestCase {
    func testSynchronousReleaseCancelsSubscriptionsAndKeepsTaskLocalScope() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                XCTAssertTrue(Thread.isMainThread)
                ModelDeinitializationTaskLocal.$marker.withValue(17) {
                    var cancellations = 0
                    var model: StandardViewModel? = StandardViewModel()
                    let publisher = PassthroughSubject<Void, Never>()
                    publisher
                        .handleEvents(receiveCancel: { cancellations += 1 })
                        .sink { _ in }
                        .store(in: &model!.cancellables)
                    weak let releasedModel = model

                    model = nil

                    XCTAssertNil(releasedModel)
                    XCTAssertEqual(cancellations, 1)
                    XCTAssertEqual(ModelDeinitializationTaskLocal.marker, 17)
                }
                XCTAssertEqual(ModelDeinitializationTaskLocal.marker, 0)
                continuation.resume()
            }
        }
    }
}
