import Foundation
import ModernNetworking
@testable import MMFeeds

@MainActor
final class ControlledPostService: PostService {
    var loadedFeedIDs: [Feed.ID] = []
    var refreshedFeedIDs: [Feed.ID] = []
    var onLoad: (() -> Void)?
    var onRefresh: (() -> Void)?
    var onCancellation: (() -> Void)?
    private var pendingRefresh: CheckedContinuation<ResourceCollection<Post>, Error>?

    func index(for feedID: Feed.ID, page: Int, perPage: Int, cacheMode: CacheMode) async throws -> ResourceCollection<Post> {
        switch cacheMode {
        case .revalidate:
            refreshedFeedIDs.append(feedID)
            return try await withTaskCancellationHandler {
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
        default:
            loadedFeedIDs.append(feedID)
            onLoad?()
            return ResourceCollection(data: [], links: .init(), meta: .init())
        }
    }

    func show(for postID: Post.ID, cacheMode: CacheMode) async throws -> Resource<Post> {
        Resource(data: Post.stub(withID: postID))
    }

    func completeRefresh(error: Error? = nil) {
        guard let continuation = pendingRefresh else { return }
        pendingRefresh = nil
        if let error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume(returning: ResourceCollection(data: [], links: .init(), meta: .init()))
        }
    }

    nonisolated deinit {}
}
