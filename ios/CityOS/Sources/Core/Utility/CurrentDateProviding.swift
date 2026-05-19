//
//  CurrentDateProviding.swift
//  Core
//
//  Created by Codex on 16.05.26.
//

import Combine
import Foundation

public protocol CurrentDateProviding: AnyObject {
    
    var now: Date { get }
    
    var dateDidChange: AnyPublisher<Date, Never> { get }
    
}
