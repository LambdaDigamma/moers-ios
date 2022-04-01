//
//  DefaultParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import Combine
import ModernNetworking
import Core

public struct ParkingAreaResponse: Model {
    
    public let parkingAreas: [ParkingArea]
    
    public static var decoder: JSONDecoder = ParkingArea.decoder
    public static var encoder: JSONEncoder = ParkingArea.encoder
    
    public enum CodingKeys: String, CodingKey {
        case parkingAreas = "parking_areas"
    }
    
}

public class DefaultParkingService: ParkingService {
    
    private let loader: HTTPLoader
    
    public init(
        loader: HTTPLoader
    ) {
        self.loader = loader
    }
    
    public func loadParkingAreas() -> AnyPublisher<[ParkingArea], Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "parking-areas"
        )
        
        return Deferred {
            return Future { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    guard let data = result.response?.body else {
                        promise(.failure(URLError(.cannotDecodeRawData)))
                        return
                    }
                    
                    do {
                        let response = try ParkingArea.decoder.decode(DataResponse<ParkingAreaResponse>.self, from: data)
                        promise(.success(response.data.parkingAreas.sorted(by: { $0.currentOpeningState > $1.currentOpeningState })))
                    } catch {
                        promise(.failure(error))
                    }
                    
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func loadDashboard() -> AnyPublisher<ParkingDashboardData, Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "parking-areas/dashboard"
        )
        
        return Deferred {
            return Future { promise in
                
                self.loader.load(request) { (result: HTTPResult) in
                    
                    guard let data = result.response?.body else {
                        promise(.failure(URLError(.cannotDecodeRawData)))
                        return
                    }
                    
                    do {
                        let response = try ParkingArea.decoder.decode(DataResponse<ParkingDashboardData>.self, from: data)
                        promise(.success(response.data))
                    } catch {
                        promise(.failure(error))
                    }
                    
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
}
