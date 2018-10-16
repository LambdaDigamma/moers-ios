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
    
    // MARK: - Entry Onboarding
    
    public var entryName: String? {
        get { return UserDefaults.standard.string(forKey: "EntryName") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryName") }
    }
    
    public var entryLat: Double {
        get { return UserDefaults.standard.double(forKey: "EntryLat") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryLat") }
    }
    
    public var entryLng: Double {
        get { return UserDefaults.standard.double(forKey: "EntryLng") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryLng") }
    }
    
    public var entryStreet: String? {
        get { return UserDefaults.standard.string(forKey: "EntryStreet") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryStreet") }
    }
    
    public var entryHouseNumber: String? {
        get { return UserDefaults.standard.string(forKey: "EntryHouseNumber") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryHouseNumber") }
    }
    
    public var entryPostcode: String? {
        get { return UserDefaults.standard.string(forKey: "EntryPostcode") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryPostcode") }
    }
    
    public var entryPlace: String? {
        get { return UserDefaults.standard.string(forKey: "EntryPlace") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryPlace") }
    }
    
    public var entryPhone: String? {
        get { return UserDefaults.standard.string(forKey: "EntryPhone") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryPhone") }
    }
    
    public var entryWebsite: String? {
        get { return UserDefaults.standard.string(forKey: "EntryWebsite") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryWebsite") }
    }
    
    public var entryMondayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryMondayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryMondayOH") }
    }
    
    public var entryTuesdayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryTuesdayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryTuesdayOH") }
    }
    
    public var entryWednesdayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryWednesdayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryWednesdayOH") }
    }
    
    public var entryThursdayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryThursdayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryThursdayOH") }
    }
    
    public var entryFridayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryFridayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryFridayOH") }
    }

    public var entrySaturdayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntrySaturdayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntrySaturdayOH") }
    }

    public var entrySundayOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntrySundayOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntrySundayOH") }
    }

    public var entryOtherOH: String? {
        get { return UserDefaults.standard.string(forKey: "EntryOtherOH") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryOtherOH") }
    }

}
