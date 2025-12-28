//
//  FGDCollection.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation

public class FGDCollection {
    
    public var camping: [CampingFeature]
    public var dorf: [DorfFeature]
    public var medicalService: [MedicalServiceFeature]
    public var stages: [StageFeature]
    public var surfaces: [SurfaceFeature]
    public var tickets: [TicketFeature]
    public var toilets: [ToiletFeature]
    public var transporation: [TransportationFeature]
    
    public init(
        camping: [CampingFeature] = [],
        dorf: [DorfFeature] = [],
        medicalService: [MedicalServiceFeature] = [],
        stages: [StageFeature] = [],
        surfaces: [SurfaceFeature] = [],
        tickets: [TicketFeature] = [],
        toilets: [ToiletFeature] = [],
        transporation: [TransportationFeature] = []
    ) {
        self.camping = camping
        self.dorf = dorf
        self.medicalService = medicalService
        self.stages = stages
        self.surfaces = surfaces
        self.tickets = tickets
        self.toilets = toilets
        self.transporation = transporation
    }
    
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        try container.decode([CampingFeature].self, forKey: .camping)
//
//    }
    
    public enum CodingKeys: String, CodingKey {
        
        case camping = "camping"
        case dorf = "dorf"
        case medicalService = "medical_service"
        case stages = "stages"
        case surfaces = "surfaces"
        case tickets = "tickets"
        case toilets = "toilets"
        case transporation = "transportation"
        
    }
    
}
