//
//  MMUIFrameworkConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold
import Core

class MMUIFrameworkConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let theme = ApplicationTheme(
            identifier: "Mein Moers",
            color: UIColor.label,
            backgroundColor: UIColor.systemBackground, // AppColors.darkGray,
            accentColor: AppColors.navigationAccent, // AppColors.yellow,
            decentColor: UIColor.secondaryLabel,
            navigationBarColor: UIColor.systemBackground,
            tabBarColor: UIColor.systemBackground,
            cardShadow: false,
            cardBackgroundColor: UIColor.secondarySystemBackground,
            separatorColor: UIColor.separator,
            statusBarStyle: .lightContent,
            presentationStyle: .dark
        )
        
        ThemeManager.default.theme = theme
        
        MMUIConfig.registerThemeManager(ThemeManager.default)
        
    }
    
}
