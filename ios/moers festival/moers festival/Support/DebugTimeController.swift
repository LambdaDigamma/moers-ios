//
//  DebugTimeController.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import Combine
import Core
import Factory
import Foundation
import MMEvents

nonisolated final class DebugTimeController: ObservableObject, CurrentDateProviding, @unchecked Sendable {
    
    private static let baseDateKey = "debugTime.baseDate"
    private static let anchorRealDateKey = "debugTime.anchorRealDate"
    private static let speedMultiplierKey = "debugTime.speedMultiplier"
    
    private let lock = NSRecursiveLock()
    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<Date, Never>
    
    private var baseDateValue: Date
    private var anchorRealDateValue: Date
    private var speedMultiplierValue: Double
    private var checkpointsValue: [DebugTimeCheckpoint] = []
    
    private var timerCancellable: AnyCancellable?
    private var eventCancellable: AnyCancellable?
    
    var now: Date {
        lock.lock()
        defer { lock.unlock() }
        
        let elapsedRealTime = Date().timeIntervalSince(anchorRealDateValue)
        return baseDateValue.addingTimeInterval(elapsedRealTime * speedMultiplierValue)
    }
    
    var dateDidChange: AnyPublisher<Date, Never> {
        subject.eraseToAnyPublisher()
    }
    
    var speedMultiplier: Double {
        lock.lock()
        defer { lock.unlock() }
        
        return speedMultiplierValue
    }
    
    var selectedSpeedPreset: DebugTimeSpeedPreset {
        get {
            DebugTimeSpeedPreset.closest(to: speedMultiplier)
        }
        set {
            setSpeedMultiplier(newValue.rawValue)
        }
    }
    
    var checkpoints: [DebugTimeCheckpoint] {
        lock.lock()
        defer { lock.unlock() }
        
        return checkpointsValue
    }
    
    init(
        userDefaults: UserDefaults = .standard,
        arguments: [String] = CommandLine.arguments,
        observesEvents: Bool = true
    ) {
        let realNow = Date()
        
        self.userDefaults = userDefaults
        self.baseDateValue = realNow
        self.anchorRealDateValue = realNow
        self.speedMultiplierValue = DebugTimeSpeedPreset.realtime.rawValue
        self.subject = CurrentValueSubject(realNow)
        
        restorePersistedState()
        applyLaunchArguments(arguments)
        configureTicker()
        
        if observesEvents {
            observeFestivalEvents()
        }
        
        publishCurrentDate()
    }
    
    func setDate(_ date: Date) {
        lock.lock()
        baseDateValue = date
        anchorRealDateValue = Date()
        lock.unlock()
        
        persistState()
        publishCurrentDate()
    }
    
    func setSpeedMultiplier(_ multiplier: Double) {
        let normalizedMultiplier = max(0, multiplier)
        let currentDate = now
        
        lock.lock()
        baseDateValue = currentDate
        anchorRealDateValue = Date()
        speedMultiplierValue = normalizedMultiplier
        lock.unlock()
        
        persistState()
        configureTicker()
        publishCurrentDate()
    }
    
    func step(by interval: TimeInterval) {
        setDate(now.addingTimeInterval(interval))
    }
    
    func resetToRealTime() {
        let realNow = Date()
        
        lock.lock()
        baseDateValue = realNow
        anchorRealDateValue = realNow
        speedMultiplierValue = DebugTimeSpeedPreset.realtime.rawValue
        lock.unlock()
        
        clearPersistedState()
        configureTicker()
        publishCurrentDate()
    }
    
    private func restorePersistedState() {
        guard let baseDate = persistedDate(forKey: Self.baseDateKey),
              let anchorRealDate = persistedDate(forKey: Self.anchorRealDateKey) else {
            return
        }
        
        lock.lock()
        baseDateValue = baseDate
        anchorRealDateValue = anchorRealDate
        speedMultiplierValue = userDefaults.object(forKey: Self.speedMultiplierKey) as? Double
            ?? DebugTimeSpeedPreset.realtime.rawValue
        lock.unlock()
    }
    
    private func applyLaunchArguments(_ arguments: [String]) {
        if arguments.contains("-debug-time-reset") {
            resetToRealTime()
        }
        
        if let dateString = value(after: "-debug-time", in: arguments),
           let date = Self.parseLaunchDate(dateString) {
            setDate(date)
        }
        
        if let speedString = value(after: "-debug-time-speed", in: arguments),
           let multiplier = Double(speedString) {
            setSpeedMultiplier(multiplier)
        }
    }
    
    private func value(after flag: String, in arguments: [String]) -> String? {
        guard let flagIndex = arguments.firstIndex(of: flag) else { return nil }
        let valueIndex = arguments.index(after: flagIndex)
        guard arguments.indices.contains(valueIndex) else { return nil }
        
        return arguments[valueIndex]
    }
    
    private static func parseLaunchDate(_ string: String) -> Date? {
        let fractionalFormatter = ISO8601DateFormatter()
        fractionalFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = fractionalFormatter.date(from: string) {
            return date
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
    
    private func configureTicker() {
        timerCancellable?.cancel()
        
        guard speedMultiplier > 0 else { return }
        
        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.publishCurrentDate()
            }
    }
    
    private func observeFestivalEvents() {
        let repository = Container.shared.eventRepository()
        
        eventCancellable = repository
            .events()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] events in
                self?.updateCheckpoints(from: events)
            }
    }
    
    private func updateCheckpoints(from events: [MMEvents.Event]) {
        let datedEvents = events
            .filter { $0.startDate != nil }
            .sorted { ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture) }
        
        var checkpoints: [DebugTimeCheckpoint] = []
        
        if let firstEventDate = datedEvents.first?.startDate {
            checkpoints.append(DebugTimeCheckpoint(title: "Festival Start", date: firstEventDate))
            checkpoints.append(DebugTimeCheckpoint(title: "First Live", date: firstEventDate))
        }
        
        if let nextEventDate = datedEvents
            .compactMap(\.startDate)
            .first(where: { $0 > now }) {
            checkpoints.append(DebugTimeCheckpoint(title: "Next Event", date: nextEventDate))
        }
        
        if let lateNightEventDate = datedEvents
            .compactMap(\.startDate)
            .first(where: { date in
                let hour = Calendar.autoupdatingCurrent.component(.hour, from: date)
                return hour >= 22 || hour < 6
            }) {
            checkpoints.append(DebugTimeCheckpoint(title: "Late Night", date: lateNightEventDate))
        }
        
        if let finalEventDate = datedEvents
            .compactMap({ $0.endDate ?? $0.startDate })
            .max() {
            checkpoints.append(DebugTimeCheckpoint(title: "Final Event", date: finalEventDate))
        }
        
        lock.lock()
        checkpointsValue = checkpoints
        lock.unlock()
        
        publishObjectChange()
    }
    
    private func persistState() {
        lock.lock()
        let baseDate = baseDateValue
        let anchorRealDate = anchorRealDateValue
        let speedMultiplier = speedMultiplierValue
        lock.unlock()
        
        userDefaults.set(baseDate.timeIntervalSince1970, forKey: Self.baseDateKey)
        userDefaults.set(anchorRealDate.timeIntervalSince1970, forKey: Self.anchorRealDateKey)
        userDefaults.set(speedMultiplier, forKey: Self.speedMultiplierKey)
    }
    
    private func clearPersistedState() {
        userDefaults.removeObject(forKey: Self.baseDateKey)
        userDefaults.removeObject(forKey: Self.anchorRealDateKey)
        userDefaults.removeObject(forKey: Self.speedMultiplierKey)
    }
    
    private func persistedDate(forKey key: String) -> Date? {
        guard userDefaults.object(forKey: key) != nil else { return nil }
        
        return Date(timeIntervalSince1970: userDefaults.double(forKey: key))
    }
    
    private func publishCurrentDate() {
        subject.send(now)
        publishObjectChange()
    }
    
    private func publishObjectChange() {
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
}

#endif
