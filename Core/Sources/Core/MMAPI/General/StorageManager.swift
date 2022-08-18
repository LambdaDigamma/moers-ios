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
