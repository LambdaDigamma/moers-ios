//
//  TrackerManager.swift
//  MMAPI
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Combine

public enum TrackerDeviceID: String {
    case tracker1 = "moers_festival_pax_counter_1"
    case tracker2 = "moers_festival_pax_counter_2"
    case tracker3 = "moers_festival_pax_counter_3"
    case tracker4 = "moers_festival_pax_counter_4"
}

public protocol TrackerManagerProtocol {

    func getTrackers(completion: @escaping (Result<[Tracker], Error>) -> Void)

    func getTrackers() -> AnyPublisher<[Tracker], Error>

}

@MainActor
public class TrackerManager: TrackerManagerProtocol {

    public static let shared = TrackerManager()

    private let session = URLSession.shared
    private let keyTracker = "tracker"
    private let loRaServer = "http://m090web3.krzn.de:1880/"
    private var cachedTracker: [Tracker] = []
    private var cancellables = Set<AnyCancellable>()

    private let storageManager: AnyStoragable<Tracker>

    public init(storageManager: AnyStoragable<Tracker> = NoCache()) {
        self.storageManager = storageManager
    }

    public var lastUpdate: Date? = nil

    // MARK: - TrackerManagerProtocol

    public func getTrackers(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        loadCachedTrackers { result in completion(result) }
        Task {
            do {
                completion(.success(try await loadTrackersFromNetwork()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func getTrackers() -> AnyPublisher<[Tracker], Error> {
        Future { [weak self] promise in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    promise(.success(try await self.loadTrackersFromNetwork()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Async Loading

    private func loadTrackersFromNetwork() async throws -> [Tracker] {
        guard let trackingPointsURL = URL(string: loRaServer + "mapper-lite") else {
            throw APIError.unavailableURL
        }
        let (trackingPointsData, _) = try await session.data(from: trackingPointsURL)
        let trackingPoints = try buildTrackingPointDecoder().decode([TrackingPoint].self, from: trackingPointsData)
        cachedTracker = convertTrackingPointsToTrackers(trackingPoints)

        guard let configURL = URL(string: "https://moers.app/api/v2/tracker") else {
            throw APIError.unavailableURL
        }
        let (configData, _) = try await session.data(from: configURL)
        let configTrackers = try buildTrackerDecoder().decode([Tracker].self, from: configData)

        lastUpdate = Date()

        var populatedTrackers: [Tracker] = []
        for tracker in configTrackers {
            if let match = cachedTracker.first(where: { $0.deviceID ?? "1" == tracker.deviceID ?? "2" }) {
                var populated = tracker
                populated.trackingPoints = match.trackingPoints
                populatedTrackers.append(populated)
            }
        }

        if let encoded = try? JSONEncoder().encode(populatedTrackers) {
            storageManager.write(data: encoded, forKey: keyTracker)
        }

        return populatedTrackers.filter { $0.isEnabled }
    }

    // MARK: - Cache

    private func loadCachedTrackers(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        storageManager.read(forKey: keyTracker, with: buildTrackerDecoder())
            .sink { comp in
                if case .failure(let error) = comp { completion(.failure(error)) }
            } receiveValue: { trackers in
                completion(.success(trackers))
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers

    private func convertTrackingPointsToTrackers(_ trackingPoints: [TrackingPoint]) -> [Tracker] {

        let tracker01 = Tracker(name: "(1) \(String(localized: "Loading tracker...", bundle: .module))",
            deviceID: TrackerDeviceID.tracker1.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker1.rawValue }
                .sorted(by: { $0.time < $1.time }))

        let tracker02 = Tracker(name: "(2) \(String(localized: "Loading tracker...", bundle: .module))",
            deviceID: TrackerDeviceID.tracker2.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker2.rawValue }
                .sorted(by: { $0.time < $1.time }))

        let tracker03 = Tracker(name: "(3) \(String(localized: "Loading tracker...", bundle: .module))",
            deviceID: TrackerDeviceID.tracker3.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker3.rawValue }
                .sorted(by: { $0.time < $1.time }))

        let tracker04 = Tracker(name: "(4) \(String(localized: "Loading tracker...", bundle: .module))",
            deviceID: TrackerDeviceID.tracker4.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker4.rawValue }
                .sorted(by: { $0.time < $1.time }))

        return [tracker01, tracker02, tracker03, tracker04]

    }

    private func buildTrackingPointDecoder() -> JSONDecoder {

        let decoder = JSONDecoder()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        decoder.dateDecodingStrategy = .formatted(formatter)

        return decoder

    }

    private func buildTrackerDecoder() -> JSONDecoder {

        let decoder = JSONDecoder()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"

        decoder.dateDecodingStrategy = .formatted(formatter)

        return decoder

    }

}
