//
//  RubbishCollectionProvider.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import WidgetKit
import RubbishFeature
import UserNotifications
import Resolver
import Combine

class RubbishCollectionProvider: TimelineProvider {
    
    typealias Entry = RubbishCollectionEntry
    
    private let rubbishService: RubbishService
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        
        NetworkingConfiguration().executeInExtension()
        ServiceConfiguration().executeInExtension()
        
        self.rubbishService = Resolver.resolve()
    }
    
    func placeholder(in context: Context) -> RubbishCollectionEntry {
        return placeholderEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RubbishCollectionEntry) -> Void) {
        completion(placeholderEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RubbishCollectionEntry>) -> Void) {
        
        let startOfNextDay = Calendar.autoupdatingCurrent.startOfDay(
            for: Date(timeIntervalSinceNow: 60 * 60 * 24)
        )
        
        if let street = rubbishService.rubbishStreet {
            
            rubbishService.loadRubbishPickupItems(for: street)
                .sink { (completion: Subscribers.Completion<RubbishLoadingError>) in
                    
                    switch completion {
                        case .failure(let error):
                            print(error)
                        default: break
                    }
                    
                } receiveValue: { (items: [RubbishPickupItem]) in
                    
                    let entry = RubbishCollectionEntry(date: Date(), rubbishPickupItems: items)
                    
                    completion(.init(entries: [entry], policy: .after(startOfNextDay)))
                    
                }
                .store(in: &cancellables)
            
        } else {
            
            completion(.init(entries: [], policy: .after(startOfNextDay)))
            
        }
        
    }
    
    func placeholderEntry() -> RubbishCollectionEntry {
        
        return RubbishCollectionEntry(
            date: Date(),
            streetName: "Musterstraße",
            rubbishPickupItems: RubbishPickupItem.placeholder
        )
        
    }
    
}
