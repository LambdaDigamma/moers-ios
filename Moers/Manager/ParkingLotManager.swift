//
//  ParkingLotManager.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import Reachability
import CoreLocation

class ParkingLotManager: NSObject, XMLParserDelegate {
    
    static let shared = ParkingLotManager()

    private let reachability = Reachability()!
    
    private var xmlBuffer = String()
    private var valueBuffer: [String: AnyObject]? = [:]
    
    private var parkingLots: [ParkingLot] = []
    
    var completion: ((Error?, [ParkingLot]?) -> Void)?
    
    func get(completion: @escaping ((Error?, [ParkingLot]?) -> Void)) {
        
        if reachability.connection != .none {
            
            self.completion = completion
            
            let parkingLotURL = URL(string: "http://download.moers.de/Parkdaten/Parkdaten_open.php")
            
            if let parkingLotURL = parkingLotURL {
                
                let parser = XMLParser(contentsOf: parkingLotURL)
                
                parser?.delegate = self
                parser?.parse()
                
            }
            
        } else {
            completion(APIError.noConnection, nil)
        }
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        valueBuffer?[elementName] = xmlBuffer as AnyObject?
        
        xmlBuffer = ""
        
        if elementName == "eintrag" {
            
            if let valueBuffer = valueBuffer {
                
                guard let status = Status(rawValue: valueBuffer["status"] as! String) else { return }
                
                let loc = CLLocation(latitude: (valueBuffer["lat"]?.doubleValue)!, longitude: (valueBuffer["lng"]?.doubleValue)!)
                
                let newParkingLot = ParkingLot(name: (valueBuffer["name"] as! String), address: (valueBuffer["address"] as! String), slots: Int((valueBuffer["slots"]?.int64Value)!), free: Int((valueBuffer["free"]?.int64Value)!), status: status, location: loc)
                
                parkingLots.append(newParkingLot)
                
                self.valueBuffer?.removeAll()
                
            }
            
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        xmlBuffer += string
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
        completion?(nil, parkingLots)
        
        parser.delegate = nil
        
    }
    
}
