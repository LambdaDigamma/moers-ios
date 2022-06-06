//
//  EntryManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import ModernNetworking
//import MMCommon
import Combine

public protocol EntryManagerProtocol {
    
    func get(completion: @escaping (Result<[Entry], Error>) -> ())
    
    func store(entry: Entry, completion: @escaping (Result<Entry, Error>) -> ())
    
    func update(entry: Entry, completion: @escaping (Result<Entry, Error>) -> ())
    
    func fetchHistory(entry: Entry, completion: @escaping (Result<[Audit], Error>) -> ())
    
    func extractTags(entries: [Entry]) -> [String]
    
    func resetData()
    
    var entryName: String? { get set }
    var entryLat: Double? { get set }
    var entryLng: Double? { get set }
    var entryStreet: String? { get set }
    var entryHouseNumber: String? { get set }
    var entryPostcode: String? { get set }
    var entryPlace: String? { get set }
    var entryPhone: String? { get set }
    var entryWebsite: String? { get set }
    var entryMondayOH: String? { get set }
    var entryTuesdayOH: String? { get set }
    var entryWednesdayOH: String? { get set }
    var entryThursdayOH: String? { get set }
    var entryFridayOH: String? { get set }
    var entrySaturdayOH: String? { get set }
    var entrySundayOH: String? { get set }
    var entryOtherOH: String? { get set }
    var entryTags: [String] { get set }
    
}

public class EntryManager: EntryManagerProtocol {
    
    private let loader: HTTPLoader
    
    public init(loader: HTTPLoader) {
        self.loader = loader
    }
    
    private var session = URLSession.shared
    
    public func get(completion: @escaping (Result<[Entry], Error>) -> ()) {
        
        let request = HTTPRequest(path: "/api/v2/entries")
        
        self.loader.load(request) { (result: HTTPResult) in
            
            switch result {
                case .success(_):
                    
                    guard let response = result.response else {
                        completion(.failure(APIError.unknownResponse))
                        return
                    }
                    
                    if response.statusCode == .ok {
                        result.decoding([Entry].self) { result in
                            switch result {
                                case .success(let response):
                                    
                                    completion(.success(response))
                                case .failure(let decodingError):
                                    if let error = decodingError.underlyingError as? DecodingError {
                                        completion(.failure(APIError.decodingError(error)))
                                    } else {
                                        completion(.failure(APIError.unknownResponse))
                                    }
                                    
                            }
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    completion(.failure(error))
            }
            
        }
        
    }
    
    public func store(entry: Entry, completion: @escaping (Result<Entry, Error>) -> ()) {
        
//        guard let url = URL(string: MMAPIConfig.baseURL + "entries") else { return }
        
        let payload = data(from: entry)
        
        print(payload)
        
        let body = DataBody(payload)
        
        let request = HTTPRequest(method: .post, path: "/api/v2/entries", body: body)
        
        loader.load(request) { result in
            
            switch result {
                
                case .success(let response):
                    
                    let decoder = JSONDecoder()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    do {
                        
                        guard let data = response.body else {
                            completion(.failure(APIError.noData))
                            return
                        }
                        
                        let entry = try decoder.decode(Entry.self, from: data)
                        
                        completion(.success(entry))
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    
            }
            
        }
        
    }
    
    public func update(entry: Entry, completion: @escaping (Result<Entry, Error>) -> ()) {
        
//        guard let url = URL(string: MMAPIConfig.baseURL + "entries/\(entry.id)") else { return }
        
        let payload = data(from: entry)
        let request = HTTPRequest(method: .put, path: "/api/v2/entries/\(entry.id)", body: DataBody(payload))
        
        loader.load(request) { result in
            
            switch result {
                
                case .success(let response):
                    
                    let decoder = JSONDecoder()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    do {
                        
                        guard let data = response.body else {
                            completion(.failure(APIError.noData))
                            return
                        }
                        
                        let entry = try decoder.decode(Entry.self, from: data)
                        
                        completion(.success(entry))
                        
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    
            }
            
        }
         
    }
    
    public func fetchHistory(entry: Entry, completion: @escaping (Result<[Audit], Error>) -> ()) {
        
//        guard let url = URL(string: MMAPIConfig.baseURL + "entries/\(entry.id)/history") else { return }
        
        let request = HTTPRequest(path: "/api/v2/entries/\(entry.id)/history")
        
        loader.load(request) { result in
            
            switch result {
                
                case .success(let response):
                    
                    let decoder = JSONDecoder()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
                    
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    do {
                        
                        guard let data = response.body else {
                            completion(.failure(APIError.noData))
                            return
                        }
                        
                        let audits = try decoder.decode([Audit].self, from: data)
                        
                        completion(.success(audits))
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                    
            }
            
        }
        
    }
    
    public func extractTags(entries: [Entry]) -> [String] {
        
        let tags = Set(entries.map { $0.tags }.reduce([], +))
        
        return Array(tags)
        
    }
    
    public func resetData() {
        
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
    
    private func data(from entry: Entry) -> Data {
        
        let tags = entry.tags.map({ $0.replacingOccurrences(of: ",", with: ";") }).joined(separator: ", ")
        
        let data = EntryData(
            name: entry.name,
            tags: tags,
            street: entry.street,
            house_number: entry.houseNumber ?? "",
            postcode: entry.postcode,
            place: entry.place,
            lat: entry.coordinate.latitude,
            lng: entry.coordinate.longitude,
            url: entry.url ?? "",
            phone: entry.phone ?? "",
            monday: entry.monday ?? "",
            tuesday: entry.tuesday ?? "",
            wednesday: entry.wednesday ?? "",
            thursday: entry.thursday ?? "",
            friday: entry.friday ?? "",
            saturday: entry.saturday ?? "",
            sunday: entry.sunday ?? "",
            other: entry.other ?? ""
        )
        
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(data)
        } catch {
            return Data()
        }
        
    }
    
    public struct EntryData: Encodable {
        
        let secret = "tzVQl34i6SrYSzAGSkBh"
        let name: String
        let tags: String
        let street: String
        let house_number: String
        let postcode: String
        let place: String
        let lat: Double
        let lng: Double
        let url: String
        let phone: String
        let monday: String
        let tuesday: String
        let wednesday: String
        let thursday: String
        let friday: String
        let saturday: String
        let sunday: String
        let other: String
        
    }
    
    // MARK: - Entry Onboarding
    
    @UserDefaultsBacked(key: "EntryName")
    public var entryName: String?
    
    @UserDefaultsBacked(key: "EntryLat")
    public var entryLat: Double?
    
    @UserDefaultsBacked(key: "EntryLng")
    public var entryLng: Double?
    
    @UserDefaultsBacked(key: "EntryStreet")
    public var entryStreet: String?
    
    @UserDefaultsBacked(key: "EntryHouseNumber")
    public var entryHouseNumber: String?
    
    @UserDefaultsBacked(key: "EntryPostcode")
    public var entryPostcode: String?
    
    @UserDefaultsBacked(key: "EntryPlace")
    public var entryPlace: String?
    
    @UserDefaultsBacked(key: "EntryPhone")
    public var entryPhone: String?
    
    @UserDefaultsBacked(key: "EntryWebsite")
    public var entryWebsite: String?
    
    @UserDefaultsBacked(key: "EntryMondayOH")
    public var entryMondayOH: String?
    
    @UserDefaultsBacked(key: "EntryTuesdayOH")
    public var entryTuesdayOH: String?
    
    @UserDefaultsBacked(key: "EntryWednesdayOH")
    public var entryWednesdayOH: String?
    
    @UserDefaultsBacked(key: "EntryThursdayOH")
    public var entryThursdayOH: String?
    
    @UserDefaultsBacked(key: "EntryFridayOH")
    public var entryFridayOH: String?
    
    @UserDefaultsBacked(key: "EntrySaturdayOH")
    public var entrySaturdayOH: String?
    
    @UserDefaultsBacked(key: "EntrySundayOH")
    public var entrySundayOH: String?
    
    @UserDefaultsBacked(key: "EntryOtherOH")
    public var entryOtherOH: String?
    
    public var entryTags: [String] {
        get { return UserDefaults.standard.stringArray(forKey: "EntryTags") ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: "EntryTags") }
    }
    
}
