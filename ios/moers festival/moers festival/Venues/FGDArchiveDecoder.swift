//
//  FGDArchiveDecoder.swift
//  moers festival
//
//  Created by Lennart Fischer on 10.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import MapKit

public class FGDArchiveDecoder {
    
    private let geoJSONDecoder = MKGeoJSONDecoder()
    
    public func decode(_ fgdDirectory: URL) throws -> FGDCollection {
        
        let archive = FGDArchive(directory: fgdDirectory)
        let camping = try decodeFeatures(CampingFeature.self, from: .camping, in: archive)
        let dorf = try decodeFeatures(DorfFeature.self, from: .dorf, in: archive)
        let medicalService = try decodeFeatures(MedicalServiceFeature.self, from: .medical_service, in: archive)
        let stages = try decodeFeatures(StageFeature.self, from: .stages, in: archive)
        let surfaces = try decodeFeatures(SurfaceFeature.self, from: .surfaces, in: archive)
        let tickets = try decodeFeatures(TicketFeature.self, from: .tickets, in: archive)
        let toilets = try decodeFeatures(ToiletFeature.self, from: .toilets, in: archive)
        let transportation = try decodeFeatures(TransportationFeature.self, from: .transportation, in: archive)
        
        return FGDCollection(
            camping: camping,
            dorf: dorf,
            medicalService: medicalService,
            stages: stages,
            surfaces: surfaces,
            tickets: tickets,
            toilets: toilets,
            transporation: transportation
        )
        
    }
    
    private func decodeFeatures<T: FGDDecodableFeature>(
        _ type: T.Type,
        from file: FGDArchive.File,
        in archive: FGDArchive
    ) throws -> [T] {
        let fileURL = archive.fileURL(for: file)
        let data = try Data(contentsOf: fileURL)
        let geoJSONFeatures = try geoJSONDecoder.decode(data)
        guard let features = geoJSONFeatures as? [MKGeoJSONFeature] else {
            throw FGDError.invalidType
        }
        
        let fgdFeatures = try features.map { try type.init(feature: $0) }
        return fgdFeatures
        
    }
    
}
