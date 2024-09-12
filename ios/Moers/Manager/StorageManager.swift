//
//  StorageManager.swift
//  
//
//  Created by Lennart Fischer on 02.06.22.
//

import Core
import Haneke
import Combine
import OSLog

public class StorageManager<D: Codable>: AnyStoragable<D> {
    
    private let format = "dd.MM.yyyy HH:mm:ss"
    
    private var cancellables = Set<AnyCancellable>()
    
    public override init() {
        super.init()
    }
    
    override public func lastReload(forKey key: String) -> Date? {
        
        if let lastFetch = UserDefaults.standard.string(forKey: key) {
            return Date.from(lastFetch, withFormat: format)
        } else {
            return nil
        }
        
    }
    
    override public func setLastReload(_ date: Date?, forKey key: String) {
        
        if let date = date {
            UserDefaults.standard.set(date.format(format: format), forKey: key)
        } else {
            UserDefaults.standard.set(nil, forKey: key)
        }
        
    }
    
    /// Determines whether new data should be fetched based on the given interval
    /// - Parameters:
    ///   - interval: The interval in minutes that should use cached values.
    ///   - key: The key used for storing the last update date.
    override public func shouldReload(interval: Double, forKey key: String) -> Bool {
        
        if let lastReload = lastReload(forKey: key) {
            return lastReload.timeIntervalSince(Date()) < -60 * interval
        } else {
            return true
        }
        
    }
    
    override public func read(forKey key: String, with decoder: JSONDecoder) -> AnyPublisher<[D], Error> {
        
        print("StorageManager: Loading \(key.localizedCapitalized) from Cache")
        
        return Deferred {
            Future { promise in
                
                Shared.dataCache
                    .fetch(key: key)
                    .onSuccess { data in
                        
                        if let customDecoder = self.decoder {
                            
                            customDecoder(data).sink { (completion: Subscribers.Completion<Error>) in
                                
                                switch completion {
                                    case .failure(let error):
                                        
                                        if let error = error as? DecodingError {
                                            print("StorageManager: Custom Decoding failed for \(D.self) - \(error)")
                                        }
                                        
                                        promise(.success([]))
                                        
                                    default: break
                                }
                                
                            } receiveValue: { items in
                                promise(.success(items))
                            }
                            .store(in: &self.cancellables)
                            
                        } else {
                            
                            do {
                                let items = try decoder.decode([D].self, from: data)
                                promise(.success(items))
                            } catch {
                                
                                if let error = error as? DecodingError {
                                    print("StorageManager: \(D.self) Reading failed - \(error)")
                                }
                                
                                promise(.success([]))
                                
                            }
                            
                        }
                        
                    }
                    .onFailure { error in
                        
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        
                        promise(.success([]))
                        
                    }
                
            }
        }.eraseToAnyPublisher()
        
    }
    
    override public func write(data: Data, forKey key: String) {
        
        Shared.dataCache.set(value: data, key: key)
        
    }
    
    override public func reset(forKey key: String) {
        Shared.dataCache.remove(key: key)
    }
    
}
