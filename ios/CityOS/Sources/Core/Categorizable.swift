//
//  Categorizable.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

nonisolated public protocol Categorizable {
    
    var category: String { get }
    var localizedCategory: String { get }
    
}
