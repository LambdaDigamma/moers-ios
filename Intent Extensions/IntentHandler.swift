//
//  IntentHandler.swift
//  Intent Extensions
//
//  Created by Lennart Fischer on 12.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Intents
import ModernNetworking
import EFAAPI
import Combine

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

class IntentHandler: INExtension, SelectDepartureMonitorStopIntentHandling {
    
    private let transitService: TransitService
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        
        let serverEnvironment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "vrr")
        let serverEnvironmentLoader = ApplyEnvironmentLoader(environment: serverEnvironment)
        let loader = URLSessionLoader()
        self.transitService = DefaultTransitService(loader: (serverEnvironmentLoader --> loader)!)
        
        super.init()
        
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    func resolveTransitStation(
        for intent: SelectDepartureMonitorStopIntent,
        with completion: @escaping (TransitStationResolutionResult) -> Void
    ) {
        
        guard let transitStation = intent.transitStation else {
            completion(.confirmationRequired(with: nil))
            return
        }
        
        completion(TransitStationResolutionResult.success(with: transitStation))
        
    }
    
    func provideTransitStationOptionsCollection(
        for intent: SelectDepartureMonitorStopIntent,
        searchTerm: String?,
        with completion: @escaping (INObjectCollection<TransitStation>?, Error?) -> Void
    ) {
        
        guard let searchTerm = searchTerm else {
            completion(nil, nil)
            return
        }
        
        transitService
            .findTransitLocation(for: searchTerm, filtering: [.stops])
            .sink { (serviceCompletion: Subscribers.Completion<HTTPError>) in
                
                switch serviceCompletion {
                    case .failure(let error):
                        completion(nil, error)
                    default: break
                }
                
            } receiveValue: { (locations: [TransitLocation]) in
                
                let stations = locations.map({ TransitStation(identifier: $0.name, display: $0.name) })
                let collection = INObjectCollection(items: stations)
                
                completion(collection, nil)
                
            }
            .store(in: &cancellables)
        
    }
    
}
