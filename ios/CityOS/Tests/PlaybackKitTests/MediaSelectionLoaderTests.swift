import AVFoundation
import XCTest
@testable import PlaybackKit

@MainActor
final class MediaSelectionLoaderTests: XCTestCase {
    func testLoadsEachCurrentItemOnce() async {
        var loadCount = 0
        let loaded = expectation(description: "Media options loaded")
        let loader = MediaSelectionLoader { _ in
            loadCount += 1
            return []
        }
        let item = AVPlayerItem(asset: AVMutableComposition())

        loader.load(for: item) { loaded.fulfill() }
        await fulfillment(of: [loaded], timeout: 1)
        loader.load(for: item) { XCTFail("Repeated item must use cached groups") }

        XCTAssertEqual(loadCount, 1)
    }

    func testReplacingItemIgnoresPreviousLoadCompletion() async {
        let firstStarted = expectation(description: "First load started")
        let firstFinished = expectation(description: "First load finished")
        let secondLoaded = expectation(description: "Second item loaded")
        let firstAsset = AVMutableComposition()
        let firstItem = AVPlayerItem(asset: firstAsset)
        let secondItem = AVPlayerItem(asset: AVMutableComposition())
        var firstContinuation: CheckedContinuation<[AVMediaSelectionGroup], Never>?
        var staleUpdates = 0
        let loader = MediaSelectionLoader { asset in
            if asset === firstAsset {
                defer { firstFinished.fulfill() }
                return await withCheckedContinuation { continuation in
                    firstContinuation = continuation
                    firstStarted.fulfill()
                }
            }
            return []
        }

        loader.load(for: firstItem) { staleUpdates += 1 }
        await fulfillment(of: [firstStarted], timeout: 1)
        loader.load(for: secondItem) { secondLoaded.fulfill() }
        await fulfillment(of: [secondLoaded], timeout: 1)
        firstContinuation?.resume(returning: [])
        await fulfillment(of: [firstFinished], timeout: 1)

        XCTAssertEqual(staleUpdates, 0)
    }

    func testCancellationPreventsUpdateAfterLoadCompletes() async {
        let started = expectation(description: "Load started")
        let finished = expectation(description: "Load finished")
        var pending: CheckedContinuation<[AVMediaSelectionGroup], Never>?
        var updates = 0
        let loader = MediaSelectionLoader { _ in
            defer { finished.fulfill() }
            return await withCheckedContinuation { continuation in
                pending = continuation
                started.fulfill()
            }
        }

        loader.load(for: AVPlayerItem(asset: AVMutableComposition())) { updates += 1 }
        await fulfillment(of: [started], timeout: 1)
        loader.cancel()
        pending?.resume(returning: [])
        await fulfillment(of: [finished], timeout: 1)

        XCTAssertEqual(updates, 0)
        XCTAssertTrue(loader.groups.isEmpty)
    }

    func testPendingLoadDoesNotRetainLoader() async {
        let started = expectation(description: "Load started")
        let finished = expectation(description: "Load finished")
        var pending: CheckedContinuation<[AVMediaSelectionGroup], Never>?
        var loader: MediaSelectionLoader? = MediaSelectionLoader { _ in
            defer { finished.fulfill() }
            return await withCheckedContinuation { continuation in
                pending = continuation
                started.fulfill()
            }
        }

        loader?.load(for: AVPlayerItem(asset: AVMutableComposition())) {
            XCTFail("Released loader must not publish media options")
        }
        await fulfillment(of: [started], timeout: 1)
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                weak let releasedLoader = loader
                loader = nil
                XCTAssertNil(releasedLoader)
                continuation.resume()
            }
        }
        pending?.resume(returning: [])
        await fulfillment(of: [finished], timeout: 1)
    }

    func testDefaultLoaderHandlesAssetWithoutLanguageOptions() async {
        let loaded = expectation(description: "Composition loaded")
        let loader = MediaSelectionLoader()
        loader.load(for: AVPlayerItem(asset: AVMutableComposition())) { loaded.fulfill() }

        await fulfillment(of: [loaded], timeout: 2)
        XCTAssertTrue(loader.groups.isEmpty)
    }
}
