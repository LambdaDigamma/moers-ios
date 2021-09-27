//
//  AppStrings.swift
//  
//
//  Created by Lennart Fischer on 13.09.21.
//

import Foundation

// swiftlint:disable line_length
public enum AppStrings {
    
    public static let appName = String.localized("AppName")
    
    public enum Waste {
        public static let errorMessage = String.localized("Waste.errorMessage")
        public static let loadingFailed = String.localized("Waste.loadingFailed")
        public static let noUpcomingRubbishItems = String.localized("Waste.noUpcomingRubbishItems")
    }
    
    public enum Buergerfunk {
        public static let title = "Bürgerfunk"
        public static let description = "Täglich gibt es zwischen 20 und 21 Uhr auf Radio K.W. (sonn- und feiertags ab 19:04 Uhr) ein etwas anderes Radio – den Bürgerfunk. Menschen aus dem Kreis Wesel verbringen viele Stunden ihrer Freizeit in Produktionsstudios, um täglich eine Stunde Programm über den Äther zu schicken."
        public static let nextBroadcasts = "Nächste Sendungen"
        public static let contactAction = "Kontaktieren"
        public static let disclaimer = "Die Daten werden vom Bürgerfunk Moers zur Verfügung gestellt. Es besteht keine Garantie auf Richtigkeit bzw. Vollständigkeit."
        public static let allAction = "Alle"
        public static let listenToPastBroadcasts = "Vergangene Sendungen hören"
        
        public static let listenNowAction = "Jetzt hören"
        public static let remindMeAction = "Erinnerung erstellen"
    }
    
}
