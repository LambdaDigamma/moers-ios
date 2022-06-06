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
    
    func getCameras(shouldReload: Bool) -> AnyPublisher<[Camera], Error>
    

}

public class CameraManager: CameraManagerProtocol {
    
    @available(*, deprecated, message: "Stop using Singleton Instance")
    public static let shared = CameraManager()
    
    public init(storageManager: AnyStoragable<Camera> = NoCache()) {
        
        self.decoder = JSONDecoder()
        self.storageManager = storageManager
        
    }
    
    private let decoder: JSONDecoder
    private let storageManager: AnyStoragable<Camera>
    private let storageKey = "cameras"
    
    // MARK: - API Interface
    
    public func getCameras(shouldReload: Bool = false) -> AnyPublisher<[Camera], Error> {
        
        if storageManager.shouldReload(interval: 60 * 6, forKey: storageKey) || shouldReload {
            
            let storageSource = storageManager.read(forKey: storageKey, with: decoder)
            let networkSource = loadCamerasNetwork()
            
            return storageSource.merge(with: networkSource).eraseToAnyPublisher()
            
        }
        
        return storageManager.read(forKey: storageKey, with: decoder)
        
    }
    
    // MARK: - Helper
    
    internal func loadCamerasNetwork() -> AnyPublisher<[Camera], Error> {
        
        return Deferred {
            
            return Future<[Camera], Error> { promise in
                
                guard let url = URL(string: "https://raw.githubusercontent.com/noelsch/360Moers/master/360moers_OpenData.csv") else {
                    return promise(.failure(APIError.unavailableURL))
                }
                
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    print("CameraManager: Loaded Cameras from Network")
                    
                    if let error = error {
                        promise(.failure(error))
                    }
                    
                    guard let data = data else {
                        promise(.failure(APIError.noData))
                        return
                    }
                    
                    let decodedCameras = self.decodeCSVtoJSON(from: data)
                    
                    self.storageManager.setLastReload(Date(), forKey: self.storageKey)
                    self.storageManager.write(data: decodedCameras.jsonData, forKey: self.storageKey)
                    
                    promise(.success(decodedCameras.cameras))
                    
                }
                
                task.resume()
                
            }
            
            
        }
        .eraseToAnyPublisher()
        
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
