//
//  EventManager.swift
//  Moers
//
//  Created by Lennart Fischer on 14.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Reachability

struct EventManager {
    
    static var shared = EventManager()
    
    private let reachability = Reachability()!
    private let session = URLSession.shared
    
    public func getEvents(completion: @escaping ((Error?, [Event]?) -> Void)) {
        
        if reachability.connection != .none {
            
            guard let url = URL(string: Environment.current.baseURL + "api/v1/events") else { return }
            
            let request = URLRequest(url: url)
            
            session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    completion(error, nil)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let events = try decoder.decode([Event].self, from: data)
                    
                    completion(nil, events)
                    
                } catch {
                    completion(error, nil)
                }
                
            }.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
}
