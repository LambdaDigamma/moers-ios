//
//  ShopManager.swift
//  Moers
//
//  Created by Lennart Fischer on 17.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct ShopManager {
    
    static let shared = ShopManager()
    
    private var session = URLSession.shared
    
    public func get(completion: @escaping ((Error?, [Store]?) -> Void)) {
        
        let url = Environment.current.baseURL + "api/v1/shops"
        
        do {
            
            let request = try buildRequest(with: url)
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let data = data else { return }
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    
                    let stores = try jsonDecoder.decode([Store].self, from: data)
                    
                    completion(nil, stores)
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            })
            
            task.resume()
            
        } catch {
            completion(error, nil)
        }
        
    }
    
    public func store(name: String?, branch: String?, street: String?, houseNumber: String?, postcode: String?, place: String?, website: String?, phone: String?, monday: String?, tuesday: String?, wednesday: String?, thursday: String?, friday: String?, saturday: String?, sunday: String?, other: String?) {
        
        
        
    }
    
    private func buildRequest(with url: String) throws -> URLRequest {
        
        guard let url = URL(string: url) else { throw APIError.unavailableURL }
//        guard let token = token else { throw APIError.noToken }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
        
    }
    
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
