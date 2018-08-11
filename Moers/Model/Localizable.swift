//
//  Localizable.swift
//  Moers
//
//  Created by Lennart Fischer on 11.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

protocol Localizable {
    
    static func localizedForCase(_ c: Self) -> String
    
}
