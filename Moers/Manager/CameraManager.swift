//
//  CameraManager.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import CoreLocation

struct CameraManager {

    static let shared = CameraManager()
    
    private var session = URLSession.shared
    
    public func get(completion: @escaping ((Error?, [Camera]?) -> Void)) {
        
        let cameraURL = URL(string: "https://raw.githubusercontent.com/noelsch/360Moers/master/360moers_OpenData.csv")
        
        if let url = cameraURL {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                
                let csv = CSwiftV(with: content, separator: ";", headers: nil)
                
                var cameras: [Camera] = []
                
                for row in csv.rows {
                    
                    let lat = row[1].components(separatedBy: ", ").first
                    let lng = row[1].components(separatedBy: ", ").last
                    
                    if let lat = lat?.doubleValue, let lng = lng?.doubleValue {
                        
                        let location = CLLocation(latitude: lat, longitude: lng)
                        
                        let camera = Camera(name: row.first!, location: location, panoID: Int(row.last!)!)
                        
                        cameras.append(camera)
                        
                    }
                    
                }
                
                completion(nil, cameras)
                
            } catch  {
                completion(error, nil)
            }
            
        }
        
    }
    
}