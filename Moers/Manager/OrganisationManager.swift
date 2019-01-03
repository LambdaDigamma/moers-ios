//
//  OrganisationManager.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct OrganisationManager {
    
    public static var shared = OrganisationManager()
    
    // MARK: - Basic
    
    public func get(completion: @escaping (Error?, [Organisation]?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations") else { return }
        
        HTTPClient.shared.get(url: url) { (error, data) in
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                
                let organisations = try decoder.decode([Organisation].self, from: data)
                
                completion(nil, organisations)
                
            } catch {
                completion(error, nil)
            }
            
        }
        
    }
    
    public func show(id: Int, completion: @escaping (Error?, Organisation?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)") else { return }
        
        HTTPClient.shared.get(url: url) { (error, data) in
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                
                let organisation = try decoder.decode(Organisation.self, from: data)
                
                completion(nil, organisation)
                
            } catch {
                completion(error, nil)
            }
            
        }
        
    }
    
    public func store() {
        
        
        
    }
    
    public func update(updatedOrganisation: Organisation) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations") else { return }
        
//        HTTPClient.shared.
        
    }
    
    public func delete(id: Int) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)") else { return }
        
        HTTPClient.shared.delete(url: url, withAuth: true) { (error, data) in
            
            
            
        }
        
    }
    
    // MARK: - User
    
    public func getUsers(id: Int, completion: @escaping (Error?, [User]?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)/users") else { return }
        
        HTTPClient.shared.get(url: url, withAuth: true) { (error, data) in
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                
//                let users = try decoder.decode([User].self, from: data)
//
//                completion(nil, users)
                
            } catch {
                completion(error, nil)
            }
            
        }
        
    }
    
    public func joinOrganisation(id: Int, completion: @escaping (Error?, Bool?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)/join") else { return }
        
        HTTPClient.shared.post(url: url, data: [:], withAuth: true) { (error, data) in
            
            
            
        }
        
    }
    
    // MARK: - Events
    
    public func getEvents(id: Int, completion: @escaping (Error?, [Event]?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)/events") else { return }
        
        HTTPClient.shared.get(url: url) { (error, data) in
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                
                let events = try decoder.decode([Event].self, from: data)
                
                completion(nil, events)
                
            } catch {
                completion(error, nil)
            }
            
        }
        
    }
    
    // MARK: - Entry
    
    public func getEntry(id: Int, completion: @escaping (Error?, Entry?) -> Void) {
        
        guard let url = URL(string: Environment.current.baseURL + "api/v2/organisations/\(id)/entry") else { return }
        
        HTTPClient.shared.get(url: url) { (error, data) in
            
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            do {
                
                let entry = try decoder.decode(Entry.self, from: data)
                
                completion(nil, entry)
                
            } catch {
                completion(error, nil)
            }
            
        }
        
    }
    
}
