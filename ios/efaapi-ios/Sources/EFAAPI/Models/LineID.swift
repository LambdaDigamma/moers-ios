//
//  LineID.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public protocol LineIdentifiable {
    
    var lineIdentifier: String { get }
    
}

public struct LineID: Codable, LineIdentifiable {
    
    public let network: String
    public let divaLineNumber: String
    public let addition: String
    public let direction: String
    public let project: String
    
    public init(
        network: String,
        divaLineNumber: String,
        addition: String,
        direction: String,
        project: String
    ) {
        self.network = network
        self.divaLineNumber = divaLineNumber
        self.addition = addition
        self.direction = direction
        self.project = project
    }
    
    public init(motDivaParams: MotDivaParams) {
        self.network = motDivaParams.network
        self.divaLineNumber = motDivaParams.line
        self.addition = motDivaParams.supplement
        self.direction = motDivaParams.direction
        self.project = motDivaParams.project
    }
    
    public var lineIdentifier: String {
        return "\(network):\(divaLineNumber):\(addition):\(direction):\(project)"
    }
    
}
