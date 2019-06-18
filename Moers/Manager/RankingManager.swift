//
//  RankingManager.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Reachability
import MMAPI

struct RankingManager {
    
    static var shared = RankingManager()
    
    private let reachability = Reachability()!
    
    public func getTopRanking(completion: @escaping ((Error?, [UserRanking]?) -> Void)) {
        
        let session = URLSession.shared
        
        if reachability.connection != .none {
            
            guard let token = API.shared.token else { completion(APIError.noToken, nil); return }
            
            guard let url = URL(string: Environment.rootURL + "api/v1/leaderboard/top") else {
                completion(APIError.noConnection, nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let rankings = try decoder.decode([UserRanking].self, from: data)
                    
                    completion(nil, rankings)
                    
                } catch {
                    completion(error, nil)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }

    public func getMyRanking(completion: @escaping ((Error?, UserRanking?) -> Void)) {
        
        let session = URLSession.shared
        
        if reachability.connection != .none {
            
            guard let token = API.shared.token else { completion(APIError.noToken, nil); return }
            
            guard let url = URL(string: Environment.rootURL + "api/v1/leaderboard/me") else {
                completion(APIError.noConnection, nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                guard let data = data else {
                    completion(APIError.noData, nil)
                    return
                }
                
                do {
                    
                    let decoder = JSONDecoder()
                    
                    let ranking = try decoder.decode(UserRanking.self, from: data)
                    
                    completion(nil, ranking)
                    
                } catch {
                    completion(error, nil)
                }
                
            }
            
            task.resume()
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
}
