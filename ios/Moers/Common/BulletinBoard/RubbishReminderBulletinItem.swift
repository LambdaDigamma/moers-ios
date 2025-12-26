//
//  RubbishReminderBulletinItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import BLTNBoard

class RubbishReminderBulletinItem: BLTNPageItem {
    
    lazy var picker = UIDatePicker()
    
    override init(title: String) {
        super.init(title: title)
        
        let date = Calendar.current.date(bySettingHour: 20, minute: 00, second: 00, of: Date())
        
        picker.datePickerMode = .time
        picker.date = date ?? Date()
        picker.locale = Locale.current
        picker.backgroundColor = UIColor.systemBackground
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = UIColor.systemYellow
        
        self.appearance.actionButtonColor = UIColor.systemYellow
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        return [picker]
        
    }
    
}
