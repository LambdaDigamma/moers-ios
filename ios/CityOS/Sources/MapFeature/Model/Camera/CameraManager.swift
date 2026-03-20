//
//  CameraManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Core
import Foundation
import CoreLocation
import Combine

public protocol CameraManagerProtocol {
    
    func getCameras(shouldReload: Bool) async throws -> [Camera]
    

}

public class CameraManager: CameraManagerProtocol {
    
    public init(storageManager: AnyStoragable<Camera> = NoCache()) {
        
        self.decoder = JSONDecoder()
        self.storageManager = storageManager
        
    }
    
    private let decoder: JSONDecoder
    private let storageManager: AnyStoragable<Camera>
    private let storageKey = "cameras"
    
    // MARK: - API Interface
    
    public func getCameras(shouldReload: Bool = false) async throws -> [Camera] {

        let mustReload = storageManager.shouldReload(interval: 60 * 6, forKey: storageKey) || shouldReload
        let cachedCameras = try await loadCamerasFromCache()

        if !mustReload && !cachedCameras.isEmpty {
            return cachedCameras
        }

        do {
            let networkCameras = try await loadCamerasNetwork()
            if !networkCameras.isEmpty {
                return networkCameras
            }
            return cachedCameras
        } catch {
            if !cachedCameras.isEmpty {
                return cachedCameras
            }
            throw error
        }

    }
    
    // MARK: - Helper
    
    internal func loadCamerasNetwork() async throws -> [Camera] {

        guard let url = URL(string: "https://raw.githubusercontent.com/noelsch/360Moers/master/360moers_OpenData.csv") else {
            throw APIError.unavailableURL
        }

        print("CameraManager: Loaded Cameras from Network")

        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedCameras = decodeCSVtoJSON(from: data)

        storageManager.setLastReload(Date(), forKey: storageKey)
        storageManager.write(data: decodedCameras.jsonData, forKey: storageKey)

        return decodedCameras.cameras

    }

    internal func loadCamerasFromCache() async throws -> [Camera] {

        let publisher = storageManager.read(forKey: storageKey, with: decoder)

        for try await cameras in publisher.values {
            return cameras
        }

        return []

    }
    
    internal func buildReadURL() throws -> URL {
        
        guard let url = URL(string: "https://raw.githubusercontent.com/noelsch/360Moers/master/360moers_OpenData.csv") else {
            throw APIError.unavailableURL
        }
        
        return url
        
    }
    
    internal func decodeCSVtoJSON(from data: Data) -> (jsonData: Data, cameras: [Camera]) {
        
        print("Convert CSV to JSON")
        
        let dataString = String(data: data, encoding: .utf8) ?? ""
        let csv = CSwiftV(with: dataString, separator: ";", headers: ["PanoTitle", "PanoGPS", "PanoID"])
        
        print(dataString)
        
        var rows = csv.keyedRows
        rows?.removeFirst()
        
        if let keyedRows = rows {
            
            let cameras = keyedRows.compactMap { row -> Camera in
                
                let lat = row["PanoGPS"]?.components(separatedBy: ", ").first?.doubleValue ?? 0
                let lng = row["PanoGPS"]?.components(separatedBy: ", ").last?.doubleValue ?? 0
                
                return Camera(name: row["PanoTitle"] ?? "",
                              location: CLLocation(latitude: lat, longitude: lng),
                              panoID: Int(row["PanoID"] ?? "") ?? 0)
                
            }
            
            let encoder = JSONEncoder()
            let jsonData = try? encoder.encode(cameras)
            
            return (jsonData: jsonData ?? Data(), cameras: cameras)
            
        }
        
        return (jsonData: Data(), cameras: [])
        
    }
    
}
