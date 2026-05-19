//
//  DebugTimeSpeedPreset.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import Foundation

nonisolated enum DebugTimeSpeedPreset: Double, CaseIterable, Identifiable {
    
    case frozen = 0
    case realtime = 1
    case tenTimes = 10
    case sixtyTimes = 60
    case threeHundredTimes = 300
    
    var id: Double { rawValue }
    
    var title: String {
        "\(Int(rawValue))x"
    }
    
    static func closest(to multiplier: Double) -> DebugTimeSpeedPreset {
        allCases.min { first, second in
            abs(first.rawValue - multiplier) < abs(second.rawValue - multiplier)
        } ?? .realtime
    }
    
}

#endif
