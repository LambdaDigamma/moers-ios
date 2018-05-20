//
//  StaticTableView.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Section {
    let title: String
    let rows: [Row]
}

struct Row {
    var title: String
    var action: (() -> ())?
}
