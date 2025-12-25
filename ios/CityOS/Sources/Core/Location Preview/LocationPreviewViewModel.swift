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
    
    public var annotation: AnyPublisher<MKPointAnnotation, Error> {
        
        return model.mapCoordinate.map({ coordinate in
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinate
            annotation.title = self.model.name
            
            return annotation
            
        }).eraseToAnyPublisher()
        
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
