//
//  MMEventsTestCurrentDateProvider.swift
//
//
//  Created by Codex on 17.05.26.
//

import Combine
import Core
import Foundation

final class MMEventsTestCurrentDateProvider: CurrentDateProviding {

    private let subject = PassthroughSubject<Date, Never>()

    var now: Date {
        didSet {
            subject.send(now)
        }
    }

    var dateDidChange: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }

    init(now: Date) {
        self.now = now
    }

}
