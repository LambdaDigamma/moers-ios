//
//  Set+Toggle.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import Foundation

extension Set {

    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }

}
