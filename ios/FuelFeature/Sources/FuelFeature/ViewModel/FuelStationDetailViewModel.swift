//
//  FuelStationDetailViewModel.swift
//  
//
//  Created by Lennart Fischer on 30.01.22.
//

import Foundation
import Core
import Combine

public class FuelStationDetailViewModel: StandardViewModel {
    
    @Published public var state: DataState<PetrolStation, Error> = .loading
    
    private let loadDetails: () -> AnyPublisher<PetrolStation, Error>
    
    public init(
        loadDetails: @escaping () -> AnyPublisher<PetrolStation, Error>
    ) {
        self.loadDetails = loadDetails
    }
    
    public func load() {
        
        loadDetails()
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { (fuelStation: PetrolStation) in
                self.state = .success(fuelStation)
            }
            .store(in: &cancellables)
        
    }
    
}
