//
//  GroupedTableView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

struct Section: Hashable {
    
    let title: String
    var rows: [Row]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.title == rhs.title
    }
    
}

struct Row: Hashable {
    
    let title: String
    let action: (() -> ())?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.title == rhs.title
    }
    
}
