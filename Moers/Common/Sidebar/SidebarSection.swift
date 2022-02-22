//
//  SidebarSection.swift
//  Moers
//
//  Created by Lennart Fischer on 22.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation

public enum SidebarSection: String, Hashable, Equatable {
    
    case tabs
    case organisations
    case places
    
    var title: String? {
        switch self {
            case .tabs:
                return nil
            case .organisations:
                return "Organisationen"
            case .places:
                return "Orte"
        }
    }
    
}
