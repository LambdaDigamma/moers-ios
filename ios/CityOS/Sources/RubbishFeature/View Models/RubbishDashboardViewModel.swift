//
//  RubbishDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 22.12.21.
//

import Foundation
import Core
import ModernNetworking
import Factory

@MainActor
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
            self.state = .success(items)
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
