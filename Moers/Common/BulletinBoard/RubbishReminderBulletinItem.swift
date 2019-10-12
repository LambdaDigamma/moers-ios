//
//  RubbishReminderBulletinItem.swift
//  Moers
//
//  Created by Lennart Fischer on 22.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import BLTNBoard
import Gestalt
import MMUI

class RubbishReminderBulletinItem: BLTNPageItem {
    
    lazy var picker = UIDatePicker()
    
    override init(title: String) {
        super.init(title: title)
        
        let date = Calendar.current.date(bySettingHour: 20, minute: 00, second: 00, of: Date())
        
        picker.datePickerMode = .time
        picker.date = date ?? Date()
        picker.locale = Locale.current
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    override func makeViewsUnderDescription(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        return [picker]
        
    }
    
}

extension RubbishReminderBulletinItem: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.appearance.actionButtonColor = theme.accentColor
        self.picker.backgroundColor = theme.backgroundColor
        self.picker.performSelector(inBackground: Selector(("setHighlightsToday:")), with: theme.accentColor)
        self.picker.setValue(theme.decentColor, forKey: "textColor")
    }
    
}
