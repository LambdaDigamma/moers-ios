//
//  ApplicationTheme.swift
//  MMUI
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Gestalt
import UIKit

#if !os(tvOS)

public struct ApplicationTheme: Gestalt.Theme {
    
    public let identifier: String
    public let color: UIColor
    public let backgroundColor: UIColor
    public let accentColor: UIColor
    public let decentColor: UIColor
    public let navigationBarColor: UIColor
    public let tabBarColor: UIColor
    public let cardShadow: Bool
    public let cardBackgroundColor: UIColor
    public let separatorColor: UIColor
    public let statusBarStyle: UIStatusBarStyle
    public let presentationStyle: PresentationStyle
    
    public init(
        identifier: String,
        color: UIColor,
        backgroundColor: UIColor,
        accentColor: UIColor,
        decentColor: UIColor,
        navigationBarColor: UIColor,
        tabBarColor: UIColor,
        cardShadow: Bool,
        cardBackgroundColor: UIColor,
        separatorColor: UIColor,
        statusBarStyle: UIStatusBarStyle,
        presentationStyle: PresentationStyle
    ) {
        self.identifier = identifier
        self.color = color
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.decentColor = decentColor
        self.navigationBarColor = navigationBarColor
        self.tabBarColor = tabBarColor
        self.cardShadow = cardShadow
        self.cardBackgroundColor = cardBackgroundColor
        self.separatorColor = separatorColor
        self.statusBarStyle = statusBarStyle
        self.presentationStyle = presentationStyle
    }
    
    
    public private(set) static var all: [ApplicationTheme] = [dark, lightning, darkOrange, mono, red]
    
    public static let dark: ApplicationTheme = .init(
        identifier: "Mein Moers",
        color: UIColor.label,
        backgroundColor: UIColor.systemBackground, // AppColors.darkGray,
        accentColor: UIColor.systemYellow, // AppColors.yellow,
        decentColor: UIColor.secondaryLabel, // UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
        navigationBarColor: UIColor.systemBackground,
        tabBarColor: UIColor.systemBackground,
        cardShadow: false,
        cardBackgroundColor: UIColor.secondarySystemBackground, // AppColors.darkGray.darker(by: 2)!,
        separatorColor: UIColor.separator, // UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
        statusBarStyle: .lightContent,
        presentationStyle: .dark
    )
    
    public static let darkOrange: ApplicationTheme = .init(
        identifier: "Dark Orange",
        color: UIColor.white,
        backgroundColor: AppColors.darkGray,
        accentColor: UIColor.orange,
        decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
        navigationBarColor: UIColor.black,
        tabBarColor: UIColor.black,
        cardShadow: false,
        cardBackgroundColor: AppColors.darkGray.darker(by: 2)!,
        separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
        statusBarStyle: .lightContent,
        presentationStyle: .dark
    )
    
    public static let lightning: ApplicationTheme = .init(
        identifier: "Lightning",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor(hexString: "#C0392B")!,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor.white,
        tabBarColor: UIColor.white,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        statusBarStyle: .default,
        presentationStyle: .light
    )
    
    public static let mono: ApplicationTheme = .init(
        identifier: "Mono",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor.white,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor.black,
        tabBarColor: UIColor.black,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        statusBarStyle: .lightContent,
        presentationStyle: .light
    )
    
    public static let red: ApplicationTheme = .init(
        identifier: "Red",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor.white,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor(hexString: "#424242")!,
        tabBarColor: UIColor(hexString: "#424242")!,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        statusBarStyle: .lightContent,
        presentationStyle: .light
    )
    
    public static func register(themes: [ApplicationTheme]) {
        
        self.all = themes
        
    }
    
}

#else

public struct ApplicationTheme: Gestalt.Theme {
    
    public let identifier: String
    public let color: UIColor
    public let backgroundColor: UIColor
    public let accentColor: UIColor
    public let decentColor: UIColor
    public let navigationBarColor: UIColor
    public let tabBarColor: UIColor
    public let cardShadow: Bool
    public let cardBackgroundColor: UIColor
    public let separatorColor: UIColor
    public let presentationStyle: PresentationStyle
    
    public init(
        identifier: String,
        color: UIColor,
        backgroundColor: UIColor,
        accentColor: UIColor,
        decentColor: UIColor,
        navigationBarColor: UIColor,
        tabBarColor: UIColor,
        cardShadow: Bool,
        cardBackgroundColor: UIColor,
        separatorColor: UIColor,
        presentationStyle: PresentationStyle
    ) {
        self.identifier = identifier
        self.color = color
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.decentColor = decentColor
        self.navigationBarColor = navigationBarColor
        self.tabBarColor = tabBarColor
        self.cardShadow = cardShadow
        self.cardBackgroundColor = cardBackgroundColor
        self.separatorColor = separatorColor
        self.presentationStyle = presentationStyle
    }
    
    
    public private(set) static var all: [ApplicationTheme] = [dark, lightning, darkOrange, mono, red]
    
    public static let dark: ApplicationTheme = .init(
        identifier: "Mein Moers",
        color: UIColor.white,
        backgroundColor: AppColors.darkGray,
        accentColor: AppColors.yellow,
        decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
        navigationBarColor: UIColor.black,
        tabBarColor: UIColor.black,
        cardShadow: false,
        cardBackgroundColor: AppColors.darkGray.darker(by: 2)!,
        separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
        presentationStyle: .dark
    )
    
    public static let darkOrange: ApplicationTheme = .init(
        identifier: "Dark Orange",
        color: UIColor.white,
        backgroundColor: AppColors.darkGray,
        accentColor: UIColor.orange,
        decentColor: UIColor(red: 0x7F, green: 0x7F, blue: 0x7F),
        navigationBarColor: UIColor.black,
        tabBarColor: UIColor.black,
        cardShadow: false,
        cardBackgroundColor: AppColors.darkGray.darker(by: 2)!,
        separatorColor: UIColor(red: 0.149, green: 0.196, blue: 0.220, alpha: 1.00),
        presentationStyle: .dark
    )
    
    public static let lightning: ApplicationTheme = .init(
        identifier: "Lightning",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor(hexString: "#C0392B")!,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor.white,
        tabBarColor: UIColor.white,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        presentationStyle: .light
    )
    
    public static let mono: ApplicationTheme = .init(
        identifier: "Mono",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor.white,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor.black,
        tabBarColor: UIColor.black,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        presentationStyle: .light
    )
    
    public static let red: ApplicationTheme = .init(
        identifier: "Red",
        color: UIColor.black,
        backgroundColor: UIColor.white,
        accentColor: UIColor.white,
        decentColor: UIColor.lightGray,
        navigationBarColor: UIColor(hexString: "#424242")!,
        tabBarColor: UIColor(hexString: "#424242")!,
        cardShadow: true,
        cardBackgroundColor: UIColor.white,
        separatorColor: UIColor.lightGray,
        presentationStyle: .light
    )
    
    public static func register(themes: [ApplicationTheme]) {
        
        self.all = themes
        
    }
    
}

#endif

public enum PresentationStyle {
    case dark
    case light
}
