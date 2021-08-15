//
//  StorageManager.swift
//  Moers
//
//  Created by Lennart Fischer on 11.02.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import ReactiveKit
import MMAPI
import Haneke
import Combine

public class StorageManager<D: Codable>: AnyStoragable<D> {
    
    private let format = "dd.MM.yyyy HH:mm:ss"
    private let bag = DisposeBag()
    
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
            
        return Signal { observer in
            
            Shared.dataCache
                .fetch(key: key)
                .onSuccess { data in
                    
                    if let customDecoder = self.decoder {
                        
                        customDecoder(data).toSignal().observeNext(with: { items in
                            observer.receive(lastElement: items)
                        }).dispose(in: self.bag)
                        
                        customDecoder(data).toSignal().observeFailed(with: { error in
                            observer.receive(lastElement: [])
                            if let error = error as? DecodingError {
                                print("StorageManager: Custom Decoding failed for \(D.self) - \(error)")
                            }
                        }).dispose(in: self.bag)
                        
                    } else {
                        
                        do {
                            let items = try decoder.decode([D].self, from: data)
                            observer.receive(lastElement: items)
                        } catch {
                            observer.receive(lastElement: [])
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
                    
                    observer.receive(lastElement: [])
                    
                }
            
            return BlockDisposable {}
            
        }
        .toPublisher()
        .eraseToAnyPublisher()
        
    }
    
    override public func write(data: Data, forKey key: String) {
        
        Shared.dataCache.set(value: data, key: key)
        
    }
    
    override public func reset(forKey key: String) {
        Shared.dataCache.remove(key: key)
    }
    
}
