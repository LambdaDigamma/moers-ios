//
//  MMEventAttendanceMode.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

nonisolated enum MMEventAttendanceMode: String, CaseIterable, Hashable {
    case offline
    case online
    case mixed

    var title: String {
        switch self {
        case .offline:
            return "Vor Ort"
        case .online:
            return "Online"
        case .mixed:
            return "Hybrid"
        }
    }
}
