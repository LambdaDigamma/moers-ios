//
//  RubbishScheduleViewModel.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation
import Core
import Factory

@MainActor
public class RubbishScheduleViewModel: StandardViewModel {
    
    @LazyInjected(\.rubbishService) var rubbishService
    
    @Published var state: DataState<[RubbishSection], RubbishLoadingError> = .loading
    
    public init(
        initialState: DataState<[RubbishSection], RubbishLoadingError> = .loading
    ) {
        self.state = initialState
        super.init()
    }
    
    public func load() async {
        self.setLoading()
        
        if !rubbishService.isEnabled {
            state = .error(.deactivated)
            return
        }
        
        guard let street = rubbishService.rubbishStreet else {
            state = .error(.noStreetConfigured)
            return
        }
        
        do {
            let items = try await rubbishService.loadRubbishPickupItems(for: street)
            let grouped = items.groupByDayIntoSections()
            self.state = .success(grouped)
        } catch let error as RubbishLoadingError {
            self.state = .error(error)
        } catch {
            let rubbishError: RubbishLoadingError
            if let apiError = error as? APIError {
                rubbishError = .internalError(apiError)
            } else {
                rubbishError = .internalError(APIError.networkError(error))
            }
            self.state = .error(rubbishError)
        }
    }
    
    public func setLoading() {
        self.state = .loading
    }
    
}
