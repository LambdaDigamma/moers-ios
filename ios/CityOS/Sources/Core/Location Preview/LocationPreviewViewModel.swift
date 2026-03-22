//
//  LocationPreviewViewModel.swift
//  MMUI
//
//  Created by Lennart Fischer on 26.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import MapKit
import Combine

public struct LocationPreviewViewModel {
    
    public let model: LocationPreviewModel
    
    public func annotation() async throws -> MKPointAnnotation {

        let coordinate = try await model.mapCoordinate()
        let annotation = MKPointAnnotation()

        annotation.coordinate = coordinate
        annotation.title = model.name

        return annotation

    }
    
    public var name: CurrentValueSubject<String, Never> {
        return CurrentValueSubject(model.name)
    }
    
    public var details: CurrentValueSubject<String, Never> {
        
        let details = """
        \(model.street ?? "") \(model.houseNumber ?? "")
        \(model.postcode ?? "") \(model.place ?? "")
        """
        
        return CurrentValueSubject(details)
        
    }
    
}
