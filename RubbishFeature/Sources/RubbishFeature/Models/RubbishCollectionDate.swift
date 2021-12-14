//
//  RubbishCollectionDate.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

public struct RubbishCollectionDate: Codable {
    
    public let id: Int
    public let date: String
    public let residualWaste: [Int]
    public let organicWaste: [Int]
    public let paperWaste: [Int]
    public let yellowBag: [Int]
    public let greenWaste: [Int]
    
}
