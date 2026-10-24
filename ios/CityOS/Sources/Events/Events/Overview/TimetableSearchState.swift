//
//  TimetableSearchState.swift
//
//
//  Created by Codex on 19.05.26.
//

import Foundation

public enum TimetableSearchState: Equatable, Sendable {

    case inactive
    case loading
    case loaded
    case failed

}
