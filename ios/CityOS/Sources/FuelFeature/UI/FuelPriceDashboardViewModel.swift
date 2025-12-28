//
//  FuelPriceDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation
import Core
import CoreLocation
import Factory
import OSLog

public struct PetrolPriceDashboardData {
    
    public let averagePrice: Double
    public let numberOfStations: Int
    
}

public class FuelPriceDashboardViewModel: StandardViewModel {
    
    @Published var petrolType: PetrolType = .diesel
    @Published var data: DataState<PetrolPriceDashboardData, Error> = .loading
    @Published var locationName: DataState<String, Error> = .loading
    
    public private(set) var fuelStations: DataState<[PetrolStation], Error> = .loading
    
    @Published private var defaultSearchRadius = 10.0
    
    private let logger: Logger = Logger(.coreUi)
    
    @Injected(\.petrolService) private var petrolService
    @Injected(\.locationService) private var locationService
    @Injected(\.geocodingService) private var geocodingService
    
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
    public func load() {
        
        self.petrolType = petrolService.petrolType
        
        logger.info("Requesting current location and fuel station prices for '\(self.petrolType.rawValue, privacy: .public)' type.")
        
        locationService.requestCurrentLocation()
        
        Task {
            await loadLocationName()
            await loadFuelStations()
        }
    }
    
    private func loadLocationName() async {
        do {
            guard let location = await waitForValidLocation() else {
                locationName = .success("")
                return
            }
            
            logger.info("Loading placemark for the currently received location \(location.coordinate, privacy: .private)")
            
            let placemark = try await geocodingService.placemark(from: location)
            
            await MainActor.run {
                locationName = .success(placemark.locality ?? "")
            }
        } catch {
            logger.error("Failed to load location name: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                locationName = .success("")
            }
        }
    }
    
    private func loadFuelStations() async {
        do {
            guard let location = await waitForValidLocation() else {
                return
            }
            
            print("Location: \(location.coordinate)")
            
            let stations = try await petrolService.getPetrolStations(
                coordinate: location.coordinate,
                radius: defaultSearchRadius,
                sorting: .distance,
                type: petrolType,
                shouldReload: false
            )
            
            await MainActor.run {
                self.fuelStations = .success(stations.filter { $0.isOpen })
                self.calculateNewAverage(from: stations)
            }
        } catch {
            logger.error("Failed to load fuel stations: \(error.localizedDescription, privacy: .public)")
            await MainActor.run {
                self.data = .error(error)
            }
        }
    }
    
    private func waitForValidLocation() async -> CLLocation? {
        do {
            for try await location in locationService.locations {
                if location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0 {
                    return location
                }
            }
        } catch {
            return CoreSettings.regionLocation
        }
        return nil
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
        
        DispatchQueue.main.async {
            self.data = .success(PetrolPriceDashboardData(
                averagePrice: averagePrice,
                numberOfStations: numberOfStations
            ))
        }
        
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
