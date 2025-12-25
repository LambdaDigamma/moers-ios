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

public class TrackerManager: TrackerManagerProtocol {
    
    public static var shared = TrackerManager()
    
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
    
    // MARK: - API Interface
    
    public func getTrackers(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        
        let cachedTracker = self.loadTrackerCache()
        
        cachedTracker.sink { (comp: Subscribers.Completion<Error>) in
            
            switch comp {
                case .failure(let error):
                    return completion(.failure(error))
                default: break
            }
            
        } receiveValue: { (trackers: [Tracker]) in
            completion(.success(trackers))
        }
        .store(in: &cancellables)
        
        let networkTracker = self.loadTrackerNetwork()
        
        networkTracker.sink { (comp: Subscribers.Completion<Error>) in
            
            switch comp {
                case .failure(let error):
                    return completion(.failure(error))
                default: break
            }
            
        } receiveValue: { (tracker: [Tracker]) in
            completion(.success(tracker))
        }
        .store(in: &cancellables)
        
    }
    
    public func getTrackers() -> AnyPublisher<[Tracker], Error> {
        
        return Deferred {
            Future { promise in
                
                self.getTrackers(completion: { result in
                    switch result {
                        case .success(let trackers):
                            return promise(.success(trackers))
                        case .failure(let error):
                            return promise(.failure(error))
                    }
                })
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    // MARK: - Loading (Reactive)
    
    private func loadTrackerNetwork() -> AnyPublisher<[Tracker], Error> {
        
        return Deferred {
            Future { promise in
                
                do {
                    
                    _ = try self.loadTrackerNetwork(completion: { result in
                        switch result {
                            case .success(let trackers):
                                return promise(.success(trackers))
                            case .failure(let error):
                                return promise(.failure(error))
                        }
                    })
                    
                } catch {
                    return promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    private func loadTrackerCache() -> AnyPublisher<[Tracker], Error> {
        
        return Deferred {
            Future { promise in
                
                self.loadTrackerCache(completion: { result in
                    switch result {
                        case .success(let trackers):
                            return promise(.success(trackers))
                        case .failure(let error):
                            return promise(.failure(error))
                    }
                })
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    private func loadTrackerConfigNetwork() -> AnyPublisher<[Tracker], Error> {
        
        return Deferred {
            Future { promise in
                
                do {
                    _ = try self.loadTrackerConfigNetwork(completion: { result in
                        switch result {
                            case .success(let trackers):
                                return promise(.success(trackers))
                            case .failure(let error):
                                return promise(.failure(error))
                        }
                    })
                } catch {
                    return promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    // MARK: - Loading (Completion Handler)
    
    private func loadTrackerNetwork(completion: @escaping (Result<[Tracker], Error>) -> Void) throws -> URLSessionTask {
        
        guard let url = URL(string: loRaServer + "mapper-lite") else {
            throw APIError.unavailableURL
        }
        
        let task = self.session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            let result = self.decodeTrackingPoints(from: data)
            
            // Setup Temporary Tracker
            
            switch result {
                
            case .success(let trackingPoints):
                self.cachedTracker = self.convertTrackingPointsToTrackers(trackingPoints)
                completion(.success(self.cachedTracker))
                
            case .failure(let error):
                completion(.failure(error))
                
            }
            
            // Load Config for Tracker
            
            let trackerConfig = self.loadTrackerConfigNetwork()
            
            trackerConfig.sink { (comp: Subscribers.Completion<Error>) in
                
                switch comp {
                    case .failure(let error):
                        completion(.failure(error))
                    default: break
                }
                
            } receiveValue: { (trackers: [Tracker]) in
                
                var populatedTrackers: [Tracker] = []
                
                for tracker in trackers {
                    
                    if let trackerWithTrackingPoints = self.cachedTracker.first(where: { $0.deviceID ?? "1" == tracker.deviceID ?? "2" }) {
                        
                        var populatedTracker = tracker
                        populatedTracker.trackingPoints = trackerWithTrackingPoints.trackingPoints
                        
                        populatedTrackers.append(populatedTracker)
                        
                    }
                    
                }
                
                let encoder = JSONEncoder()
                
                do {
                    let data = try encoder.encode(populatedTrackers)
                    self.storageManager.write(data: data, forKey: self.keyTracker)
                } catch {
                    print(error.localizedDescription)
                }
                
                // TODO: Cache Everything here.
                
                completion(.success(populatedTrackers.filter { $0.isEnabled }))
                
            }
            .store(in: &self.cancellables)
            
        }
        
        task.resume()
        
        return task
        
    }
    
    private func loadTrackerCache(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        
        let trackers = storageManager.read(forKey: self.keyTracker, with: buildTrackerDecoder())
        
        trackers.sink { (comp: Subscribers.Completion<Error>) in
            
            switch comp {
                case .failure(let error):
                    completion(.failure(error))
                default: break
            }
            
        } receiveValue: { (tracker: [Tracker]) in
            completion(.success(tracker))
        }
        .store(in: &self.cancellables)
        
    }
    
    private func loadTrackerConfigNetwork(completion: @escaping (Result<[Tracker], Error>) -> Void) throws -> URLSessionTask {
        
        guard let url = URL(string: "https://archiv.moers-festival.de/" + "api/v2/tracker") else {
            throw APIError.unavailableURL
        }
        
        let task = self.session.dataTask(with: URLRequest(url: url)) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            self.lastUpdate = Date()
            
            // TODO: Cache Data Back
//            Shared.dataCache.set(value: data, key: self.keyTracker)
            
            let result = self.decodeTracker(from: data)
            
            completion(result)
            
        }
        
        task.resume()
        
        return task
        
    }
    
    // MARK: - Helper
    
    private func convertTrackingPointsToTrackers(_ trackingPoints: [TrackingPoint]) -> [Tracker] {
        
        let tracker01 = Tracker(name: "(1) \(String.localized("LoadingTracker"))",
            deviceID: TrackerDeviceID.tracker1.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker1.rawValue }
                .sorted(by: { $0.time < $1.time }))
        
        let tracker02 = Tracker(name: "(2) \(String.localized("LoadingTracker"))",
            deviceID: TrackerDeviceID.tracker2.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker2.rawValue }
                .sorted(by: { $0.time < $1.time }))
        
        let tracker03 = Tracker(name: "(3) \(String.localized("LoadingTracker"))",
            deviceID: TrackerDeviceID.tracker3.rawValue,
            trackingPoints: trackingPoints
                .filter { $0.deviceID == TrackerDeviceID.tracker3.rawValue }
                .sorted(by: { $0.time < $1.time }))
        
        let tracker04 = Tracker(name: "(4) \(String.localized("LoadingTracker"))",
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
    
    private func decodeTrackingPoints(from data: Data) -> Result<[TrackingPoint], Error> {
        
        let decoder = buildTrackingPointDecoder()
        
        do {
            
            let trackingPoints = try decoder.decode([TrackingPoint].self, from: data)
            
            return .success(trackingPoints)
            
        } catch {
            return .failure(error)
        }
        
        
    }
    
    private func decodeTracker(from data: Data) -> Result<[Tracker], Error> {
        
        let decoder = buildTrackerDecoder()
        
        do {
            
            let trackers = try decoder.decode([Tracker].self, from: data)
            
            return .success(trackers)
            
        } catch {
            return .failure(error)
        }
        
    }
    
}
