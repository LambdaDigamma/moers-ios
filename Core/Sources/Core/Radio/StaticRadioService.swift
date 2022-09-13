//
//  StaticRadioService.swift
//  
//
//  Created by Lennart Fischer on 29.08.22.
//

import Foundation
import Combine
import OSLog

#if canImport(UserNotifications)
import UserNotifications
#endif

public class StaticRadioService: RadioServiceProtocol {
    
    private let broadcasts: [RadioBroadcast]
    
    public init(broadcasts: [RadioBroadcast]) {
        self.broadcasts = broadcasts
    }
    
    // swiftlint:disable line_length
    public init() {
        self.broadcasts = [
            .init(
                id: 1,
                uid: "2332866A-8109-45B0-BBA5-D936D6B51E17",
                title: "Was ist los im Kreis Wesel",
                description: "Antworten auf diese Frage gibt's im Magazin aus Neukirchen-Vluyn und dazu viel Oldie-Musik."
            ),
            .init(
                id: 2,
                uid: "29BF8CAA-5B1E-406D-A8FE-38EEA7ECBBB7",
                title: "Ossenberger Markt mit besonderem Flair",
                description: "Der Ossenberger Wochenmarkt, eine Besonderheit hier am Niederrhein mit einem ganz besonderem Flair. Er lockt Woche für Woche, Samstag für Samstag die Menschen vom Niederrhein an und zieht sie in seinen Bann, zum Verweilen und zum stressfreien Einkaufen in einer schönen Umgebung."
            )
        ]
    }
    // swiftlint:enable line_length
    
    public func load() -> AnyPublisher<[RadioBroadcast], Error> {
        
        return Just(broadcasts)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
}
