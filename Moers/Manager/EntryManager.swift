//
//  EntryManager.swift
//  Moers
//
//  Created by Lennart Fischer on 06.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Reachability

struct EntryManager {
    
    static var shared = EntryManager()
    
    private let reachability = Reachability()!
    private var session = URLSession.shared
    
    public func get(completion: @escaping ((Error?, [Entry]?) -> Void)) {
        
        let endpoint = Environment.current.baseURL + "api/v1/entries"
        
        guard let url = URL(string: endpoint) else { completion(APIError.unavailableURL, nil); return }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        DispatchQueue.global(qos: .background).async {
            
            let task = self.session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let data = data else { return }
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    
                    let entries = try jsonDecoder.decode([Entry].self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(nil, entries)
                    }
                    
                } catch {
                    
                    DispatchQueue.main.async {
                        completion(error, nil)
                    }
                    
                    print(error.localizedDescription)
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    public func store(entry: Entry, completion: @escaping ((Error?, Bool?, Int?) -> Void)) {
        
        if reachability.connection != .none {
            
            guard let url = URL(string: Environment.current.baseURL + "api/v1/entries") else {
                completion(APIError.noConnection, nil, nil)
                return
            }
            
            let tags = entry.tags.joined(separator: ", ")
            
            let data: [String: Any] = ["secret": "tzVQl34i6SrYSzAGSkBh",
                                       "name": entry.name,
                                       "tags": tags,
                                       "street": entry.street,
                                       "house_number": entry.houseNumber,
                                       "postcode": entry.postcode,
                                       "place": entry.place,
                                       "lat": entry.coordinate.latitude,
                                       "lng": entry.coordinate.longitude,
                                       "url": entry.url ?? "",
                                       "phone": entry.phone ?? "",
                                       "monday": entry.monday ?? "",
                                       "tuesday": entry.tuesday ?? "",
                                       "wednesday": entry.wednesday ?? "",
                                       "thursday": entry.thursday ?? "",
                                       "friday": entry.friday ?? "",
                                       "saturday": entry.saturday ?? "",
                                       "sunday": entry.sunday ?? "",
                                       "other": entry.other ?? ""]
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            DispatchQueue.global(qos: .background).async {
                
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                } catch {
                    print(error.localizedDescription)
                }
                
                let task = self.session.dataTask(with: request) { (data, response, error) in
                    
                    guard error == nil else {
                        completion(error, nil, nil)
                        return
                    }
                    
                    guard let data = data else {
                        completion(APIError.noData, nil, nil)
                        return
                    }
                    
                    do {
                        
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { completion(APIError.noData, nil, nil); return }
                        
                        print(json)
                        
                        let id = (json["id"] as? Int) ?? -1
                        
                        DispatchQueue.main.async {
                            completion(nil, true, id)
                        }
                        
                    } catch {
                        DispatchQueue.main.async {
                            completion(error, false, nil)
                        }
                    }
                    
                }
                
                task.resume()
                
            }
            
        } else {
            completion(APIError.noConnection, nil, nil)
        }
        
    }
    
    public func extractTags(entries: [Entry]) -> [String] {
        
        let tags = Set(entries.map { $0.tags }.reduce([], +))
        
        return Array(tags)
        
    }
    
    public mutating func resetData() {
        
        self.entryName = nil
        self.entryLat = nil
        self.entryLng = nil
        self.entryStreet = nil
        self.entryHouseNumber = nil
        self.entryPostcode = nil
        self.entryPlace = nil
        self.entryPhone = nil
        self.entryWebsite = nil
        self.entryMondayOH = nil
        self.entryTuesdayOH = nil
        self.entryWednesdayOH = nil
        self.entryThursdayOH = nil
        self.entryFridayOH = nil
        self.entrySaturdayOH = nil
        self.entrySundayOH = nil
        self.entryOtherOH = nil
        self.entryTags = []
        
    }
    
    // MARK: - Entry Onboarding
    
    public var entryName: String? {
        get { return UserDefaults.standard.string(forKey: "EntryName") }
        set { UserDefaults.standard.set(newValue, forKey: "EntryName") }
    }
    
    public var entryLat: Double? {
        get {
            if UserDefaults.standard.double(forKey: "EntryLat") != 0 {
                return UserDefaults.standard.double(forKey: "EntryLat")
            } else {
                return nil
            }
        }
        set { UserDefaults.standard.set(newValue, forKey: "EntryLat") }
    }
    
    public var entryLng: Double? {
        get {
            if UserDefaults.standard.double(forKey: "EntryLng") != 0 {
                return UserDefaults.standard.double(forKey: "EntryLng")
            } else {
                return nil
            }
        }
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
    
    public var entryTags: [String] {
        get { return UserDefaults.standard.stringArray(forKey: "EntryTags") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "EntryTags") }
    }

}
