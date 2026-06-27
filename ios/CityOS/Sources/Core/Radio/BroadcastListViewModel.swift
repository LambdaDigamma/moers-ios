//
//  BroadcastListViewModel.swift
//  
//
//  Created by Lennart Fischer on 24.09.21.
//

import Foundation
import Combine
import Observation

@MainActor
@Observable
public class BroadcastListViewModel: StandardViewModel {
    
    public var upcomingBroadcasts: [RadioBroadcast] = []
    public var broadcasts: [RadioBroadcast] = []
    public var viewModels: [RadioBroadcastViewModel] = []
    
    private let service: RadioServiceProtocol
    
    public init(service: RadioServiceProtocol) {
        self.service = service
    }
    
    public func load() {
        
        self.service.load()
            .sink { (completion: Subscribers.Completion<Error>) in
                print(completion)
            } receiveValue: { [weak self] (broadcasts: [RadioBroadcast]) in
                Task { @MainActor in
                    self?.apply(broadcasts)
                }
            }
            .store(in: &cancellables)
        
    }

    private func apply(_ broadcasts: [RadioBroadcast]) {
        self.upcomingBroadcasts = Array(broadcasts.prefix(8))
        self.broadcasts = broadcasts
        self.viewModels = self.upcomingBroadcasts.map { $0.toViewModel() }
    }
    
}
