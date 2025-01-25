//
//  ApplyTableDefinition.swift
//  
//
//  Created by Lennart Fischer on 29.04.23.
//

import Foundation
import GRDB

public protocol ApplyTableDefinition {
    
    var tableName: String { get }
    
    func apply(to t: TableDefinition)
    
}
