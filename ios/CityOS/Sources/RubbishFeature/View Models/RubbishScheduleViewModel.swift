//
//  RubbishScheduleViewModel.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation
import Core
import FactoryKit
import Observation

@MainActor
@Observable
public class RubbishScheduleViewModel: StandardViewModel {
    
    @ObservationIgnored @LazyInjected(\.rubbishService) var rubbishService
    
    var state: DataState<[RubbishSection], RubbishLoadingError> = .loading
    
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
