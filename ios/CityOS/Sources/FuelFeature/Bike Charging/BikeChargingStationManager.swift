//
//  BikeChargingStationManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 06.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation
import CoreLocation

// todo: reimplement this
public struct BikeChargingStationManager {
    
    public static var shared = BikeChargingStationManager()
    
    private let url = URL(string: "https://www.offenesdatenportal.de/dataset/16cf7d90-dbbb-4ce1-aeec-762dfb49b973/resource/4a3b89d7-3301-45bf-97f6-9ba06b23256f/download/e-bike-ladestationen-neu.csv")
    
    public func loadBikeChargingStations() {
        
        guard let url = url else { return }
        
        do {
            
            let _ = try String(contentsOf: url, encoding: String.Encoding.ascii)
            
//            let csv = CSwiftV(with: content, separator: ";", headers: nil)
//
//            var chargers: [BikeChargingStation] = []
//
//            guard let rows = csv.keyedRows else { return }
//
//            for row in rows {
//
//                if let lat = row["slat"]?.doubleValue, let lng = row["slng"]?.doubleValue {
//
//                    let loc = CLLocation(latitude: lat, longitude: lng)
//
//                    var phone: URL? = nil
//
//                    if let tel = row["Tel"] {
//                        if let phoneUrl = URL(string: "telprompt://49" + tel.replacingOccurrences(of: "/", with: "")) {
//                            phone = phoneUrl
//                        }
//                    }
//
//                    let openingHours = BikeChargingStation.OpeningHours(
//                        monday: row["Mo"] ?? "",
//                        tuesday: row["Di"] ?? "",
//                        wednesday: row["Mi"] ?? "",
//                        thursday: row["Do"] ?? "",
//                        friday: row["Fr"] ?? "",
//                        saturday: row["Sa"] ?? "",
//                        sunday: row["So"] ?? "",
//                        feastday: row["Feiertag"] ?? ""
//                    )
//
//                    let charger = BikeChargingStation(
//                        name: row["Name"]!,
//                        location: loc,
//                        postcode: row["PLZ"]!,
//                        place: row["Ort"]!,
//                        street: row["Strasse"]!,
//                        openingHours: openingHours,
//                        phone: phone
//                    )
//
//                    chargers.append(charger)
//
//                }
//
//            }
            
        } catch let err {
            print(err.localizedDescription)
        }
        
    }
    
}
