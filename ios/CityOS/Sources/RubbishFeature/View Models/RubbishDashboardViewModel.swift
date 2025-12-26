//
//  RubbishDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 22.12.21.
//

import Foundation
import Combine
import Core
import ModernNetworking
import Factory

open class RubbishDashboardViewModel: StandardViewModel {
    
    @Published var state: DataState<[RubbishPickupItem], RubbishLoadingError> = .loading
    @LazyInjected(\.rubbishService) var rubbishService
    
    public init(
        rubbishService: RubbishService? = nil,
        initialState: DataState<[RubbishPickupItem], RubbishLoadingError> = .loading
    ) {
        self.state = initialState
        super.init()
        
        if let rubbishService = rubbishService {
            self.rubbishService = rubbishService
        }
    }
    
    public func load() {
        
        self.setLoading()
        
        if !rubbishService.isEnabled {
            state = .error(.deactivated)
        }
        
        if let street = rubbishService.rubbishStreet {
            
            rubbishService
                .loadRubbishPickupItems(for: street)
                .sink { [weak self] (completion: Subscribers.Completion<RubbishLoadingError>) in
                    
                    switch completion {
                        case .failure(let error):
                            self?.state = .error(error)
                        default:
                            break
                    }
                    
                } receiveValue: { [weak self] (items: [RubbishPickupItem]) in
                    
                    self?.state = .success(items)
                    
                }
                .store(in: &cancellables)
                
        } else {
            state = .error(.noStreetConfigured)
        }
        
    }
    
    private func setLoading() {
        self.state = .loading
    }
    
}

public extension Date {
    
    static func todayPlusNDays(_ number: Int) -> [Date] {
        
        let range = 0...number
        
        return range.map({ Date(timeIntervalSinceNow: TimeInterval($0 * 24 * 60 * 60)) })
        
    }
    
}
