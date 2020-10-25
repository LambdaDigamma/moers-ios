//
//  CovidIncidenceViewModel.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit
import MMAPI

struct CovidIncidenceViewModel {
    
    let incidenceResponse: IncidenceResponse
    
    private lazy var incidenceFormatter: NumberFormatter = {
        let incidenceFormatter = NumberFormatter()
        incidenceFormatter.usesGroupingSeparator = true
        incidenceFormatter.numberStyle = .decimal
        incidenceFormatter.maximumFractionDigits = 1
        incidenceFormatter.decimalSeparator = ","
        incidenceFormatter.locale = Locale.current
        return incidenceFormatter
    }()
    
    var countyIncidence: String = ""
    var countyName: String = ""
    
    init(incidenceResponse: IncidenceResponse) {
        self.incidenceResponse = incidenceResponse
        
        let countyIncidence = incidenceFormatter.string(from: NSNumber(value: incidenceResponse.countyIncidence.countyCases7Per100k)) ?? "keine Daten"
        let countyIncidenceTrend = self.visualizeInfectionTrend(slope: incidenceResponse.countyIncidence.countyCases7Per100kTrend.slope)
        
        self.countyIncidence = "\(countyIncidence) \(countyIncidenceTrend)"
        self.countyName = incidenceResponse.countyIncidence.county
        
    }
    
    private func visualizeInfectionTrend(slope: Double) -> String {
        
        if slope > 0 {
            return "▲"
        } else if slope == 0 {
            return "▶︎"
        } else if slope < 0 {
            return "▼"
        } else {
            return "-"
        }
        
    }
    
    private func colorForInfectionTrend(slope: Double) -> UIColor {
        
        if slope > 1 {
            return UIColor.red
        } else if slope > 0 {
            return UIColor.orange
        } else if slope < 0 {
            return UIColor.green
        } else {
            return UIColor.gray
        }
        
    }
    
}
