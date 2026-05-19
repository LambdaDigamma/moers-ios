//
//  FixedCurrentDateProvider.swift
//  CoreTests
//
//  Created by Codex on 16.05.26.
//

import Combine
import Foundation
@testable import Core

final class FixedCurrentDateProvider: CurrentDateProviding, @unchecked Sendable {
    
    private let lock = NSLock()
    private let subject: CurrentValueSubject<Date, Never>
    private var currentDate: Date
    
    var now: Date {
        lock.lock()
        defer { lock.unlock() }
        
        return currentDate
    }
    
    var dateDidChange: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(now: Date) {
        self.currentDate = now
        self.subject = CurrentValueSubject(now)
    }
    
    func setNow(_ date: Date) {
        lock.lock()
        currentDate = date
        lock.unlock()
        
        subject.send(date)
    }
    
}
