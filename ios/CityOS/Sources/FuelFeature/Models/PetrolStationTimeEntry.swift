//
//  PetrolStationTimeEntry.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

nonisolated public struct PetrolStationTimeEntry: Codable, Equatable {
    
    public var text: String
    public var start: String
    public var end: String
    
    public init(
        text: String,
        start: String,
        end: String
    ) {
        self.text = text
        self.start = start
        self.end = end
    }
    
}
