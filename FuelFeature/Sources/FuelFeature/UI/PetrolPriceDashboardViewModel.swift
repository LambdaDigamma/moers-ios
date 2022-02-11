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
import OSLog

public struct PetrolPriceDashboardData {
    
    public let averagePrice: Double
    public let numberOfStations: Int
    
}

public class PetrolPriceDashboardViewModel: StandardViewModel {
    
    @Published var petrolType: PetrolType = .diesel
    @Published var data: DataState<PetrolPriceDashboardData, Error> = .loading
    @Published var locationName: DataState<String, Error> = .loading
    
    public private(set) var fuelStations: DataState<[PetrolStation], Error> = .loading
    
    @Published private var defaultSearchRadius = 10.0
    
    private let logger: Logger = Logger(subsystem: Bundle.main.bundlePath, category: "PetrolPriceDashboardViewModel")
    
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
    
    /// Reloads location and updates the fuel stations
    /// and average price data of the dashboard.
    public func load() {
        
        self.petrolType = petrolService.petrolType
        
        logger.info("Requesting current location and fuel station prices for '\(self.petrolType.rawValue, privacy: .public)' type.")
        
        locationService.requestCurrentLocation()
        
        locationPublisher()
            .flatMap { (location: CLLocation) -> AnyPublisher<String, Never> in
            
                self.logger.info("Loading placemark for the currently received location \(location.coordinate, privacy: .private)")
                
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
                    type: self.petrolType,
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
    
    /// Takes fuel stations and calculates the average of the open stations.
    /// The view models data property updates the user interface.
    /// - Parameter petrolStations: a list of fuel stations
    public func calculateNewAverage(from petrolStations: [PetrolStation]) {
        
        self.logger.log("Received a total of \(petrolStations.count, privacy: .public) fuel stations.")
        
        let openStations = petrolStations.filter { $0.isOpen && $0.price != nil }
        let numberOfStations = openStations.count
        
        self.logger.log("Calculating new average for a total of \(numberOfStations, privacy: .public) open fuel stations.")
        
        let priceSum = openStations.reduce(0) { (result, item) in
            return result + (item.price ?? 0)
        }
        
        let averagePrice = priceSum / Double(numberOfStations)
        
        self.data = .success(PetrolPriceDashboardData(
            averagePrice: averagePrice,
            numberOfStations: numberOfStations
        ))
        
        self.logger.log("Calculated fuel average is \(averagePrice, privacy: .public)€.")
        
    }
    
    /// Loads the detailed model of the fuel station with
    /// all of it's fuel prices and opening hours.
    /// It uses the fuel service provided to the view model.
    /// - Parameter id: fuel station id
    /// - Returns: a failable publisher of the station
    public func loadFuelStation(id: PetrolStation.ID) -> AnyPublisher<PetrolStation, Error> {
        return petrolService.getPetrolStation(id: id)
    }
    
    // MARK: - Helper -
    
    /// Ask the location service to provide the latest user location.
    /// Unallowed locations are being filtered out and only one location
    /// is being returned in the publisher.
    /// It does not throw exepections and instead they are replaced by
    /// the region location in `CoreSettings`.
    /// - Returns: a never-failing publisher of the user location
    private func locationPublisher() -> AnyPublisher<CLLocation, Never> {
        return locationService
            .location
            .replaceError(with: CoreSettings.regionLocation)
            .filter({ $0.coordinate.latitude != 0.0 && $0.coordinate.longitude != 0.0 })
            .prefix(1)
            .eraseToAnyPublisher()
    }
    
}
