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
    let subtitle: String?
    let symbolName: String?
    let iconStyle: RowIconStyle?
    let style: RowStyle
    let action: (@MainActor @Sendable () -> ())?

    init(
        title: String,
        subtitle: String? = nil,
        symbolName: String? = nil,
        iconStyle: RowIconStyle? = nil,
        style: RowStyle = .standard,
        action: (@MainActor @Sendable () -> ())? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.iconStyle = iconStyle
        self.style = style
        self.action = action
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(style)
    }

    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.title == rhs.title && lhs.style == rhs.style
    }

}

nonisolated enum RowStyle: String, Hashable, Sendable {
    case standard
    case hero
}

nonisolated enum RowIconStyle: String, Hashable, Sendable {
    case blue
    case indigo
    case purple
    case pink
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case gray
}
