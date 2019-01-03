//
//  HTTPClient.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Reachability

struct HTTPClient {
    
    public static var shared = HTTPClient()
    
    private var reachability = Reachability()!
    private var session = URLSession.shared
    
    public func get(url: URL, withAuth: Bool = false, completion: @escaping ((Error?, Data?) -> Void)) {
        
        if reachability.connection != .none {
            
            var request = URLRequest(url: url)
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            if withAuth {
                if let token = token {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    completion(APIError.noToken, nil)
                }
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                    completion(APIError.notAuthorized, nil)
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                completion(nil, data)
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    public func post(url: URL, data: [String: Any], withAuth: Bool = false, completion: @escaping ((Error?, Data?) -> Void)) {
        
        if reachability.connection != .none {
            
            var request = URLRequest(url: url)
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch {
                completion(error, nil)
            }
            
            if withAuth {
                if let token = token {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    completion(APIError.noToken, nil)
                }
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                    completion(APIError.notAuthorized, nil)
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                completion(nil, data)
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    public func update(url: URL, data: [String: Any], withAuth: Bool = false, completion: @escaping ((Error?, Data?) -> Void)) {
        
        if reachability.connection != .none {
            
            var request = URLRequest(url: url)
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch {
                completion(error, nil)
            }
            
            if withAuth {
                if let token = token {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    completion(APIError.noToken, nil)
                }
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                    completion(APIError.notAuthorized, nil)
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                completion(nil, data)
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    public func delete(url: URL, withAuth: Bool = false, completion: @escaping ((Error?, Data?) -> Void)) {
        
        if reachability.connection != .none {
            
            var request = URLRequest(url: url)
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "DELETE"
            
            if withAuth {
                if let token = token {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    completion(APIError.noToken, nil)
                }
            }
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                    completion(APIError.notAuthorized, nil)
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                completion(nil, data)
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    // MARK: - Utility
    
    private let kToken = "token"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: kToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kToken)
        }
    }
    
}
