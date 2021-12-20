//
//  RubbishDashboardConfiguration.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import SwiftUI
import RubbishFeature

public struct RubbishDashboardConfiguration: DashboardItemConfigurable {
    
    public let id: UUID
    public var rubbishStreetID: RubbishCollectionStreet.ID?
    
    public init(
        rubbishStreetID: RubbishCollectionStreet.ID? = nil
    ) {
        self.id = UUID()
        self.rubbishStreetID = rubbishStreetID
    }
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case rubbishStreetID = "rubbish_street_id"
    }
    
}
