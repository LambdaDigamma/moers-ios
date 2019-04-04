//
//  RubbishManager.swift
//  Moers
//
//  Created by Lennart Fischer on 19.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class RubbishManager {
    
    static let shared = RubbishManager()
    
    private let rubbishStreetURL = URL(string: "https://meinmoers.lambdadigamma.com/abfallkalender-strassenverzeichnis-2019.csv")
    private let rubbishDateURL = URL(string: "https://www.offenesdatenportal.de/dataset/fe92e461-9db4-4d12-ba58-8d4439084e90/resource/7a2fd251-e470-4ebb-a092-73cd1d3499ac/download/abfk-2019-termine.csv")
    private var requests: [UNNotificationRequest] = []
    
    public func loadRubbishCollectionStreets(completion: @escaping ([RubbishCollectionStreet]) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            if let url = self.rubbishStreetURL {
                
                do {
                    
                    let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                    
                    let csv = CSwiftV(with: content, separator: ";", headers: ["_id", "Straße", "Restabfall", "Biotonne", "Papiertonne", "Gelber Sack", "Grünschnitt", "Kehrtag"])
                    
                    var streets: [RubbishCollectionStreet] = []
                    
                    var rows = csv.keyedRows!
                    rows.remove(at: 0)
                    
                    for row in rows {
                        
                        let street = RubbishCollectionStreet(street: row["Straße"] ?? "",
                                                             residualWaste: Int(row["Restabfall"] ?? "")!,
                                                             organicWaste: Int(row["Biotonne"] ?? "")!,
                                                             paperWaste: Int(row["Papiertonne"] ?? "")!,
                                                             yellowBag: Int(row["Gelber Sack"] ?? "")!,
                                                             greenWaste: Int(row["Grünschnitt"] ?? "")!,
                                                             sweeperDay: row["Kehrtag"] ?? "")
                        
                        streets.append(street)
                        
                    }
                    
                    DispatchQueue.main.async {
                        completion(streets)
                    }
                    
                } catch let err as NSError {
                    print(err.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    public func loadRubbishCollectionDate(completion: @escaping ([RubbishCollectionDate]) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            if let url = self.rubbishDateURL {
                
                do {
                    
                    let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                    
                    let csv = CSwiftV(with: content, separator: ",", headers: ["_id", "datum", "restabfall", "biotonne", "papiertonne", "gelber_sack", "gruenschnitt", "schadstoff"])
                    
                    var dates: [RubbishCollectionDate] = []
                    
                    var rows = csv.keyedRows!
                    rows.remove(at: 0)
                    
                    for row in rows {
                        
                        let date = RubbishCollectionDate(id: Int(row["_id"] ?? "")!,
                                                         date: row["datum"] ?? "",
                                                         residualWaste: self.rowToArray(row["restabfall"]),
                                                         organicWaste: self.rowToArray(row["biotonne"]),
                                                         paperWaste: self.rowToArray(row["papiertonne"]),
                                                         yellowBag: self.rowToArray(row["gelber_sack"]),
                                                         greenWaste: self.rowToArray(row["gruenschnitt"]))
                        
                        dates.append(date)
                        
                    }
                    
                    DispatchQueue.main.async {
                        
                        completion(dates)
                        
                    }
                    
                } catch let err {
                    print(err.localizedDescription)
                }
                
            }
            
        }
        
    }
    
    public func register(_ street: RubbishCollectionStreet) {
        
        self.street = street.street
        self.residualWaste = street.residualWaste
        self.organicWaste = street.organicWaste
        self.paperWaste = street.paperWaste
        self.yellowBag = street.yellowBag
        self.greenWaste = street.greenWaste
        self.sweeperDay = street.sweeperDay
        
    }
    
    public func loadItems(completion: @escaping ([RubbishCollectionItem]) -> Void, all: Bool = false) {
        
        loadRubbishCollectionDate { (dates) in
            
            let residual = dates.filter { $0.residualWaste.contains(self.residualWaste ?? -1) }.map { RubbishCollectionItem(date: $0.date, type: .residual) }
            let organic = dates.filter { $0.organicWaste.contains(self.organicWaste ?? -1) }.map { RubbishCollectionItem(date: $0.date, type: .organic) }
            let paper = dates.filter { $0.paperWaste.contains(self.paperWaste ?? -1) }.map { RubbishCollectionItem(date: $0.date, type: .paper) }
            let yellow = dates.filter { $0.yellowBag.contains(self.yellowBag ?? -1) }.map { RubbishCollectionItem(date: $0.date, type: .yellow) }
            let green = dates.filter { $0.greenWaste.contains(self.greenWaste ?? -1) }.map { RubbishCollectionItem(date: $0.date, type: .green) }
            
            var items = residual + organic + paper + yellow + green
            
            items.sort(by: { $0.parsedDate < $1.parsedDate })
            
            if !all {
                
                let today = Date()
                
                let futureItems = items.filter { $0.parsedDate > today || $0.parsedDate.isToday }
                
                DispatchQueue.main.async {
                    completion(futureItems)
                }
                
            } else {
                
                DispatchQueue.main.async {
                    completion(items)
                }
                
            }
            
        }
        
    }
    
    public var rubbishStreet: RubbishCollectionStreet? {
        
        guard let street = street else { return nil }
        guard let residualWaste = residualWaste else { return nil }
        guard let organicWaste = organicWaste else { return nil }
        guard let paperWaste = paperWaste else { return nil }
        guard let yellowBag = yellowBag else { return nil }
        guard let greenWaste = greenWaste else { return nil }
        
        return RubbishCollectionStreet(street: street,
                                       residualWaste: residualWaste,
                                       organicWaste: organicWaste,
                                       paperWaste: paperWaste,
                                       yellowBag: yellowBag,
                                       greenWaste: greenWaste,
                                       sweeperDay: sweeperDay ?? "")
        
    }
    
    public func registerNotifications(at hour: Int, minute: Int) {
        
        self.reminderHour = hour
        self.reminderMinute = minute
        self.remindersEnabled = true
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            self.loadItems(completion: { (items) in
                
                // Build Rubbish Collection Notification Requests
                
                for item in items {
                
                    let notificationContent = UNMutableNotificationContent()
                    
                    notificationContent.badge = 1
                    notificationContent.title = String.localized("RubbishCollectionNotificationTitle")
                    notificationContent.body = String.localized("RubbishCollectionNotificationBody") + RubbishWasteType.localizedForCase(item.type)
                    
                    let date = item.parsedDate
                        
                    let calendar = Calendar.current
                    
                    var dateComponents = DateComponents()
                    
                    let previousDate = calendar.date(byAdding: .day, value: -1, to: date) ?? Date()
                    
                    dateComponents.day = calendar.component(.day, from: previousDate)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.year = calendar.component(.year, from: date)
                    dateComponents.hour = self.reminderHour ?? 20
                    dateComponents.minute = self.reminderMinute ?? 0
                    dateComponents.second = 0
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let identifier = "RubbishReminder-\(dateComponents.day ?? 0)-\(dateComponents.month ?? 0)-\(dateComponents.year ?? 0)-\(item.type.rawValue)"
                    
                    let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
                    
                    self.requests.append(request)
                    
                }
                
                self.invalidateRubbishReminderNotifications()
                
                // Recursively schedule all Notifications
                
                self.scheduleNextNotification()
                
            })
            
        }
        
    }
    
    public func scheduleNextNotification() {
        
        if let request = requests.popLast() {
            
            self.scheduleNotification(request: request, completion: scheduleNextNotification)
            
        } else  {
            
            UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
                
                print("Scheduled \(requests.count) notifications")
                
            }
            
        }
        
    }
    
    public func scheduleNotification(request: UNNotificationRequest, completion: @escaping () -> Void) {
        
        let center = UNUserNotificationCenter.current()
        
        center.add(request, withCompletionHandler: { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
            
        })
        
    }
    
    public func invalidateRubbishReminderNotifications() {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    public func registerTestNotification() {
        
        let date = Date()
        
        let item = RubbishCollectionItem(date: date.format(format: "dd.MM.yyyy"), type: .paper)
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.badge = 1
        notificationContent.title = "Abfuhrkalender"
        notificationContent.subtitle = "Morgen wird abgeholt: \(item.type.rawValue)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: "RubbishReminder", content: notificationContent, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        
        center.add(request, withCompletionHandler: { (error) in
            
            guard let error = error else { return }
            
            print(error.localizedDescription)
            
        })
        
    }
    
    public func disableReminder() {
        
        self.invalidateRubbishReminderNotifications()
        self.remindersEnabled = false
        self.reminderHour = 20
        self.reminderMinute = 0
        
    }
    
    public func disableStreet() {
        
        self.street = nil
        self.residualWaste = nil
        self.organicWaste = nil
        self.paperWaste = nil
        self.yellowBag = nil
        self.greenWaste = nil
        self.sweeperDay = nil
        
    }
    
    public var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "RubbishEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishEnabled") }
    }
    
    public internal(set) var reminderHour: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishReminderHour") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishReminderHour") }
    }
    
    public internal(set) var reminderMinute: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishReminderMinute") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishReminderMinute") }
    }
    
    public var remindersEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "RubbishRemindersEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishRemindersEnabled") }
    }
    
    internal var street: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishStreet") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishStreet") }
    }
    
    internal var residualWaste: Int? {
        get {
            let residual = UserDefaults.standard.integer(forKey: "RubbishResidualWaste")
            return residual != 0 ? residual : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishResidualWaste") }
    }
    
    internal var organicWaste: Int? {
        get {
            let organic = UserDefaults.standard.integer(forKey: "RubbishOrganicWaste")
            return organic != 0 ? organic : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishOrganicWaste") }
    }
    
    internal var paperWaste: Int? {
        get {
            let paper = UserDefaults.standard.integer(forKey: "RubbishPaperWaste")
            return paper != 0 ? paper : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishPaperWaste") }
    }
    
    internal var yellowBag: Int? {
        get {
            let yellow = UserDefaults.standard.integer(forKey: "RubbishYellowBag")
            return yellow != 0 ? yellow : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishYellowBag") }
    }
    
    internal var greenWaste: Int? {
        get {
            let green = UserDefaults.standard.integer(forKey: "RubbishGreenWaste")
            return green != 0 ? green : nil
        }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishGreenWaste") }
    }
    
    internal var sweeperDay: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishSweeperDay") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishSweeperDay") }
    }
    
    // Helper
    
    private func rowToArray(_ string: String?) -> [Int] {
        
        let row = string ?? ""
        
        return row.components(separatedBy: ",").compactMap({ Int($0.trimmingCharacters(in: .whitespaces)) })
        
    }
    
}
