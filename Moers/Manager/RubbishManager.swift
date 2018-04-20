//
//  RubbishManager.swift
//  Moers
//
//  Created by Lennart Fischer on 19.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

class RubbishManager {
    
    static let shared = RubbishManager()
    
    private let rubbishStreetURL = URL(string: "https://meinmoers.lambdadigamma.com/abfallkalender-strassenverzeichnis.csv")
    private let rubbishDateURL = URL(string: "https://www.offenesdatenportal.de/dataset/fe92e461-9db4-4d12-ba58-8d4439084e90/resource/04c58f79-e903-46d4-afc9-d546f4474543/download/abfallkalender--abfuhrtermine-2018.csv")
    
    public func loadRubbishCollectionStreets(completion: @escaping ([RubbishCollectionStreet]) -> Void) {
        
        if let url = rubbishStreetURL {
            
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
                
                completion(streets)
                
            } catch let err as NSError {
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    public func loadRubbishCollectionDate(completion: @escaping ([RubbishCollectionDate]) -> Void) {
        
        if let url = rubbishDateURL {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.ascii)
                
                let csv = CSwiftV(with: content, separator: ";", headers: ["id", "datum", "rest_woche", "restabfall", "biotonne", "papiertonne", "gelber_sack", "gruenschnitt", "schadstoff", "del"])
                
                var dates: [RubbishCollectionDate] = []
                
                var rows = csv.keyedRows!
                rows.remove(at: 0)
                
                for row in rows {
                    
                    let date = RubbishCollectionDate(id: Int(row["id"] ?? "")!,
                                                     date: row["datum"] ?? "",
                                                     residualWaste: Int(row["restabfall"] ?? ""),
                                                     organicWaste: Int(row["biotonne"] ?? ""),
                                                     paperWaste: Int(row["papiertonne"] ?? ""),
                                                     yellowBag: Int(row["gelber_sack"] ?? ""),
                                                     greenWaste: Int(row["gruenschnitt"] ?? ""))
                    
                    dates.append(date)
                    
                }
                
                completion(dates)
                
            } catch let err {
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    public func register(_ street: RubbishCollectionStreet) {
        
        self.street = street.street
        self.residualWaste = street.residualWaste
        self.organicWaste = street.organicWaste
        self.paperWaste = street.paperWaste
        self.yellowBag = street.yellowBag
        self.greenWaste = street.greenWaste
        self.sweeperDay = street.sweeperDay
        
    }
    
    public func loadItems(completion: @escaping ([RubbishCollectionItem]) -> Void, all: Bool = false) {
        
        loadRubbishCollectionDate { (dates) in
            
            let residual = dates.filter { $0.residualWaste == self.residualWaste && $0.residualWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .residual) }
            let organic = dates.filter { $0.organicWaste == self.organicWaste && $0.organicWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .organic) }
            let paper = dates.filter { $0.paperWaste == self.paperWaste && $0.paperWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .paper) }
            let yellow = dates.filter { $0.yellowBag == self.yellowBag && $0.yellowBag != nil }.map { RubbishCollectionItem(date: $0.date, type: .yellow) }
            let green = dates.filter { $0.greenWaste == self.greenWaste && $0.greenWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .green) }
            
            var items = residual + organic + paper + yellow + green
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            items.sort(by: { dateFormatter.date(from: $0.date)! < dateFormatter.date(from: $1.date)! })
            
            if !all {
                
                let today = Date()
                
                let futureItems = items.filter { dateFormatter.date(from: $0.date)! > today }
                
                completion(futureItems)
                
            } else {
                completion(items)
            }
            
        }
        
    }
    
    public var rubbishStreet: RubbishCollectionStreet? {
        
        guard let street = street else { return nil }
        guard let residualWaste = residualWaste else { return nil }
        guard let organicWaste = organicWaste else { return nil }
        guard let paperWaste = paperWaste else { return nil }
        guard let yellowBag = yellowBag else { return nil }
        guard let greenWaste = greenWaste else { return nil }
        
        return RubbishCollectionStreet(street: street,
                                       residualWaste: residualWaste,
                                       organicWaste: organicWaste,
                                       paperWaste: paperWaste,
                                       yellowBag: yellowBag,
                                       greenWaste: greenWaste,
                                       sweeperDay: sweeperDay ?? "")
        
    }
    
    private var street: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishStreet") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishStreet") }
    }
    
    private var residualWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishResidualWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishResidualWaste") }
    }
    
    private var organicWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishOrganicWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishOrganicWaste") }
    }
    
    private var paperWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishPaperWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishPaperWaste") }
    }
    
    private var yellowBag: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishYellowBag") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishYellowBag") }
    }
    
    private var greenWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishGreenWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishGreenWaste") }
    }
    
    private var sweeperDay: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishSweeperDay") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishSweeperDay") }
    }
    
}
