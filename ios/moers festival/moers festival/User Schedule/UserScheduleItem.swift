//
//  UserScheduleItem.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation
import MMEvents

enum UserScheduleSection: Hashable {
    case main(DateComponents?)
    case empty
}

enum UserScheduleItem: Hashable, Equatable {
    case event(EventListItemViewModel)
    case placeholder
}

struct UserScheduleLegacyItem: Identifiable, Hashable {
    
    var id: UUID = UUID()
    var title: String
    
}
