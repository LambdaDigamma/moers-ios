//
//  Combine+Extensions.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import Foundation
import Combine

public extension Subscribers.Completion {
    
    var error: Error? {
        switch self {
            case .failure(let error):
                return error
            default:
                return nil
        }
    }
    
}
