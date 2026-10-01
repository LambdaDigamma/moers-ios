import XCTest
import AVFoundation
@testable import PlaybackKit

@MainActor
final class PlaybackKitTests: XCTestCase {
    func testPlaybackItemCreatesAssetFromMetadataURL() async throws {
        let url = URL(string: "https://example.com/audio.mp3")!
        let metadata = NowPlayableStaticMetadata(
            assetURL: url,
            mediaType: .audio,
            isLiveStream: false,
            title: "Audio"
        )
        let item = PlaybackItem(metadata: metadata)
        let asset = try XCTUnwrap(item.asset as? AVURLAsset)
        XCTAssertEqual(asset.url, url)
        XCTAssertEqual(item.metadata, metadata)
    }
}
