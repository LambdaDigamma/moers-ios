//
//  TransitLocationSearchViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation
import Combine
import EFAAPI
import ModernNetworking
import OSLog

public class TransitLocationSearchViewModel: ObservableObject {
    
    private let service: TransitService
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var searchTerm: String = ""
    @Published public var transitLocations: [TransitLocation] = []
    @Published public var recentSearches: [TransitLocation] = []
    
    public init(service: TransitService) {
        self.service = service
        
        $searchTerm
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .map({ (search) -> String? in
                if search.count < 1 {
                    self.transitLocations = []
                    return nil
                }
                
                return search
            })
            .compactMap{ $0 }
            .sink(receiveValue: { (search) in
                
                self.searchStation(searchText: search)
                
//                if !self.searchText.isEmpty {
//                    self.filteredData = self.allData.
//                    filter { $0.contains(str) }
//                } else {
//                    self.filteredData = self.allData
//                }
            }).store(in: &cancellables)
        
    }
    
    public var searchActive: Bool {
        return searchTerm != ""
    }
    
    // MARK: - Loading -
    
    public func searchStation(searchText: String) {
        
        service.findTransitLocation(for: searchText, filtering: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<HTTPError>) in
                
                switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    default: break
                }
                
            }, receiveValue: { (transitLocations: [TransitLocation]) in
                self.transitLocations = transitLocations
            })
            .store(in: &cancellables)
        
    }
    
    // MARK: - Recent -
    
    public func loadRecentSearches() {
        
        if let url = Self.buildURL() {
            
            if FileManager.default.fileExists(atPath: url.path) {
                
                do {
                    
                    let data = try Data(contentsOf: url)
                    self.recentSearches = try Self.decode(data: data)
                    
                } catch {
                    print(error)
                }
                
            }
            
        }
        
    }
    
    public func addNewRecentSearch(transitLocation: TransitLocation) {
        self.recentSearches.insert(transitLocation, at: 0)
        self.persistRecentSearches()
    }
    
    private static func buildURL() -> URL? {
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentsPath.appendingPathComponent("recent_efa_searches").appendingPathExtension("json")
        
    }

    public func persistRecentSearches() {
        
        guard let url = Self.buildURL() else { return }
        
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        
        guard let encodedData = try? Self.encode(data: recentSearches) else { return }
        
        do {
            try encodedData.write(to: url)
        } catch {
            print(error)
        }
        
    }
    
    public func delete() {
        
        guard let url = Self.buildURL() else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
        
    }
    
    public static func encode(data: [TransitLocation], prettyPrinted: Bool = false) throws -> Data {
        
        let encoder = JSONEncoder()
        
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys] : []
        
        return try encoder.encode(data)
        
    }
    
    public static func decode(data: Data) throws -> [TransitLocation] {
        
        let decoder = JSONDecoder()
        
        return try decoder.decode([TransitLocation].self, from: data)
        
    }
    
}
