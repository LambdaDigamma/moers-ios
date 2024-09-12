//
//  SidebarSection.swift
//  Moers
//
//  Created by Lennart Fischer on 22.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Foundation
import AppScaffold

extension SidebarSection {
    
    static let tabs = SidebarSection(
        title: nil,
        isCollapsable: false
    )
    
    static let organisations = SidebarSection(
        title: "Organisationen",
        isCollapsable: true
    )
    
    static let places = SidebarSection(
        title: "Orte",
        isCollapsable: true
    )
    
}
