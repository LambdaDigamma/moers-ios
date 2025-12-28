//
//  DefaultPetrolService.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import Core
import Foundation
import CoreLocation
import ModernNetworking
import OSLog

public class DefaultPetrolService: PetrolService {
    
    private let logger = Logger(.coreApi)
    private let storageKey = "petrolStations"
    
    private let session: URLSession
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    
    private let apiKey: String
    private let host: String = "creativecommons.tankerkoenig.de"
    
    public init(
        userDefaults: UserDefaults = .standard,
        session: URLSession = .shared,
        apiKey: String
    ) {
        self.userDefaults = userDefaults
        self.session = session
        self.apiKey = apiKey
        self.decoder = JSONDecoder()
    }
    
    // MARK: - API Interface
    
    public var petrolType: PetrolType {
        get {
            return PetrolType(rawValue: userDefaults.string(forKey: "PetrolType") ?? "") ?? .diesel
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: "PetrolType")
        }
    }
    
    public var lastLoadLocation: CLLocation? {
        get {
            return CLLocation(
                latitude: userDefaults.double(forKey: "lastPetrolLat"),
                longitude: userDefaults.double(forKey: "lastPetrolLng")
            )
        }
        set {
            
            guard let newValue = newValue else {
                return
            }
            
            userDefaults.set(newValue.coordinate.latitude, forKey: "lastPetrolLat")
            userDefaults.set(newValue.coordinate.longitude, forKey: "lastPetrolLng")
        }
    }
    
    public func getPetrolStation(id: PetrolStation.ID) async throws -> PetrolStation {
        if apiKey.isEmptyOrWhitespace {
            logger.error("The petrol api key is empty. Please provide a valid api key.")
            throw APIError.noToken
        }
        
        var request = HTTPRequest(
            method: .get,
            path: "/json/detail.php"
        )
        
        request.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        request.host = host
        
        guard let url = request.url else {
            throw APIError.unavailableURL
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, _) = try await session.data(for: urlRequest)
        
        let response = try decoder.decode(PetrolDetailResponse.self, from: data)
        
        if response.isValid, let station = response.station {
            return station
        } else {
            throw APIError.noData
        }
    }
    
    public func getPetrolStations(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType,
        shouldReload: Bool = false
    ) async throws -> [PetrolStation] {
        let requestLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        self.lastLoadLocation = requestLocation
        
        return try await sendRequest(
            coordinate: coordinate,
            radius: radius,
            sorting: sorting,
            type: type
        )
    }
    
    // MARK: - Helper
    
    internal func sendRequest(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType
    ) async throws -> [PetrolStation] {
        if apiKey.isEmptyOrWhitespace {
            logger.error("The petrol api key is empty. Please provide a valid api key.")
            throw APIError.noToken
        }
        
        var request = HTTPRequest(
            method: .get,
            path: "/json/list.php"
        )
        
        request.host = host
        
        request.queryItems = [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lng", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "rad", value: "\(radius)"),
            URLQueryItem(name: "sort", value: sorting.rawValue),
            URLQueryItem(name: "type", value: type.rawValue),
            URLQueryItem(name: "apikey", value: apiKey),
        ]
        
        if radius > 25.0 {
            logger.info("Search radius should not be greater than 25.0")
            return []
        }
        
        guard let url = request.url else {
            throw APIError.unavailableURL
        }
        
        let urlRequest = URLRequest(url: url)
        let (data, _) = try await session.data(for: urlRequest)
        
        let stations = try await decodePetrolStations(from: data)
        
        // Optionally encode and save to storage
        // let encoder = JSONEncoder()
        // _ = try? encoder.encode(stations)
        
        return stations
    }
    
    internal func decodePetrolStations(from data: Data) async throws -> [PetrolStation] {
        let response = try decoder.decode(PetrolRequestResponse.self, from: data)
        
        if response.isValid {
            if let stations = response.stations {
                stations.forEach { station in
                    station.name = station.name
                        .capitalized(with: Locale.autoupdatingCurrent)
                        .replacingOccurrences(of: "_", with: " ")
                }
                return stations
            } else {
                throw APIError.noData
            }
        }
        
        throw APIError.noData
    }
    
}
