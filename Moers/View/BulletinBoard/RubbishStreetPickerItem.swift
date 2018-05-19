//
//  RubbishStreetPickerItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BulletinBoard
import Gestalt

class RubbishStreetPickerItem: PageBulletinItem, PickerViewDelegate, PickerViewDataSource {

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
                
            }
            
        }
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.accentColor = theme.accentColor
            themeable.decentColor = theme.decentColor
            themeable.picker.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    override func viewsUnderDescription(_ interfaceBuilder: BulletinInterfaceBuilder) -> [UIView]? {
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.heightAnchor.constraint(equalToConstant: 150).isActive = true
        descriptionLabel?.minimumScaleFactor = 0.5
        descriptionLabel?.adjustsFontSizeToFitWidth = true
        
        return [picker]
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
    
}
