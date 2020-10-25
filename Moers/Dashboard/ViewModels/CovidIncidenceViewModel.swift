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
    
    let rkiAttributes: RKIResponseFeatures.Attributes
    
    private lazy var incidenceFormatter: NumberFormatter = {
        let incidenceFormatter = NumberFormatter()
        incidenceFormatter.usesGroupingSeparator = true
        incidenceFormatter.numberStyle = .decimal
        incidenceFormatter.maximumFractionDigits = 1
        incidenceFormatter.decimalSeparator = ","
        incidenceFormatter.locale = Locale.current
        return incidenceFormatter
    }()
    
//    var countyIncidenceWithTrend
    
    var countyIncidence: String = ""
    
    init(rkiAttributes: RKIResponseFeatures.Attributes) {
        self.rkiAttributes = rkiAttributes
        
        self.countyIncidence = incidenceFormatter.string(from: NSNumber(value: rkiAttributes.incidenceCity)) ?? "keine Daten"
        
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
