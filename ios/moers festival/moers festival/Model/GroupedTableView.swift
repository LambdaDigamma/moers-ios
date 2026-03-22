//
//  GroupedTableView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

nonisolated struct Section: Hashable, Sendable {

    let title: String
    var rows: [Row]

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.title == rhs.title
    }

}

nonisolated struct Row: Hashable, Sendable {

    let title: String
    let action: (@MainActor @Sendable () -> ())?

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.title == rhs.title
    }

}
