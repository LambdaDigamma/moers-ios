//
//  NativePageViewModel.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import Foundation
import FactoryKit
import Combine
import Observation

@MainActor
@Observable
public class NativePageViewModel {
    
    @ObservationIgnored
    var cancellables = Set<AnyCancellable>()
    
    private let pageID: Page.ID
    private let repository: PageRepository
    
    public var state: DataState<Page, Error> = .loading {
        didSet {
            stateSubject.send(state)
        }
    }

    @ObservationIgnored
    private let stateSubject = CurrentValueSubject<DataState<Page, Error>, Never>(.loading)

    public var statePublisher: AnyPublisher<DataState<Page, Error>, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    public init(pageID: Page.ID, repository: PageRepository = Container.shared.pageRepository()) {
        self.pageID = pageID
        self.repository = repository
    }
    
    public func setupObserver() {
        guard cancellables.isEmpty else { return }
        
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
            .sink { [weak self] (state: DataState<Page, Error>) in
                self?.state = state
            }
            .store(in: &cancellables)
           
    }
    
    /// Call the reload method on UI events like `onAppear` in order to reload
    /// the data from network if the cached data is not up to date according
    /// to protocol cache information.
    public func reload() async {
        guard !Task.isCancelled else { return }
        setupObserver()
        do {
            try await repository.reloadPage(for: pageID)
        } catch {
            print("Failed to reload page: \(error)")
        }
    }
    
    public func refresh() async {
        do {
            try await repository.refreshPage(for: pageID)
        } catch {
            print("Failed to refresh page: \(error)")
        }
    }
    
    public func cancel() {
        
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
