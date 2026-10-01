//
//  PostViewModel.swift
//  
//
//  Created by Lennart Fischer on 09.04.23.
//

import Foundation
import MMPages
import FactoryKit
import Combine
import SwiftUI

@MainActor
@Observable
public class PostViewModel {
    
    @ObservationIgnored
    var cancellables = Set<AnyCancellable>()
    @ObservationIgnored
    private var pageCancellable: AnyCancellable?
    
    private let postID: Post.ID
    private let repository: PostRepository
    
    public var pageViewModel: NativePageViewModel?
    
    var pageID: Page.ID?
    var state: DataState<Post, Error> = .loading
    var pageState: DataState<Page, Error> = .loading
    
    public init(postID: Post.ID, repository: PostRepository = Container.shared.postRepository()) {
        self.postID = postID
        self.repository = repository
    }
    
    public func setupObserver() {
        guard cancellables.isEmpty else { return }
        
        repository
            .postPublisher(postID: postID)
            .map({ (post: Post?) -> DataState<Post, Error> in
                
                if let post {
                    return DataState<Post, Error>.success(post)
                } else {
                    return DataState<Post, Error>.loading
                }
                
            })
            .catch({ (error: Error) in
                
                return Just(DataState<Post, Error>.error(error))
            })
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (state: DataState<Post, Error>) in
                guard let self else { return }
                
                self.state = state
                
                if let pageID = state.value?.pageID {
                    if self.pageID != pageID || self.pageViewModel == nil {
                        self.pageViewModel?.cancel()
                        self.pageViewModel = NativePageViewModel(pageID: pageID)
                    }
                    self.setupPageListener()
                    self.pageID = pageID
                } else {
                    self.pageCancellable?.cancel()
                    self.pageCancellable = nil
                    self.pageViewModel?.cancel()
                    self.pageViewModel = nil
                    self.pageID = nil
                }
                
            }
            .store(in: &cancellables)
        
        
        
    }
    
    private func setupPageListener() {
        pageCancellable = pageViewModel?.statePublisher.sink { [weak self] (state: DataState<Page, Error>) in
            print("Received new page state", state)
            self?.pageState = state
        }
    }
    
    /// Call the reload method on UI events like `onAppear` in order to reload
    /// the data from network if the cached data is not up to date according
    /// to protocol cache information.
    public func reload() async {
        guard !Task.isCancelled else { return }
        setupObserver()
        do {
            try await repository.reloadPost(for: postID)
        } catch {
            print("Failed to reload post: \(error)")
        }
    }
    
    public func refresh() async {
        guard !Task.isCancelled else { return }
        setupObserver()
        do {
            try await repository.refreshPost(for: postID)
            if let pageViewModel = pageViewModel {
                await pageViewModel.refresh()
            }
        } catch {
            print("Failed to refresh post: \(error)")
        }
    }
    
    public func cancel() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        pageCancellable?.cancel()
        pageCancellable = nil
        pageViewModel?.cancel()
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
