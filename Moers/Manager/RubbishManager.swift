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
    
    private let rubbishStreetURL = URL(string: "https://meinmoers.lambdadigamma.com/abfallkalender-strassenverzeichnis.csv")
    private let rubbishDateURL = URL(string: "https://www.offenesdatenportal.de/dataset/fe92e461-9db4-4d12-ba58-8d4439084e90/resource/04c58f79-e903-46d4-afc9-d546f4474543/download/abfallkalender--abfuhrtermine-2018.csv")
    private var requests: [UNNotificationRequest] = []
    
    public func loadRubbishCollectionStreets(completion: @escaping ([RubbishCollectionStreet]) -> Void) {
        
        if let url = rubbishStreetURL {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
                
                let csv = CSwiftV(with: content, separator: ";", headers: ["Straße", "Restabfall", "Biotonne", "Papiertonne", "Gelber Sack", "Grünschnitt", "Kehrtag"])
                
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
                
                completion(streets)
                
            } catch let err as NSError {
                print(err.localizedDescription)
            }
            
        }
        
    }
    
    public func loadRubbishCollectionDate(completion: @escaping ([RubbishCollectionDate]) -> Void) {
        
        if let url = rubbishDateURL {
            
            do {
                
                let content = try String(contentsOf: url, encoding: String.Encoding.ascii)
                
                let csv = CSwiftV(with: content, separator: ";", headers: ["id", "datum", "rest_woche", "restabfall", "biotonne", "papiertonne", "gelber_sack", "gruenschnitt", "schadstoff", "del"])
                
                var dates: [RubbishCollectionDate] = []
                
                var rows = csv.keyedRows!
                rows.remove(at: 0)
                
                for row in rows {
                    
                    let date = RubbishCollectionDate(id: Int(row["id"] ?? "")!,
                                                     date: row["datum"] ?? "",
                                                     residualWaste: Int(row["restabfall"] ?? ""),
                                                     organicWaste: Int(row["biotonne"] ?? ""),
                                                     paperWaste: Int(row["papiertonne"] ?? ""),
                                                     yellowBag: Int(row["gelber_sack"] ?? ""),
                                                     greenWaste: Int(row["gruenschnitt"] ?? ""))
                    
                    dates.append(date)
                    
                }
                
                completion(dates)
                
            } catch let err {
                print(err.localizedDescription)
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
            
            let residual = dates.filter { $0.residualWaste == self.residualWaste && $0.residualWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .residual) }
            let organic = dates.filter { $0.organicWaste == self.organicWaste && $0.organicWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .organic) }
            let paper = dates.filter { $0.paperWaste == self.paperWaste && $0.paperWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .paper) }
            let yellow = dates.filter { $0.yellowBag == self.yellowBag && $0.yellowBag != nil }.map { RubbishCollectionItem(date: $0.date, type: .yellow) }
            let green = dates.filter { $0.greenWaste == self.greenWaste && $0.greenWaste != nil }.map { RubbishCollectionItem(date: $0.date, type: .green) }
            
            var items = residual + organic + paper + yellow + green
            
            items.sort(by: { $0.parsedDate < $1.parsedDate })
            
            if !all {
                
                let today = Date()
                
                let futureItems = items.filter { $0.parsedDate > today || $0.parsedDate.isToday }
                
                completion(futureItems)
                
            } else {
                completion(items)
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
        
        self.invalidateRubbishReminderNotifications()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            self.loadItems(completion: { (items) in
                
                // Build Rubbish Collection Notification Requests
                
                for item in items {
                
                    let notificationContent = UNMutableNotificationContent()
                    
                    notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
                    notificationContent.title = String.localized("RubbishCollectionNotificationTitle")
                    notificationContent.body = String.localized("RubbishCollectionNotificationBody") + RubbishWasteType.localizedForCase(item.type)
                    
                    let date = item.parsedDate
                        
                    let calendar = Calendar.current
                    
                    var dateComponents = DateComponents()
                    
                    dateComponents.day = calendar.component(.day, from: date) - 1
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
    
    public var isEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "RubbishEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishEnabled") }
    }
    
    public var reminderHour: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishReminderHour") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishReminderHour") }
    }
    
    public var reminderMinute: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishReminderMinute") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishReminderMinute") }
    }
    
    public var remindersEnabled: Bool? {
        get { return UserDefaults.standard.bool(forKey: "RubbishRemindersEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishRemindersEnabled") }
    }
    
    private var street: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishStreet") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishStreet") }
    }
    
    private var residualWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishResidualWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishResidualWaste") }
    }
    
    private var organicWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishOrganicWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishOrganicWaste") }
    }
    
    private var paperWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishPaperWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishPaperWaste") }
    }
    
    private var yellowBag: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishYellowBag") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishYellowBag") }
    }
    
    private var greenWaste: Int? {
        get { return UserDefaults.standard.integer(forKey: "RubbishGreenWaste") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishGreenWaste") }
    }
    
    private var sweeperDay: String? {
        get { return UserDefaults.standard.string(forKey: "RubbishSweeperDay") }
        set { UserDefaults.standard.set(newValue, forKey: "RubbishSweeperDay") }
    }
    
}
