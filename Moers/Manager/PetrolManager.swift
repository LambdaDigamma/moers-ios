//
//  PetrolManager.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import CoreLocation

protocol PetrolManagerDelegate {
    
    func didReceivePetrolStations(stations: [PetrolStation])
    
}

class PetrolManager {
    
    static let shared = PetrolManager()
    
    public var delegate: PetrolManagerDelegate? = nil
    
    private var session = URLSession.shared
    private let apiKey = "0dfdfad3-7385-ef47-2ff6-ec0477872677"
    private let baseURL = "https://creativecommons.tankerkoenig.de/"
    
    public var cachedStations: [PetrolStation]?
    
    public var petrolType: PetrolType {
        get { return PetrolType(rawValue: UserDefaults.standard.string(forKey: "PetrolType") ?? "") ?? .diesel }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "PetrolType") }
    }
    
    public func sendRequest(coordiante: CLLocationCoordinate2D, radius: Double, sorting: PetrolSorting, type: PetrolType) {
        
        if radius > 25.0 {
            fatalError("Search radius should not be greater than 25.0")
        }
        
        let url = URL(string: "\(baseURL)json/list.php" +
                                "?lat=\(coordiante.latitude)" +
                                "&lng=\(coordiante.longitude)" +
                                "&rad=\(radius)" +
                                "&sort=\(sorting.rawValue)" +
                                "&type=\(type.rawValue)" +
                                "&apikey=\(apiKey)")
        
        guard let builtURL = url else { return }
        
        let request = URLRequest(url: builtURL)
        
        session.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let response = try jsonDecoder.decode(PetrolRequestResponse.self, from: data)
                    
                if response.isValid {
                    
                    guard let stations = response.stations else { return }
                    
                    self.cachedStations = stations
                    
                    self.delegate?.didReceivePetrolStations(stations: stations)
                    
                } else {
                    
                    print("An Error Occured: \(response.status)")
                    
                }
                
            } catch {
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    
    public func sendDetailRequest(id: String, completion: @escaping ((_ station: PetrolStation?) -> Void)) {
        
        let url = URL(string: "\(baseURL)json/detail.php" +
            "?id=\(id)" +
            "&apikey=\(apiKey)")
        
        guard let builtURL = url else { return }
        
        let request = URLRequest(url: builtURL)
        
        session.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let response = try jsonDecoder.decode(PetrolDetailResponse.self, from: data)
                
                if response.isValid {
                    
                    completion(response.station)
                    
                } else {
                    
                    print("Error: \(response.ok)")
                    
                    completion(nil)
                    
                }
                
            } catch {
                print("Error")
                print(error.localizedDescription)
            }
            
        }.resume()
        
    }
    
}
