//
//  RetrySearchStub.swift
//
//
//  Created by Codex on 20.05.26.
//

import Foundation
@testable import MMEvents

actor RetrySearchStub {

    private var queries: [String] = []
    private let event: Event

    init(event: Event) {
        self.event = event
    }

    func search(query: String) throws -> [Event] {
        queries.append(query)

        if queries.count == 1 {
            throw NSError(domain: "TimetableSearchTests", code: 1)
        }

        return [event]
    }

    func searchedQueries() -> [String] {
        queries
    }

}
