//
//  NativePageViewModel.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import Foundation
import Resolver
import Combine
import Factory

public class NativePageViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    private let pageID: Page.ID
    private let repository: PageRepository
    
    @Published public var state: DataState<Page, Error> = .loading
    
    public init(pageID: Page.ID) {
        self.pageID = pageID
        self.repository = Container.shared.pageRepository()
        self.setupObserver()
    }
    
    public func setupObserver() {
        
        repository
            .pagePublisher(pageID: pageID)
            .map({ (page: Page?) -> DataState<Page, Error> in
                
                if let page {
                    return DataState<Page, Error>.success(page)
                } else {
                    return DataState<Page, Error>.loading
                }
                
            })
            .catch({ (error: Error) in
                return Just(DataState<Page, Error>.error(error))
            })
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { (state: DataState<Page, Error>) in
                self.state = state
            }
            .store(in: &cancellables)
           
    }
    
    /// Call the reload method on UI events like `onAppear` in order to reload
    /// the data from network if the cached data is not up to date according
    /// to protocol cache information.
    public func reload() {
        
        Task {
            try await repository.reloadPage(for: pageID)
        }
        
    }
    
    public func refresh() {
        
        Task {
            try await repository.refreshPage(for: pageID)
        }
        
    }
    
    public func cancel() {
        
        self.cancellables.forEach { $0.cancel() }
        
    }
    
}
