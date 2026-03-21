//
//  SidebarSection.swift
//  
//
//  Created by Lennart Fischer on 31.03.22.
//

import Foundation

public struct SidebarSection: Hashable, Equatable, Sendable {
    
    public var title: String?
    public var isCollapsable: Bool = false
    
    public init(
        title: String? = nil,
        isCollapsable: Bool = false
    ) {
        self.title = title
        self.isCollapsable = isCollapsable
    }
    
}
