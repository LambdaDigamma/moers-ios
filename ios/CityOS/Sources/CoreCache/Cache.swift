//
//  Cache.swift
//  
//
//  Created by Lennart Fischer on 06.05.22.
//

import Foundation
import Cache
import Combine
import OSLog
import Core

public protocol Cache {
    
    associatedtype Data: Codable
    
    func read(_ key: String) -> AnyPublisher<Data, Error>
    
    
    func write(_ data: Data, forKey key: String)
    
}

public class DefaultCache<CacheData: Codable>: Cache {
    
    public typealias Data = CacheData
    
    private let cacheName: String
    private let storage: Storage<String, Data>
    private let logger: Logger = .init(.coreLocalData)
    
    public init(cacheName: String) throws {
        
        self.cacheName = cacheName
        
        let diskConfig = DiskConfig(name: cacheName)
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        
        self.storage = try Storage<String, Data>(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self)
        )
        
    }
    
    public func read(_ key: String) -> AnyPublisher<CacheData, Error> {
        
        return Deferred {
            return Future { promise in
                self.storage.async.entry(forKey: key) { result in
                    switch result {
                        case .success(let t):
                            promise(.success(t.object))
                        case .failure(let error):
                            promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    public func write(_ data: Data, forKey key: String) {
        
        self.storage.async.setObject(data, forKey: key) { result in
            switch result {
                case .success(_):
                    return
                case .failure(let error):
                    self.logger.error("Failed writing into '\(self.cacheName, privacy: .public)' cache: \(error.localizedDescription, privacy: .public)")
            }
        }
        
    }
    
    public func nuke() {
        
        do {
            try storage.removeAll()
        } catch {
            logger.error("Failed nuking cache '\(self.cacheName, privacy: .public)': \(error.localizedDescription, privacy: .public)")
        }
        
    }
    
}
