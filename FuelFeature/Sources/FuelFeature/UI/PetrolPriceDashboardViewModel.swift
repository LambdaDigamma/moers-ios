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
    @Published var locationName: DataState<String, Error> = .loading
    
    public private(set) var fuelStations: DataState<[PetrolStation], Error> = .loading
    
    @Published private var defaultSearchRadius = 10.0
    
    private let petrolService: PetrolService
    private let locationService: LocationService
    private let geocodingService: GeocodingService
    
    public init(
        petrolService: PetrolService = Resolver.resolve(),
        locationService: LocationService = Resolver.resolve(),
        geocodingService: GeocodingService = Resolver.resolve(),
        initialState: DataState<PetrolPriceDashboardData, Error> = .loading,
        initialFuelStations: DataState<[PetrolStation], Error> = .loading
    ) {
        self.petrolService = petrolService
        self.locationService = locationService
        self.geocodingService = geocodingService
        self.data = initialState
        self.fuelStations = initialFuelStations
        super.init()
    }
    
    public func load() {
        
        let petrolType = petrolService.petrolType
        
        locationService.requestCurrentLocation()
        
        locationPublisher()
            .flatMap { (location: CLLocation) -> AnyPublisher<String, Never> in
            
                print("Flatmapping")
                
                return self.geocodingService
                    .placemark(from: location)
                    .map(\.city)
                    .replaceError(with: "")
                    .eraseToAnyPublisher()
            
            }
            .replaceError(with: "")
            .map({ DataState.success($0) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(receiveValue: { data in
                self.locationName = data
            })
//            .assign(to: \.locationName, on: self)
            .store(in: &cancellables)
        
        // does this need some kind of debouncing?
        // can multiple locations be received so that
        // too many requests get scheduled?
        
        locationPublisher()
            .flatMap { (location: CLLocation) -> AnyPublisher<[PetrolStation], Error> in

                print("Location: \(location.coordinate)")

                return self.petrolService.getPetrolStations(
                    coordinate: location.coordinate,
                    radius: self.defaultSearchRadius,
                    sorting: .distance,
                    type: petrolType,
                    shouldReload: false
                )
            }
            .eraseToAnyPublisher()
            .sink { (completion: Subscribers.Completion<Error>) in

                switch completion {
                    case .failure(let error):
                        print(error)
                        self.data = .error(error)
                    default: break
                }

            } receiveValue: { [weak self] (petrolStations: [PetrolStation]) in

                self?.fuelStations = DataState<[PetrolStation], Error>.success(petrolStations.filter { $0.isOpen })
                self?.calculateNewAverage(from: petrolStations)

            }
            .store(in: &cancellables)
            
    }
    
    public func calculateNewAverage(from petrolStations: [PetrolStation]) {
        
        print("Total stations: \(petrolStations.count)")
        
        let openStations = petrolStations.filter { $0.isOpen && $0.price != nil }
        let numberOfStations = openStations.count
        
        print("Open stations: \(numberOfStations)")
        
        let priceSum = openStations.reduce(0) { (result, item) in
            return result + (item.price ?? 0)
        }
        
        self.data = .success(PetrolPriceDashboardData(
            averagePrice: priceSum / Double(numberOfStations),
            numberOfStations: numberOfStations
        ))
        
    }
    
    private func locationPublisher() -> AnyPublisher<CLLocation, Never> {
        return locationService
            .location
            .replaceError(with: CoreSettings.regionLocation)
            .filter({ $0.coordinate.latitude != 0.0 && $0.coordinate.longitude != 0.0 })
            .prefix(1)
            .eraseToAnyPublisher()
    }
    
    public func loadFuelStation(id: PetrolStation.ID) -> AnyPublisher<PetrolStation, Error> {
        return petrolService.getPetrolStation(id: id)
    }
    
}
