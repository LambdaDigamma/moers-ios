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
    
    public init(postID: Post.ID) {
        self.postID = postID
        self.repository = Container.shared.postRepository()
        self.setupObserver()
    }
    
    public func setupObserver() {
        
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
            .sink { (state: DataState<Post, Error>) in
                
                self.state = state
                
                if let pageID = state.value?.pageID {
                    self.pageViewModel = NativePageViewModel(pageID: pageID)
                    self.setupPageListener()
                    self.pageID = pageID
                } else {
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
        do {
            try await repository.reloadPost(for: postID)
        } catch {
            print("Failed to reload post: \(error)")
        }
    }
    
    public func refresh() async {
        do {
            try await repository.refreshPost(for: postID)
            if let pageViewModel = pageViewModel {
                await pageViewModel.refresh()
            }
        } catch {
            print("Failed to refresh post: \(error)")
        }
    }
    
}
