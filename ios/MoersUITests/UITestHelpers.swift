//
//  UITestHelpers.swift
//  MoersUITests
//
//  Created by Lennart Fischer on 11.02.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import XCTest

// swiftlint:disable identifier_name
enum SizeCategory: String {
    case XS
    case S
    case M
    case L
    case XL
    case XXL
    case XXXL
}

// swiftlint:enable identifier_name
enum SizeCategoryAccessibility: String {
    
    case accessibility = "Accessibility"
    case normal = ""
    
    func description() -> String {
        return self.rawValue
    }
    
}

extension TimeInterval {
    
    init(hours: Int) {
        self = Double(hours * 60 * 60)
    }
    
    init(days: Int) {
        self = Double(days * 24 * 60 * 60)
    }
    
    /// 5 seconds
    static let short = 5.0
    
    /// 10 seconds
    static let medium = 10.0
    
    /// 20 seconds
    static let long = 20.0
    
    /// 30 seconds
    static let extraLong = 30.0
    
}

extension XCUIElement {
    
    func labelContains(text: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return staticTexts.matching(predicate).firstMatch.exists
    }
    
    func visible() -> Bool {
        guard exists, !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
    
    func waitAndTap(_ timeout: Double = .short) {
        // Need XCTAssertEqual() here because we can append a message, this is not possible for XCTAssertTrue()
        
        XCTAssertEqual(self.waitForExistence(timeout: timeout), true, "Could not find XCUIElement: \(self) before tapping it.")
        XCTAssertTrue(self.isEnabled)
        
        self.tap()
    }
    
}

extension XCUIElementQuery {
    
    var lastMatch: XCUIElement { return element(boundBy: count - 1) }
    
}

enum SupportedLanguages: String {
    case de = "de"
    case en = "en"
}

extension XCUIApplication {
    
    func setDefaults() {
        launchEnvironment["XCUI"] = "YES"
    }
    
    func setLanguageTag(_ tag: SupportedLanguages) {
        self.setLaunchArgument(LaunchArguments.Common.language, to: "(\(tag.rawValue))")
    }
    
    func setPreferredContentSizeCategory(
        accessibility: SizeCategoryAccessibility,
        size: SizeCategory
    ) {
        // see https://stackoverflow.com/questions/38316591/how-to-test-dynamic-type-larger-font-sizes-in-ios-simulator
        launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategory\(accessibility.description())\(size)"]
    }
    
    func setLaunchArgument(_ launchArgument: LaunchArgument, to value: String) {
        launchArguments.append(contentsOf: ["-\(launchArgument.name)", value])
    }
    
    func setLaunchArgument(_ launchArgument: LaunchArgument, to bool: Bool) {
        setLaunchArgument(launchArgument, to: bool ? "YES" : "NO")
    }
    
    func localized(_ key: String) -> String {
        let testBundle = Bundle(for: Snapshot.self)
        if let currentLanguage = currentLanguage,
           let testBundlePath = testBundle.path(forResource: currentLanguage.localeCode, ofType: "lproj") ??
            testBundle.path(forResource: currentLanguage.langCode, ofType: "lproj"),
           let localizedBundle = Bundle(path: testBundlePath) {
            return NSLocalizedString(key, bundle: localizedBundle, comment: "")
        }
        return ""
    }
    
    private var currentLanguage: (langCode: String, localeCode: String)? {
        guard let preferredLanguage = Locale.preferredLanguages.first else {
            fatalError("Cant unwrap: Locale.preferredLanguages.first")
        }
        let currentLocale = Locale(identifier: preferredLanguage)
        guard let langCode = currentLocale.languageCode else {
            return nil
        }
        var localeCode = langCode
        if let scriptCode = currentLocale.scriptCode {
            localeCode = "\(langCode)-\(scriptCode)"
        } else if let regionCode = currentLocale.regionCode {
            localeCode = "\(langCode)-\(regionCode)"
        }
        return (langCode, localeCode)
    }
    
}
