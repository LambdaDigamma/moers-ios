//
//  DefaultPetrolService.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import Core
import Foundation
import CoreLocation
import Combine
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
    
    private var cancellables = Set<AnyCancellable>()
    
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
    
    public func getPetrolStation(id: PetrolStation.ID) -> AnyPublisher<PetrolStation, Error> {
        
        if apiKey.isEmptyOrWhitespace {
            
            logger.error("The petrol api key is empty. Please provide a valid api key.")
            
            return Fail(error: APIError.noToken)
                .eraseToAnyPublisher()
            
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
            return Fail(error: APIError.unavailableURL).eraseToAnyPublisher()
        }
        
        return Deferred {
            Future { promise in
                
                let request = URLRequest(url: url)
                
                let task = self.session.dataTask(with: request) { (data, _, error) in
                    
                    if let error = error {
                        return promise(.failure(error))
                    }
                    
                    guard let data = data else {
                        return promise(.failure(APIError.noData))
                    }
                    
                    do {
                        
                        let response = try self.decoder.decode(PetrolDetailResponse.self, from: data)
                        
                        if response.isValid, let station = response.station {
                            return promise(.success(station))
                        } else {
                            return promise(.failure(APIError.noData))
                        }
                        
                    } catch {
                        return promise(.failure(error))
                    }
                    
                }
                
                task.resume()
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func getPetrolStations(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType,
        shouldReload: Bool = false
    ) -> AnyPublisher<[PetrolStation], Error> {
        
        let requestLocation = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        self.lastLoadLocation = requestLocation
        
//        let lastReloadLocationIsFarAway = requestLocation.distance(from: lastLoadLocation) > 15000
        
        let networkSource = sendRequest(
            coordinate: coordinate,
            radius: radius,
            sorting: sorting,
            type: type
        )
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return networkSource
        
//        if shouldReload || lastReloadLocationIsFarAway {
//
//            let networkSource = sendRequest(
//                coordinate: coordinate,
//                radius: radius,
//                sorting: sorting,
//                type: type
//            )
//
//            return networkSource
//
//        }
//
//        return storageManager.read(forKey: storageKey, with: decoder)
        
    }
    
    // MARK: - Helper
    
    internal func sendRequest(
        coordinate: CLLocationCoordinate2D,
        radius: Double,
        sorting: PetrolSorting,
        type: PetrolType
    ) -> AnyPublisher<[PetrolStation], Error> {
        
        if !guardApiKey() {
            return Fail(error: APIError.noToken).eraseToAnyPublisher()
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
            
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            
        }
        
        return Deferred {
            Future { promise in
                
                guard let url = request.url else {
                    return promise(.failure(APIError.unavailableURL))
                }
                
                let request = URLRequest(url: url)
                
                let task = self.session.dataTask(with: request) { (data, _, error) in
                    
                    if let error = error {
                        return promise(.failure(error))
                    }
                    
                    guard let data = data else {
                        return promise(.failure(APIError.noData))
                    }
                    
                    let decodedPetrolStations = self.decodePetrolStations(from: data)
                    
                    decodedPetrolStations.sink { (completion: Combine.Subscribers.Completion<Error>) in
                        
                        switch completion {
                            case .failure(let error):
                                return promise(.failure(error))
                            default: break
                        }
                        
                    } receiveValue: { (stations: [PetrolStation]) in
                        
                        let encoder = JSONEncoder()
                        _ = try? encoder.encode(stations)
                        
//                        if let data = encodedData {
//                            self.storageManager.setLastReload(Date(), forKey: self.storageKey)
//                            self.storageManager.write(data: data, forKey: self.storageKey)
//                        }
                        
                        return promise(.success(stations))
                        
                    }
                    .store(in: &self.cancellables)
                    
                }
                
                task.resume()
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    internal func decodePetrolStations(from data: Data) -> AnyPublisher<[PetrolStation], Error> {
        
        return Deferred {
            Future { promise in
                
                do {
                    
                    let response = try self.decoder.decode(PetrolRequestResponse.self, from: data)
                    
                    if response.isValid {
                        
                        if let stations = response.stations {
                            
                            stations.forEach({ station in
                                station.name = station.name
                                    .capitalized(with: Locale.autoupdatingCurrent)
                                    .replacingOccurrences(of: "_", with: " ")
                            })
                            
                            return promise(.success(stations))
                            
                        } else {
                            
                            return promise(.failure(APIError.noData))
                            
                        }
                        
                    }
                    
                } catch {
                    return promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    internal func guardApiKey() -> Bool {
        
        if apiKey.isEmptyOrWhitespace {
            
            logger.error("The petrol api key is empty. Please provide a valid api key.")
            
            return false
            
        }
        
        return true
        
    }
    
}
