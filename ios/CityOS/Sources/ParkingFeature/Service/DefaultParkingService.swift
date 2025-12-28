//
//  DefaultParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
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
    
    public func loadParkingAreas() async throws -> [ParkingArea] {
        let request = HTTPRequest(
            method: .get,
            path: "parking-areas"
        )
        
        let result = await loader.load(request)
        
        guard let data = result.response?.body else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let response = try ParkingArea.decoder.decode(DataResponse<ParkingAreaResponse>.self, from: data)
        return response.data.parkingAreas.sorted(by: { $0.currentOpeningState > $1.currentOpeningState })
    }
    
    public func loadDashboard() async throws -> ParkingDashboardData {
        let request = HTTPRequest(
            method: .get,
            path: "parking/dashboard"
        )
        
        let result = await loader.load(request)
        
        guard let data = result.response?.body else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let response = try ParkingArea.decoder.decode(DataResponse<ParkingDashboardData>.self, from: data)
        return response.data
    }
    
}
