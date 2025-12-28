//
//  UserScheduleItem.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation

enum UserScheduleSection: Hashable {
    case main(DateComponents?)
}

struct UserScheduleItem: Identifiable, Hashable {
    
    var id: UUID = UUID()
    var title: String
    
}
