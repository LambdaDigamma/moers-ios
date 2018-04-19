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
    
    public func loadRubbishCollectionStreets() {
        
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
                
            } catch let err as NSError {
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
        set { UserDefaults.standard.set(newValue, forKey: "RubbishStreet") }
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
