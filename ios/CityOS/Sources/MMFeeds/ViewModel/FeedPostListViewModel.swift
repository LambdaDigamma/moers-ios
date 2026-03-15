//
//  FeedPostListViewModel.swift
//  
//
//  Created by Lennart Fischer on 11.01.21.
//

import Foundation
import Combine
import ModernNetworking
import Factory

@MainActor
public class FeedPostListViewModel: ObservableObject {
    
    public var feedID: Feed.ID {
        didSet {
            prepareFeed(with: feedID)
        }
    }
    
    @Published public var items: UIResource<[Post]> = .loading
    
    private var cancellables = Set<AnyCancellable>()
    
    private let repository: PostRepository
    
    /// This is the current page the last load took place for.
    private var currentPage: Int
    
    /// Determines how many posts should be loaded per page request.
    private let postsPerLoad: Int
    
    private var lastPage: Int?
    
    /// Determines whether the first load of the feed should happen right away
    private let automaticallyLoadFirstPage: Bool
    
    private let dataLoadingEnabled: Bool
    
    @Injected(\.feedService) private var feedService
    
    /// This initializes the view model with a `Feed.ID`.
    public init(
        feedID: Feed.ID,
        postsPerLoad: Int = 10,
        automaticallyLoadFirstPage: Bool = true
    ) {
        
        self.feedID = feedID
        self.repository = Container.shared.postRepository()
        self.postsPerLoad = postsPerLoad
        self.dataLoadingEnabled = true
        self.automaticallyLoadFirstPage = automaticallyLoadFirstPage
        self.currentPage = 1
        
//        if automaticallyLoadFirstPage {
//            loadCurrentFeed()
//        }
        
        self.setupObserver()
        
    }
    
    /// This initializes the view model with some already
    /// loaded and ready to present post overviews.
    public init(feedID: Feed.ID, posts: [Post]) {
        self.repository = Container.shared.postRepository()
        self.items = .success(posts)
        self.feedID = feedID
        self.dataLoadingEnabled = false
        self.postsPerLoad = 10
        self.automaticallyLoadFirstPage = false
        self.currentPage = 1
    }
    
    /// Resets the post current post list and loads triggers
    /// reload of new feed to update the UI.
    public func prepareFeed(with: Feed.ID) {
        
        switch items {
            case .success(_):
                items = .success([])
            default: break
        }
        
    }
    
    // MARK: -
    
    /// Call the reload method on UI events like `onAppear` in order to reload
    /// the data from network if the cached data is not up to date according
    /// to protocol cache information.
    public func reload() async {
        do {
            try await repository.reloadFeed(for: feedID, perPage: 50)
        } catch {
            print("Failed to reload feed: \(error)")
        }
    }
    
    public func refresh() async {
        do {
            try await repository.refreshFeed(for: feedID, perPage: 50)
        } catch {
            print("Failed to refresh feed: \(error)")
        }
    }
    
    // MARK: - Observer
    
    public func setupObserver() {
        
        repository
            .postsPublisher(feedID: feedID)
            .map({ (posts: [Post]) in
                return UIResource.success(posts)
            })
            .catch({ (error: Error) in
                return Just(UIResource.error(error))
            })
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (state: UIResource<[Post]>) in
                
                self.items = state
                
            }
            .store(in: &cancellables)
        
    }
    
    /// Loads the first items of the feed with the previously set `postsPerLoad`
//    public func loadCurrentFeed() {
//
//        guard dataLoadingEnabled else { return }
//
//        guard let feedService = feedService else {
//            print("No feed service was provided so data loading cannot take place.")
//            return
//        }
//
//        feedService
//            .loadFeedFromNetwork(feedID: feedID, perPage: 10)
//            .receive(on: DispatchQueue.main)
//            .sink { (completion: Subscribers.Completion<Error>) in
//                switch completion {
//                    case .failure(let error):
//                        print(error)
//                    default: break
//                }
//            } receiveValue: { (feed: Feed) in
//                print(feed.posts)
//                self.items.append(contentsOf: feed.posts)
//            }.store(in: &cancellables)
//
//    }
    
//    public func loadNextPosts() {
//
//        if currentPage == lastPage ?? 0 {
//            return
//        }
//
//        currentPage += 1
//
//        feedService?
//            .loadPosts(for: feedID, page: currentPage, perPage: postsPerLoad)
//            .receive(on: DispatchQueue.main)
//            .sink { (completion: Subscribers.Completion<Error>) in
//                switch completion {
//                    case .failure(let error):
//                        print(error)
//                    default: break
//                }
//            } receiveValue: { (resourceCollection: ResourceCollection<Post>) in
//                print(resourceCollection)
//
//                self.items.append(contentsOf: resourceCollection.data)
//                self.lastPage = resourceCollection.meta.lastPage
//
//            }.store(in: &cancellables)
//
//    }

    public var lastPageReached: Bool {
        return currentPage == lastPage ?? 0
    }
    
}

public enum PageLoadingOptions {
    case next
    case page(Int)
}
