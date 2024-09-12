//
//  TestHelpers.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import ModernNetworking
import XCTest
import Combine

internal class ServiceTestCase: XCTestCase {
    
    internal var cancellables = Set<AnyCancellable>()
    
}

internal func defaultLoader() -> HTTPLoader {
    
    return URLSessionLoader(.shared)
    
}
