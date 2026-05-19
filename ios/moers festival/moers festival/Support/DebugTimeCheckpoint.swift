//
//  DebugTimeCheckpoint.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import Foundation

nonisolated struct DebugTimeCheckpoint: Identifiable, Equatable {
    
    let id: String
    let title: String
    let date: Date
    
    init(title: String, date: Date) {
        self.id = "\(title)-\(date.timeIntervalSince1970)"
        self.title = title
        self.date = date
    }
    
}

#endif
