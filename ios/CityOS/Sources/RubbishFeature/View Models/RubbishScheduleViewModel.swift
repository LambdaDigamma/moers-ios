//
//  RubbishScheduleViewModel.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation
import Core
import Resolver
import Combine

public class RubbishScheduleViewModel: StandardViewModel {
    
    @LazyInjected var rubbishService: RubbishService
    @Published var state: DataState<[RubbishSection], RubbishLoadingError> = .loading
    
    public init(
        rubbishService: RubbishService? = nil,
        initialState: DataState<[RubbishSection], RubbishLoadingError> = .loading
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
                    
                    let grouped = items.groupByDayIntoSections()
                    
                    self?.state = .success(grouped)
                    
                }
                .store(in: &cancellables)
            
        } else {
            state = .error(.noStreetConfigured)
        }
        
    }
    
    public func setLoading() {
        self.state = .loading
    }
    
}
