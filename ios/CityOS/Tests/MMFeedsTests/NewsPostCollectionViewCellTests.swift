import UIKit
import XCTest
@testable import MMFeeds

@MainActor
final class NewsPostCollectionViewCellTests: XCTestCase {
    func testReconfigurationCancelsPreviousImageAndRejectsItsLateCompletion() async throws {
        var completions: [(UIImage?) -> Void] = []
        var cancellationCount = 0
        let cell = NewsPostCollectionViewCell(frame: .zero) { _, completion in
            completions.append(completion)
            return { cancellationCount += 1 }
        }
        cell.configure(with: post(imageURL: "https://example.com/original.png"))
        cell.configure(with: post(imageURL: "https://example.com/updated.png"))
        XCTAssertEqual(cancellationCount, 1)
        XCTAssertEqual(completions.count, 2)

        let updatedImage = try XCTUnwrap(UIImage(systemName: "heart"))
        completions[1](updatedImage)
        await flushImageCallbacks()
        let imageView = try mediaImageView(in: cell)
        XCTAssertTrue(imageView.image === updatedImage)

        completions[0](try XCTUnwrap(UIImage(systemName: "star")))
        await flushImageCallbacks()
        XCTAssertTrue(imageView.image === updatedImage)
    }

    func testRemovingMediaCancelsPreviousImageAndRejectsItsLateCompletion() async throws {
        var completion: ((UIImage?) -> Void)?
        var cancellationCount = 0
        let cell = NewsPostCollectionViewCell(frame: .zero) { _, callback in
            completion = callback
            return { cancellationCount += 1 }
        }
        cell.configure(with: post(imageURL: "https://example.com/original.png"))
        cell.configure(with: post(imageURL: nil))
        XCTAssertEqual(cancellationCount, 1)

        try XCTUnwrap(completion)(try XCTUnwrap(UIImage(systemName: "star")))
        await flushImageCallbacks()
        let imageView = try mediaImageView(in: cell)
        XCTAssertNil(imageView.image)
        XCTAssertTrue(imageView.isHidden)
    }

    func testReuseRejectsAnImageCompletionAlreadyInFlight() async throws {
        var completion: ((UIImage?) -> Void)?
        let cell = NewsPostCollectionViewCell(frame: .zero) { _, callback in
            completion = callback
            return {}
        }
        cell.configure(with: post(imageURL: "https://example.com/original.png"))
        cell.prepareForReuse()
        try XCTUnwrap(completion)(try XCTUnwrap(UIImage(systemName: "star")))
        await flushImageCallbacks()
        XCTAssertNil(try mediaImageView(in: cell).image)
    }

    private func post(imageURL: String?) -> Post {
        var post = Post.stub(withID: 42)
        if let imageURL {
            post.extras = PostExtras(
                cta: nil,
                videoFiles: nil,
                videoThumbnails: .init(thumbnails: [
                    .init(link: URL(string: imageURL), width: nil, height: nil, linkWithPlayButton: nil)
                ]),
                type: nil
            )
        }
        return post
    }

    private func mediaImageView(in cell: NewsPostCollectionViewCell) throws -> UIImageView {
        let card = try XCTUnwrap(cell.contentView.subviews.first)
        return try XCTUnwrap(card.subviews.compactMap { $0 as? UIImageView }.first)
    }

    private func flushImageCallbacks() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }
}
