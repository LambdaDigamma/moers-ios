//
//  Collection+Extensions.swift
//  
//
//  Created by Lennart Fischer on 05.01.22.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}
