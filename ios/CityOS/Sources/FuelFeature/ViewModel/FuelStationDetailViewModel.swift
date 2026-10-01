//
//  FuelStationDetailViewModel.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import Core
import Observation

@MainActor
@Observable
public class FuelStationDetailViewModel: StandardViewModel {
    
    public var state: DataState<PetrolStation, Error> = .loading
    
    private let loadDetails: () async throws -> PetrolStation
    
    public init(
        loadDetails: @escaping () async throws -> PetrolStation
    ) {
        self.loadDetails = loadDetails
    }
    
    public func load() async {
        do {
            let fuelStation = try await loadDetails()
            self.state = .success(fuelStation)
        } catch {
            self.state = .error(error)
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
