//
//  RubbishService.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation

public protocol RubbishService {
    
    var rubbishStreet: RubbishCollectionStreet? { get }
    var isEnabled: Bool { get set }
    var remindersEnabled: Bool { get set }
    var reminderHour: Int? { get }
    var reminderMinute: Int? { get }
    
    func register(_ street: RubbishCollectionStreet)
    
    func loadRubbishCollectionStreets() async throws -> [RubbishCollectionStreet]
    
    func loadRubbishPickupItems(
        for street: RubbishCollectionStreet
    ) async throws -> [RubbishPickupItem]
    
    func registerNotifications(at hour: Int, minute: Int)
    
    func invalidateRubbishReminderNotifications()
    
    func disableReminder()
    
    func disableStreet()
    
}
