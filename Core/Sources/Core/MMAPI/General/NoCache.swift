//
//  NoCache.swift
//  MMAPI
//
//  Created by Lennart Fischer on 11.02.20.
//  Copyright © 2020 LambdaDigamma. All rights reserved.
//

import Foundation
import Combine

public class NoCache<D: Codable>: AnyStoragable<D> {
    
    private let format = "dd.MM.yyyy HH:mm:ss"
    
    public override init() {
        
    }
    
    override public func lastReload(forKey key: String) -> Date? {
        return nil
    }
    
    override public func setLastReload(_ date: Date?, forKey key: String) {
        
    }
    
    /// Determines whether new data should be fetched based on the given interval
    /// - Parameters:
    ///   - interval: The interval in minutes that should use cached values.
    ///   - key: The key used for storing the last update date.
    override public func shouldReload(interval: Double, forKey key: String) -> Bool {
        return true
    }
    
    public override func read(forKey key: String, with decoder: JSONDecoder) -> AnyPublisher<[AnyStoragable<D>.Item], Error> {
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
    }
    
    override public func write(data: Data, forKey key: String) {
        
    }
    
    override public func reset(forKey key: String) {
        
    }
    
}
