//
//  FuelStationDetailViewModel.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import Core

public class FuelStationDetailViewModel: StandardViewModel {
    
    @Published public var state: DataState<PetrolStation, Error> = .loading
    
    private let loadDetails: () async throws -> PetrolStation
    
    public init(
        loadDetails: @escaping () async throws -> PetrolStation
    ) {
        self.loadDetails = loadDetails
    }
    
    public func load() {
        Task {
            do {
                let fuelStation = try await loadDetails()
                await MainActor.run {
                    self.state = .success(fuelStation)
                }
            } catch {
                await MainActor.run {
                    self.state = .error(error)
                }
            }
        }
    }
    
}
