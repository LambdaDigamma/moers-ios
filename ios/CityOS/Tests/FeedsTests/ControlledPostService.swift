import Foundation
import ModernNetworking
@testable import Feeds

@MainActor
final class ControlledPostService: PostService {
    var posts: [Post] = []
    var loadedFeedIDs: [Feed.ID] = []
    var refreshedFeedIDs: [Feed.ID] = []
    var onLoad: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onCancellation: (() -> Void)?
    private var pendingRefresh: CheckedContinuation<Void, Error>?

    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) async throws -> ResourceCollection<Post> {
        switch cacheMode {
        case .revalidate:
            refreshedFeedIDs.append(feedID)
            try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    pendingRefresh = continuation
                    onRefresh?()
                }
            } onCancel: {
                Task { @MainActor [weak self] in
                    self?.completeRefresh(error: CancellationError())
                    self?.onCancellation?()
                }
            }
            return ResourceCollection(data: posts, links: .init(), meta: .init())
        default:
            loadedFeedIDs.append(feedID)
            onLoad?()
            return ResourceCollection(data: posts, links: .init(), meta: .init())
        }
    }

    func show(for postID: Post.ID, cacheMode: CacheMode) async throws -> Resource<Post> {
        Resource(data: Post.stub(withID: postID))
    }

    func completeRefresh(posts: [Post] = [], error: Error? = nil) {
        guard let continuation = pendingRefresh else { return }
        pendingRefresh = nil
        if let error {
            continuation.resume(throwing: error)
        } else {
            self.posts = posts
            continuation.resume()
        }
    }

    nonisolated deinit {}
}
