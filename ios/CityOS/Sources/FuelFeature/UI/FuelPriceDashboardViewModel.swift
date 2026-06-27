//
//  FuelPriceDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import Core
import CoreLocation
import FactoryKit
import OSLog
import Observation

public struct PetrolPriceDashboardData {
    
    public let averagePrice: Double
    public let numberOfStations: Int
    
}

@MainActor
@Observable
public class FuelPriceDashboardViewModel: StandardViewModel {
    
    var petrolType: PetrolType = .diesel
    var data: DataState<PetrolPriceDashboardData, Error> = .loading
    var locationName: DataState<String, Error> = .loading
    
    public private(set) var fuelStations: DataState<[PetrolStation], Error> = .loading
    
    private var defaultSearchRadius = 10.0
    
    private let logger: Logger = Logger(.coreUi)
    
    @ObservationIgnored @Injected(\.petrolService) private var petrolService
    @ObservationIgnored @Injected(\.locationService) private var locationService
    @ObservationIgnored @Injected(\.geocodingService) private var geocodingService
    
    public init(
        initialState: DataState<PetrolPriceDashboardData, Error> = .loading,
        initialFuelStations: DataState<[PetrolStation], Error> = .loading
    ) {
        self.data = initialState
        self.fuelStations = initialFuelStations
        super.init()
    }
    
    /// Reloads location and updates the fuel stations
    /// and average price data of the dashboard.
    public func load() async {
        self.petrolType = petrolService.petrolType
        
        logger.info("Requesting current location and fuel station prices for '\(self.petrolType.rawValue, privacy: .public)' type.")
        
        locationService.requestCurrentLocation()
        
        // todo: make this publisher react to the location updates via the stream on the location service

        let location = await waitForValidLocation()
        
        await loadLocationName(for: location)
        await loadFuelStations(for: location)
    }
    
    private func loadLocationName(for location: CLLocation) async {
        
        do {
            
            logger.info("Loading placemark for the currently received location \(location.coordinate, privacy: .private)")
            
            let placemark = try await geocodingService.placemark(from: location)
            locationName = .success(placemark.locality ?? "")
            
        } catch {
            
            logger.error("Failed to load location name: \(error.localizedDescription, privacy: .public)")
            locationName = .success("")
            
        }
        
    }
    
    private func loadFuelStations(for location: CLLocation) async {
        
        do {
            
            logger.info("Loading fuel stations for location: \(location.coordinate, privacy: .private)")
            
            let stations = try await petrolService.getPetrolStations(
                coordinate: location.coordinate,
                radius: defaultSearchRadius,
                sorting: .distance,
                type: petrolType,
                shouldReload: false
            )
            
            self.fuelStations = .success(stations.filter { $0.isOpen })
            self.calculateNewAverage(from: stations)
            
        } catch {
            logger.error("Failed to load fuel stations: \(error.localizedDescription, privacy: .public)")
            self.data = .error(error)
        }
        
    }
    
    private func waitForValidLocation() async -> CLLocation {
        do {
            for try await location in locationService.locations {
                if location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0 {
                    return location
                }
            }
        } catch {
            return CoreSettings.regionLocation
        }
        return CoreSettings.regionLocation
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
    /// - Returns: the station or throws an error
    public func loadFuelStation(id: PetrolStation.ID) async throws -> PetrolStation {
        return try await petrolService.getPetrolStation(id: id)
    }
    
}
