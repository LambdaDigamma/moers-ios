//
//  DefaultParkingService.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation
import ModernNetworking
import Core

nonisolated public struct ParkingAreaResponse: Model, Sendable {
    
    public let parkingAreas: [ParkingArea]
    
    public static let decoder: JSONDecoder = ParkingArea.decoder
    public static let encoder: JSONEncoder = ParkingArea.encoder
    
    public enum CodingKeys: String, CodingKey {
        case parkingAreas = "parking_areas"
    }
    
}

public class DefaultParkingService: ParkingService {

    private let client: any HTTPClient
    
    public init(
        client: any HTTPClient
    ) {
        self.client = client
    }

    @MainActor
    public convenience init(loader: HTTPLoader) {
        self.init(client: HTTPLoaderClient(loader: loader))
    }
    
    public func loadParkingAreas() async throws -> [ParkingArea] {
        let request = HTTPRequest(
            method: .get,
            path: "parking-areas"
        )
        
        let result = await client.load(request)
        
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
        
        let result = await client.load(request)
        
        guard let data = result.response?.body else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let response = try ParkingArea.decoder.decode(DataResponse<ParkingDashboardData>.self, from: data)
        return response.data
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
