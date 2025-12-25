//
//  Formattable.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

protocol Formattable {
    func format(pattern: String) -> String
}

extension Formattable where Self: CVarArg {
    
    func format(pattern: String) -> String {
        return String(format: pattern, arguments: [self])
    }
    
}

extension Int: Formattable { }
extension Double: Formattable { }
extension Float: Formattable { }
