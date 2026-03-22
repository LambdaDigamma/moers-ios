//
//  UserScheduleItem.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation
import MMEvents

nonisolated enum UserScheduleSection: Hashable, Sendable {
    case main(DateComponents?)
    case empty
}

nonisolated enum UserScheduleItem: Hashable, Equatable, Sendable {
    case event(UUID)
    case placeholder
}

struct UserScheduleLegacyItem: Identifiable, Hashable {
    
    var id: UUID = UUID()
    var title: String
    
}
