//
//  PetrolPriceDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import Combine
import Core
import CoreLocation
import Resolver

public struct PetrolPriceDashboardData {
    
    public let averagePrice: Double
    public let numberOfStations: Int
    
}

public class PetrolPriceDashboardViewModel: StandardViewModel {
    
    @Published var data: DataState<PetrolPriceDashboardData, Error> = .loading
    
    private let petrolService: PetrolService
    
    public init(
        petrolService: PetrolService = Resolver.resolve(),
        initialState: DataState<PetrolPriceDashboardData, Error> = .loading
    ) {
        self.petrolService = petrolService
        self.data = initialState
        super.init()
    }
    
    public func load() {
        
        let petrolType = petrolService.petrolType
        
        self.petrolService.getPetrolStations(
            coordinate: CoreSettings.regionCenter,
            radius: 25.0,
            sorting: .distance,
            type: petrolType,
            shouldReload: false
        )
            .sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        self.data = .error(error)
                    default: break
                }
                
            } receiveValue: { [weak self] (petrolStations: [PetrolStation]) in
                
                self?.calculateNewAverage(from: petrolStations)
                
            }
            .store(in: &cancellables)
            
    }
    
    public func calculateNewAverage(from petrolStations: [PetrolStation]) {
        
        let openStations = petrolStations.filter { $0.isOpen && $0.price != nil }
        let numberOfStations = openStations.count
        
        let priceSum = openStations.reduce(0) { (result, item) in
            return result + (item.price ?? 0)
        }
        
        self.data = .success(PetrolPriceDashboardData(
            averagePrice: priceSum / Double(numberOfStations),
            numberOfStations: numberOfStations
        ))
        
    }

}
