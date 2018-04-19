//
//  API.swift
//  Moers
//
//  Created by Lennart Fischer on 14.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyConfiguration
import InfoKit

protocol APIDelegate {
    
    func didReceiveShops(shops: [Shop])
    
    func didReceiveParkingLots(parkingLots: [ParkingLot])
    
    func didReceiveCameras(cameras: [Camera])
    
    func didReceiveBikeChargers(chargers: [BikeChargingStation])
    
}

class API: NSObject, XMLParserDelegate {

    var delegate: APIDelegate?
    
    static let shared = API()
    
    private var session = URLSession.shared
    private var xmlBuffer = String()
    private var valueBuffer: [String: AnyObject]? = [:]
    
    private var parkingLots: [ParkingLot] = []
    private var branches: [Branch] = []
    
    public var cachedShops: [Shop] = []
    public var cachedParkingLots: [ParkingLot] = []
    public var cachedCameras: [Camera] = []
    public var cachedBikeCharger: [BikeChargingStation] = []
    
    override private init() {
        
        session = URLSession.shared
        
    }
    
    func loadShop() {
        
        let url = URL(string: "https://meinmoers.lambdadigamma.com/shops.json")
        
        if let requestURL = url {
            let request = URLRequest(url: requestURL)
            
            _ = session.dataTask(with: request, completionHandler: { data, response, error in
                
                var shops = [Shop]()
                
                do {
                    
                    if let d = data {
                        
                        let json = try JSONSerialization.jsonObject(with: d, options: .allowFragments) as? [String: AnyObject]
                        
                        if let features = json?["features"] as? [[String: AnyObject]] {
                            
                            for feature in features {
                        
                                var name = String()
                                var quarter = String()
                                var street = String()
                                var houseNumber = String()
                                var postcode = String()
                                var place = String()
                                var webAddress = URL(string: "")
                                var phone = URL(string: "")
                                var location = CLLocation()
                                var branche = String()
                                
                                if let properties = feature["properties"] as? [String: AnyObject] {
                                    
                                    if let comp = properties["Firma"] as? String {
                                        
                                        name = comp.replacingOccurrences(of: "`", with: "'")
                                        
                                    }
                                    
                                    if let quart = properties["Quartier"] as? String {
                                        
                                        quarter = quart
                                        
                                    }
                                    
                                    if let str = properties["Straße"] as? String {
                                        
                                        street = str
                                        
                                    }
                                    
                                    if let hN = properties["HausNr"] as? String {
                                        
                                        houseNumber = hN
                                        
                                    }
                                    
                                    if let plz = properties["PLZ"] as? String {
                                        
                                        postcode = plz
                                        
                                    }
                                    
                                    if let pl = properties["Ort"] as? String {
                                        
                                        place = pl
                                        
                                    }
                                    
                                    if let url = properties["URL"] as? String {
                                        
                                        if url != "" {
                                            
                                            if let url = URL(string: "http://" + url) {
                                                
                                                webAddress = url
                                                
                                            }
                                            
                                        } else {
                                            
                                            webAddress = nil
                                            
                                        }
                                        
                                    }
                                    
                                    if let fon = properties["Fon"] as? String {
                                        
                                        let filteredFon = fon.replacingOccurrences(of: " ", with: "")
                                        
                                        if let phoneUrl = URL(string: "telprompt://4902841" + filteredFon), filteredFon != "" {
                                            
                                            phone = phoneUrl
                                            
                                        }
                                        
                                    }
                                    
                                    if let bran = properties["Branche"] as? String {
                                        
                                        branche = bran
                                        
                                    }
                                    
                                    if let lng = properties["lng"] as? String {
                                        
                                        if let lat = properties["lat"] as? String {
                                            
                                            location = CLLocation(latitude: lat.doubleValue, longitude: lng.doubleValue)
                                            
                                        }
                                        
                                    }
                                    
                                    var monday_from: String = String()
                                    var monday_till: String = String()
                                    var monday_break: String? = String()
                                    var tuesday_from: String = String()
                                    var tuesday_till: String = String()
                                    var tuesday_break: String? = String()
                                    var wednesday_from: String = String()
                                    var wednesday_till: String = String()
                                    var wednesday_break: String? = String()
                                    var thursday_from: String = String()
                                    var thursday_till: String = String()
                                    var thursday_break: String? = String()
                                    var friday_from: String = String()
                                    var friday_till: String = String()
                                    var friday_break: String? = String()
                                    var saturday_from: String = String()
                                    var saturday_till: String = String()
                                    var saturday_break: String? = String()
                                    var other: String? = String()
                                    
                                    // MONDAY
                                    if let mo_from = properties["Montag_von"] as? String {
                                        
                                        monday_from = mo_from
                                        
                                    }
                                    if let mo_till = properties["Montag_bis"] as? String {
                                        
                                        monday_till = mo_till
                                        
                                    }
                                    if let mo_break = properties["Montag_Pause"] as? String {
                                        
                                        if mo_break != "" {
                                            monday_break = mo_break
                                        } else {
                                            monday_break = nil
                                        }
                                        
                                    } else {
                                        monday_break = nil
                                    }
                                    // TUESDAY
                                    if let tu_from = properties["Dienstag_von"] as? String {
                                        
                                        tuesday_from = tu_from
                                        
                                    }
                                    if let tu_till = properties["Dienstag_bis"] as? String {
                                        
                                        tuesday_till = tu_till
                                        
                                    }
                                    if let tu_break = properties["Dienstag_Pause"] as? String {
                                        
                                        if tu_break != "" {
                                            tuesday_break = tu_break
                                        } else {
                                            tuesday_break = nil
                                        }
                                        
                                    } else {
                                        tuesday_break = nil
                                    }
                                    // WEDNESDAY
                                    if let we_from = properties["Mittwoch_von"] as? String {
                                        
                                        wednesday_from = we_from
                                        
                                    }
                                    if let we_till = properties["Mittwoch_bis"] as? String {
                                        
                                        wednesday_till = we_till
                                        
                                    }
                                    if let we_break = properties["Mittwoch_Pause"] as? String {
                                        
                                        if we_break != "" {
                                            wednesday_break = we_break
                                        } else {
                                            wednesday_break = nil
                                        }
                                        
                                    } else {
                                        wednesday_break = nil
                                    }
                                    // THURSDAY
                                    if let th_from = properties["Donnerstag_von"] as? String {
                                        
                                        thursday_from = th_from
                                        
                                    }
                                    if let th_till = properties["Donnerstag_bis"] as? String {
                                        
                                        thursday_till = th_till
                                        
                                    }
                                    if let th_break = properties["Donnerstag_Pause"] as? String {
                                        
                                        if th_break != "" {
                                            thursday_break = th_break
                                        } else {
                                            thursday_break = nil
                                        }
                                        
                                    } else {
                                        thursday_break = nil
                                    }
                                    // FRIDAY
                                    if let fr_from = properties["Freitag_von"] as? String {
                                        
                                        friday_from = fr_from
                                        
                                    }
                                    if let fr_till = properties["Freitag_bis"] as? String {
                                        
                                        friday_till = fr_till
                                        
                                    }
                                    if let fr_break = properties["Freitag_Pause"] as? String {
                                        
                                        if fr_break != "" {
                                            friday_break = fr_break
                                        } else {
                                            friday_break = nil
                                        }
                                        
                                    } else {
                                        friday_break = nil
                                    }
                                    // SATURDAY
                                    if let sa_from = properties["Samstag_von"] as? String {
                                        
                                        saturday_from = sa_from
                                        
                                    }
                                    if let sa_till = properties["Samstag_bis"] as? String {
                                        
                                        saturday_till = sa_till
                                        
                                    }
                                    if let sa_break = properties["Samstag_Pause"] as? String {
                                        
                                        if sa_break != "" {
                                            saturday_break = sa_break
                                        } else {
                                            saturday_break = nil
                                        }
                                        
                                    } else {
                                        saturday_break = nil
                                    }
                                    // OTHER
                                    if let ot = properties["sonstiges"] as? String {
                                        
                                        other = ot
                                        
                                    } else {
                                        
                                        other = nil
                                        
                                    }
                                    
                                    let open = OpeningHours(monday_from: monday_from, monday_till: monday_till, monday_break: monday_break, tuesday_from: tuesday_from, tuesday_till: tuesday_till, tuesday_break: tuesday_break, wednesday_from: wednesday_from, wednesday_till: wednesday_till, wednesday_break: wednesday_break, thursday_from: thursday_from, thursday_till: thursday_till, thursday_break: thursday_break, friday_from: friday_from, friday_till: friday_till, friday_break: friday_break, saturday_from: saturday_from, saturday_till: saturday_till, saturday_break: saturday_break, other: other)
                                    
                                    
                                    let newShop = Shop(name: name, quater: quarter, street: street, houseNumber: houseNumber, postcode: postcode, place: place, url: webAddress, phone: phone, location: location, branch: branche, openingTimes: open)
                                    
                                    shops.append(newShop)
                                    
                                }
                            
                            }
                            
                            var branch: Array<Dictionary<String, String>> = []
                            
                            for shop in shops {
                                
                                if !branch.contains(where: { $0["name"] == shop.branch }) {
                                    
                                    self.branches.append(Branch(name: shop.branch, color: "#000000"))
                                    
                                    var dict = Dictionary<String, String>()
                                        
                                    dict["name"] = shop.branch
                                    dict["color"] = "#000000"
                                    
                                    branch.append(dict)
                                    
                                }
                                
                            }
                            
                            let path = Bundle.main.path(forResource: "Branches", ofType: "plist")
                            
                            if let dict = NSMutableDictionary(contentsOfFile: path!) {
                                
                                dict.setValue(branch, forKey: "branches")
                                
                                dict.write(toFile: path!, atomically: false)
                                
                            }
                            
                            self.cachedShops = shops
                            
                            self.delegate?.didReceiveShops(shops: shops)
                            
                        }
                        
                    }
                    
                } catch let err as NSError {
                    
                    print(err.localizedDescription)
                    
                }
                
            }).resume()
            
        }
        
    }
    
    func loadParkingLots() {
        
        let parkingLotURL = URL(string: "http://download.moers.de/Parkdaten/Parkdaten_open.php")
        
        if let parkingLotURL = parkingLotURL {
            
            let parser = XMLParser(contentsOf: parkingLotURL)
            
            parser?.delegate = self
            parser?.parse()
            
        }
        
    }
    
    func loadCameras() {
        
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
                
                self.cachedCameras = cameras
                self.delegate?.didReceiveCameras(cameras: cameras)
                
            } catch let err as NSError {
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    func loadBikeChargingStations() {
        
        let bikeChargingURL = URL(string: "https://www.offenesdatenportal.de/dataset/16cf7d90-dbbb-4ce1-aeec-762dfb49b973/resource/4a3b89d7-3301-45bf-97f6-9ba06b23256f/download/e-bike-ladestationen-neu.csv")
        
        if let url = bikeChargingURL {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.ascii)
                
                let csv = CSwiftV(with: content, separator: ";", headers: nil)
                
                var chargers: [BikeChargingStation] = []
                
                guard let rows = csv.keyedRows else { return }
                
                for row in rows {
                    
                    if let lat = row["slat"]?.doubleValue, let lng = row["slng"]?.doubleValue {
                        
                        let loc = CLLocation(latitude: lat, longitude: lng)
                        
                        var phone: URL? = nil
                        
                        if let tel = row["Tel"] {
                            
                            if let phoneUrl = URL(string: "telprompt://49" + tel.replacingOccurrences(of: "/", with: "")) { // telprompt://4902841
                                
                                phone = phoneUrl
                                
                            }
                            
                        }
                        
                        let openingHours = BikeChargingStation.OpeningHours(monday: row["Mo"] ?? "", tuesday: row["Di"] ?? "", wednesday: row["Mi"] ?? "", thursday: row["Do"] ?? "", friday: row["Fr"] ?? "", saturday: row["Sa"] ?? "", sunday: row["So"] ?? "", feastday: row["Feiertag"] ?? "")
                        
                        let charger = BikeChargingStation(name: row["Name"]!, location: loc, postcode: row["PLZ"]!, place: row["Ort"]!, street: row["Strasse"]!, openingHours: openingHours, phone: phone)
                        
                        chargers.append(charger)
                        
                    }
                    
                }
                
                self.cachedBikeCharger = chargers
                self.delegate?.didReceiveBikeChargers(chargers: chargers)
                
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    func loadRubbishCollectionStreets() {
        
        let url = URL(string: "https://meinmoers.lambdadigamma.com/abfallkalender-strassenverzeichnis.csv")
        
        if let url = url {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                
                let csv = CSwiftV(with: content, separator: ";", headers: ["Straße", "Restabfall", "Biotonne", "Papiertonne", "Gelber Sack", "Grünschnitt", "Kehrtag"])
                
                var streets: [RubbishCollectionStreet] = []
                
                var rows = csv.keyedRows!
                rows.remove(at: 0)
                
                for row in rows {
                    
                    let street = RubbishCollectionStreet(street: row["Straße"] ?? "",
                                                         residualWaste: Int(row["Restabfall"] ?? "")!,
                                                         organicWaste: Int(row["Biotonne"] ?? "")!,
                                                         paperWaste: Int(row["Papiertonne"] ?? "")!,
                                                         yellowBag: Int(row["Gelber Sack"] ?? "")!,
                                                         greenWaste: Int(row["Grünschnitt"] ?? "")!,
                                                         sweeperDay: row["Kehrtag"] ?? "")
                    
                    streets.append(street)
                    
                }
                
//                self.cachedCameras = cameras
//                self.delegate?.didReceiveCameras(cameras: cameras)
                
            } catch let err as NSError {
                print(err.localizedDescription)
            }
            
        }
        
        
    }
    
    func loadBranches() -> [Branch] {
        
        return self.branches
        
    }
    
    // --------------------------------------------------------------------------------
    // MARK: - XMLParser -
    // --------------------------------------------------------------------------------
    
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
        
        self.cachedParkingLots = parkingLots
        self.delegate?.didReceiveParkingLots(parkingLots: parkingLots)
        
        parser.delegate = nil
        
    }
    
}
