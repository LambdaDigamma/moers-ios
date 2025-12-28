//
//  GroupedTableView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

struct Section {
    
    let title: String
    var rows: [Row]
    
}

struct Row {
    
    let title: String
    let action: (() -> ())?
    
}
