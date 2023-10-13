//
//  StorageManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 20.07.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine
import OSLog
import Haneke

public protocol Storageable: AnyObject {
    
    associatedtype Item: Codable
    
    var decoder: ((_ data: Data) -> AnyPublisher<[Item], Error>)? { get set }
    
    func lastReload(forKey key: String) -> Date?
    func setLastReload(_ date: Date?, forKey key: String)
    func shouldReload(interval: Double, forKey key: String) -> Bool
    
    func read(forKey key: String, with decoder: JSONDecoder) -> AnyPublisher<[Item], Error>
    func write(data: Data, forKey key: String)
    
    func reset(forKey key: String)
    
}

open class AnyStoragable<T: Codable>: Storageable {
    
    public init() {
        
    }
    
    public typealias Item = T
    
    open var decoder: ((_ data: Data) -> AnyPublisher<[T], Error>)?
    
    open func lastReload(forKey key: String) -> Date? {
        return Date()
    }
    
    open func setLastReload(_ date: Date?, forKey key: String) {
    
    }
    
    open func shouldReload(interval: Double, forKey key: String) -> Bool {
        return true
    }
    
    open func read(forKey key: String, with decoder: JSONDecoder) -> AnyPublisher<[AnyStoragable<T>.Item], Error> {
        
        return Deferred {
            return Future { promise in
                
            }
        }.eraseToAnyPublisher()
        
    }
    
    open func write(data: Data, forKey key: String) {
        
        
        
    }
    
    open func reset(forKey key: String) {
        
    }
    
}

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
    
    public override func read(forKey key: String, with decoder: JSONDecoder) -> AnyPublisher<[AnyStoragable<D>.Item], Error> {
        
        print("StorageManager: Loading \(key.localizedCapitalized) from Cache")
        
        return Deferred {
            return Future { promise in
                
                Shared.dataCache
                    .fetch(key: key)
                    .onSuccess { data in
                        
                        if let customDecoder = self.decoder {
                            
                            customDecoder(data).sink { (completion: Subscribers.Completion<Error>) in
                                
                                switch completion {
                                    case .failure(let error):
                                        promise(.success([]))
                                        if let error = error as? DecodingError {
                                            print("StorageManager: Custom Decoding failed for \(D.self) - \(error)")
                                        }
                                    default:
                                        break
                                }
                                
                            } receiveValue: { (items: [AnyStoragable<D>.Item]) in
                                promise(.success(items))
                            }
                            .store(in: &self.cancellables)
                            
                        } else {
                            
                            do {
                                let items = try decoder.decode([D].self, from: data)
                                promise(.success(items))
                            } catch {
                                promise(.success([]))
                                if let error = error as? DecodingError {
                                    print("StorageManager: \(D.self) Reading failed - \(error)")
                                }
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
