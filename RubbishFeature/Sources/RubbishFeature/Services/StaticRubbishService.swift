//
//  StaticRubbishService.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation
import Combine

public class StaticRubbishService: RubbishService {
    
    public private(set) var rubbishStreet: RubbishCollectionStreet?
    public var isEnabled: Bool
    public var remindersEnabled: Bool
    public private(set) var reminderHour: Int?
    public private(set) var reminderMinute: Int?
    
    public init(
        rubbishStreet: RubbishCollectionStreet? = nil,
        isEnabled: Bool = true,
        remindersEnabled: Bool = false,
        reminderHour: Int? = nil,
        reminderMinute: Int? = nil
    ) {
        self.rubbishStreet = rubbishStreet
        self.isEnabled = isEnabled
        self.remindersEnabled = remindersEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
    }
    
    public func register(_ street: RubbishCollectionStreet) {
        self.rubbishStreet = street
    }
    
    public func loadRubbishCollectionStreets() -> AnyPublisher<[RubbishCollectionStreet], Error> {
        
        return Just([
            RubbishCollectionStreet(
                id: 1,
                street: "Musterstraße",
                residualWaste: 0,
                organicWaste: 0,
                paperWaste: 0,
                yellowBag: 0,
                greenWaste: 0,
                sweeperDay: ""
            ),
            RubbishCollectionStreet(
                id: 1,
                street: "Buschstraße",
                residualWaste: 0,
                organicWaste: 0,
                paperWaste: 0,
                yellowBag: 0,
                greenWaste: 0,
                sweeperDay: ""
            ),
        ])
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
    public func loadRubbishPickupItems(
        for street: RubbishCollectionStreet
    ) -> AnyPublisher<[RubbishPickupItem], Error> {
        
        return Just([
            RubbishPickupItem(date: .init(timeIntervalSinceNow: 3 * 24 * 60 * 60), type: .plastic),
            RubbishPickupItem(date: .init(timeIntervalSinceNow: 5 * 24 * 60 * 60), type: .paper),
            RubbishPickupItem(date: .init(timeIntervalSinceNow: 6 * 24 * 60 * 60), type: .organic),
        ])
        .setFailureType(to: Error.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func registerNotifications(at hour: Int, minute: Int) {
        self.reminderHour = hour
        self.reminderMinute = minute
        self.remindersEnabled = true
    }
    
    public func invalidateRubbishReminderNotifications() {
        
    }
    
    public func disableReminder() {
        self.remindersEnabled = false
        self.reminderHour = nil
        self.reminderMinute = nil
    }
    
    public func disableStreet() {
        self.rubbishStreet = nil
    }
    
}
