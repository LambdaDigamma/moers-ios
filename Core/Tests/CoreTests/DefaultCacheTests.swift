//
//  DefaultCacheTests.swift
//  
//
//  Created by Lennart Fischer on 08.06.22.
//

import Foundation
import XCTest
import Combine
@testable import CoreCache

public final class DefaultCacheTests: XCTestCase {
    
    private struct ExampleEntry: Codable {
        let value: Int
    }
    
    var cancellables = Set<AnyCancellable>()
    
    func test_write() throws {
        
        let cache = try DefaultCache<ExampleEntry>(cacheName: "TestCache")
        let entry = ExampleEntry(value: 10)
        
        cache.write(entry, forKey: "1")
        
        let expecation = expectation(description: "Reading the cache")
        
        cache.read("1").sink { (result) in
            
        } receiveValue: { (entry: ExampleEntry) in
            XCTAssertEqual(entry.value, 10)
            expecation.fulfill()
        }
        .store(in: &cancellables)

        wait(for: [expecation], timeout: 2)
        
    }
    
    func test_read_when_not_available() throws {
        
        let cache = try DefaultCache<ExampleEntry>(cacheName: "AnotherCache")
        let expecation = expectation(description: "Reading the cache")
        
        cache.read("1").sink { (result) in
            
            switch result {
                case .failure(_):
                    expecation.fulfill()
                default: break
            }
            
        } receiveValue: { (entry: ExampleEntry) in
            
        }
        .store(in: &cancellables)
        
        wait(for: [expecation], timeout: 2)
        
    }
    
}
