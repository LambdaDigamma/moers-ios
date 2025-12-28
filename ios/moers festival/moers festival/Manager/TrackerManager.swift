//
//  TrackerManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Reachability
import MMAPI
import Bond
import ReactiveKit
import Haneke

enum TrackerDeviceID: String {
    case tracker1 = "moers_festival_pax_counter_1"
    case tracker2 = "moers_festival_pax_counter_2"
    case tracker3 = "moers_festival_pax_counter_3"
    case tracker4 = "moers_festival_pax_counter_4"
}

class TrackerManager {
    
    static var shared = TrackerManager()
    
    private let reachability = Reachability()!
    private let bag = DisposeBag()
    private let session = URLSession.shared
    private let keyTracker = "tracker"
    private let loRaServer = "http://m090web3.krzn.de:1880/"
    private var cachedTracker: [Tracker] = []
    
    public var lastUpdate: Date? = nil
    
    // MARK: - API Interface
    
    public func getTrackers(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        
        let cachedTracker = self.loadTrackerCache()
        
        cachedTracker.observeNext { tracker in
            completion(.success(tracker))
        }.dispose(in: bag)
        
        if reachability.connection != .none {
                
            let networkTracker = self.loadTrackerNetwork()
            
            networkTracker.observeNext { trackers in
                completion(.success(trackers))
            }.dispose(in: bag)
            
            networkTracker.observeFailed { error in
                completion(.failure(error))
            }.dispose(in: bag)
            
        } else {
            completion(.failure(APIError.noConnection))
        }
        
    }
    
    public func getTrackers() -> Signal<[Tracker], Error> {
        
        return Signal { observer in
            
            self.getTrackers(completion: { result in
                switch result {
                case .success(let trackers):
                    observer.receive(trackers)
                case .failure(let error):
                    observer.receive(completion: .failure(error))
                }
            })
            
            return BlockDisposable {}
            
        }
        
    }
    
    // MARK: - Loading (Reactive)
    
    private func loadTrackerNetwork() -> Signal<[Tracker], Error> {
        
        return Signal { observer in
            
            do {
                let task = try self.loadTrackerNetwork(completion: { result in
                    switch result {
                    case .success(let trackers):
                        observer.receive(trackers)
                    case .failure(let error):
                        observer.receive(completion: .failure(error))
                    }
                })
                return BlockDisposable {
                    task.cancel()
                }
            } catch {
                observer.receive(completion: .failure(error))
            }
            
            return BlockDisposable {}
            
        }
        
    }
    
    private func loadTrackerCache() -> Signal<[Tracker], Error> {
        
        return Signal { observer in
            
            self.loadTrackerCache(completion: { result in
                switch result {
                case .success(let trackers):
                    observer.receive(trackers)
                case .failure(let error):
                    observer.receive(completion: .failure(error))
                }
            })
            
            return BlockDisposable {}
            
        }
        
    }
    
    private func loadTrackerConfigNetwork() -> Signal<[Tracker], Error> {
        
        return Signal { observer in
            
            do {
                let task = try self.loadTrackerConfigNetwork(completion: { result in
                    switch result {
                    case .success(let trackers):
                        observer.receive(trackers)
                    case .failure(let error):
                        observer.receive(completion: .failure(error))
                    }
                })
                return BlockDisposable {
                    task.cancel()
                }
            } catch {
                observer.receive(completion: .failure(error))
            }
            
            return BlockDisposable {}
            
        }
        
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
            
            trackerConfig.observeNext(with: { trackers in
                
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
                    Shared.dataCache.set(value: data, key: self.keyTracker)
                } catch {
                    print(error.localizedDescription)
                }
                
                // TODO: Cache Everything here.
                
                completion(.success(populatedTrackers.filter { $0.isEnabled }))
                
            }).dispose(in: self.bag)
            
            trackerConfig.observeFailed(with: { error in
                completion(.failure(error))
            }).dispose(in: self.bag)
            
        }
        
        task.resume()
        
        return task
        
    }
    
    private func loadTrackerCache(completion: @escaping (Result<[Tracker], Error>) -> Void) {
        
        let cache = Shared.dataCache
        
        cache.fetch(key: self.keyTracker)
            .onSuccess { data in
                
                let result = self.decodeTracker(from: data)
                
                completion(result)
                
            }
            .onFailure { error in
                completion(.success([]))
        }
        
    }
    
    private func loadTrackerConfigNetwork(completion: @escaping (Result<[Tracker], Error>) -> Void) throws -> URLSessionTask {
        
        guard let url = URL(string: MMAPIConfig.baseURL + "api/v2/tracker") else {
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
