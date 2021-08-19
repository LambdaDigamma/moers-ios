//
//  StaticTableView.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct TableViewSection {
    let title: String
    let rows: [Row]
}

protocol Row {
    var title: String { get set }
}

struct NavigationRow: Row {
    var title: String
    var action: (() -> Void)?
}

struct AccountRow: Row {
    var title: String
    var action: (() -> Void)?
}

struct SwitchRow: Row {
    var title: String
    var switchOn: Bool
    var action: ((Bool) -> Void)?
}
