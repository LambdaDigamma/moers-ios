//
//  EntryManager.swift
//  Moers
//
//  Created by Lennart Fischer on 06.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct EntryManager {
    
    static var shared = EntryManager()
    
    private var session = URLSession.shared
    
    public func get(completion: @escaping ((Error?, [Entry]?) -> Void)) {
        
        let endpoint = Environment.current.baseURL + "api/v1/entries"
        
        guard let url = URL(string: endpoint) else { completion(APIError.unavailableURL, nil); return }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                
                let entries = try jsonDecoder.decode([Entry].self, from: data)
                
                completion(nil, entries)
                
            } catch {
                completion(error, nil)
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
    }
    
    public func extractTags(entries: [Entry]) -> [String] {
        
        let tags = Set(entries.map { $0.tags }.reduce([], +))
        
        return Array(tags)
        
    }
    
}
