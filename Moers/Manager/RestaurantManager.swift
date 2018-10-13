//
//  RestaurantManager.swift
//  Moers
//
//  Created by Lennart Fischer on 03.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct RestaurantManager {
    
    static var shared = RestaurantManager()
    
    private var session = URLSession.shared
    
    public func get(completion: @escaping ((Error?, [Restaurant]?) -> Void)) {
        
        let endpoint = Environment.current.baseURL + "api/v1/restaurants"
        
        guard let url = URL(string: endpoint) else { completion(APIError.unavailableURL, nil); return }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                
                let stores = try jsonDecoder.decode([Restaurant].self, from: data)
                
                completion(nil, stores)
                
            } catch {
                print(error.localizedDescription)
            }
            
        })
        
        task.resume()
        
    }
    
}
