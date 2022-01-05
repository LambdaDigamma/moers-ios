//
//  RubbishCollectionStreet.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import ModernNetworking

public struct RubbishCollectionStreet: Model, Codable, Equatable {
    
    public typealias ID = Int
    
    public var id: ID
    public var street: String
    public var streetAddition: String?
    public var residualWaste: Int
    public var organicWaste: Int
    public var paperWaste: Int
    public var yellowBag: Int
    public var greenWaste: Int
    public var sweeperDay: String? = ""
    public var year: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case street = "name"
        case streetAddition = "street_addition"
        case residualWaste = "residual_tour"
        case organicWaste = "organic_tour"
        case paperWaste = "paper_tour"
        case yellowBag = "plastic_tour"
        case greenWaste = "cuttings_tour"
        case year = "year"
    }
    
    public var displayName: String {
        return "\(street) \(streetAddition ?? "")"
    }
    
    public init(
        id: Int,
        street: String,
        streetAddition: String? = nil,
        residualWaste: Int,
        organicWaste: Int,
        paperWaste: Int,
        yellowBag: Int,
        greenWaste: Int,
        sweeperDay: String,
        year: Int = 2022
    ) {
        // TODO: Check this.
        self.id = id
        self.street = street
        self.streetAddition = streetAddition
        self.residualWaste = residualWaste
        self.organicWaste = organicWaste
        self.paperWaste = paperWaste
        self.yellowBag = yellowBag
        self.greenWaste = greenWaste
        self.sweeperDay = sweeperDay
        self.year = year
    }
    
}
