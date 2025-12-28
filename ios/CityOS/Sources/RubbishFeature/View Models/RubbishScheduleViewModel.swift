//
//  RubbishScheduleViewModel.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation
import Core
import Factory

public class RubbishScheduleViewModel: StandardViewModel {
    
    @LazyInjected(\.rubbishService) var rubbishService
    
    @Published var state: DataState<[RubbishSection], RubbishLoadingError> = .loading
    
    public init(
        initialState: DataState<[RubbishSection], RubbishLoadingError> = .loading
    ) {
        self.state = initialState
        super.init()
    }
    
    public func load() {
        self.setLoading()
        
        if !rubbishService.isEnabled {
            state = .error(.deactivated)
            return
        }
        
        guard let street = rubbishService.rubbishStreet else {
            state = .error(.noStreetConfigured)
            return
        }
        
        Task {
            do {
                let items = try await rubbishService.loadRubbishPickupItems(for: street)
                let grouped = items.groupByDayIntoSections()
                
                await MainActor.run {
                    self.state = .success(grouped)
                }
            } catch let error as RubbishLoadingError {
                await MainActor.run {
                    self.state = .error(error)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(.internalError(error as? HTTPError ?? HTTPError.badRequest(nil)))
                }
            }
        }
    }
    
    public func setLoading() {
        self.state = .loading
    }
    
}
