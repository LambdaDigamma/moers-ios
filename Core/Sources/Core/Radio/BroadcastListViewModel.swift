//
//  BroadcastListViewModel.swift
//  
//
//  Created by Lennart Fischer on 24.09.21.
//

import Foundation
import Combine

public class BroadcastListViewModel: StandardViewModel {
    
    @Published public var upcomingBroadcasts: [RadioBroadcast] = []
    @Published public var broadcasts: [RadioBroadcast] = []
    
    private let service: RadioServiceProtocol
    
    public init(service: RadioServiceProtocol) {
        self.service = service
    }
    
    public func load() {
        
        self.service.load()
            .sink { (completion: Subscribers.Completion<Error>) in
                print(completion)
            } receiveValue: { (broadcasts: [RadioBroadcast]) in
                self.upcomingBroadcasts = Array(broadcasts.prefix(8))
                self.broadcasts = broadcasts
            }
            .store(in: &cancellables)
        
    }
    
}
