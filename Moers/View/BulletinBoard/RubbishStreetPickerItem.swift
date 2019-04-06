//
//  RubbishStreetPickerItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt
import CoreLocation
import MMAPI

class RubbishStreetPickerItem: BLTNPageItem, PickerViewDelegate, PickerViewDataSource, LocationManagerDelegate {

    lazy var picker = PickerView()
    
    var streets: [RubbishCollectionStreet] = []
    
    var accentColor = UIColor.clear
    var decentColor = UIColor.clear
    
    override init(title: String) {
        super.init(title: title)
        
        picker.delegate = self
        picker.dataSource = self
        
        if AppConfig.shared.loadData {
            
            RubbishManager.shared.loadRubbishCollectionStreets { (streets) in
                
                self.streets = streets
                self.picker.reloadPickerView()
                
                self.getLocationStreet()
                
            }
            
        }
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.accentColor = theme.accentColor
            themeable.decentColor = theme.decentColor
            themeable.picker.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.heightAnchor.constraint(equalToConstant: 120).isActive = true
        descriptionLabel?.minimumScaleFactor = 0.5
        descriptionLabel?.adjustsFontSizeToFitWidth = true
        
        return [picker]
        
    }
    
    private func getLocationStreet() {
        
        if LocationManager.shared.authorizationStatus == .authorizedWhenInUse {
            
            LocationManager.shared.delegate = self
            LocationManager.shared.requestCurrentLocation()
            
        }
        
    }
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        return streets.count
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return streets[row].street
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        
        if highlighted {
            label.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
            label.textColor = accentColor
        } else {
            label.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
            label.textColor = decentColor
        }
        
    }
    
    func didReceiveCurrentLocation(location: CLLocation) {
        
        GeocodingManager.shared.street(from: location) { (street) in
            
            guard let street = street else { return }
            
            if let street = self.streets.filter({ $0.street.contains(street) }).first {
                
                self.picker.selectRow(self.streets.firstIndex(where: { $0.street == street.street }) ?? 0, animated: true)
                self.picker.adjustCurrentSelectedAfterOrientationChanges()
                
            }
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error.localizedDescription)
    }
    
}
