//
//  VenueDetailViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import MMEvents
import Factory
import Combine
import MapKit
import CoreLocation

public class VenueDetailViewModel: StandardViewModel {
    
    private let placeID: Place.ID
    
    @Published var name: String
    @Published var subtitle: String
    
    @Published var addressLine1: String?
    @Published var addressLine2: String?
    
    @Published var point: Point?
    
    @Published var pageID: Page.ID?
    
    @Published var mapItem: MKMapItem?
    
    @Published var events: [EventListItemViewModel] = [
        Event.stub(withID: 3)
            .setting(\.name, to: "Gamo Singers + tba (ET, DE)")
            .setting(\.startDate, to: Date(timeIntervalSinceNow: -25 * 60))
            .setting(\.endDate, to: Date(timeIntervalSinceNow: 25 * 60))
            .setting(\.place, to: Place.stub(withID: 1)),
        Event
            .stub(withID: 1)
            .setting(\.name, to: "ANNEX 4")
            .setting(\.startDate, to: .init(timeIntervalSinceNow: 60 * 5)),
        Event
            .stub(withID: 2)
            .setting(\.name, to: "Kasper Agnas (SE)")
            .setting(\.startDate, to: .init(timeIntervalSinceNow: 60 * 65)),
        Event.stub(withID: 4),
    ].map { (event: Event) in
        return EventListItemViewModel(
            title: event.name,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.place?.name,
            scheduleDisplayMode: event.scheduleDisplayMode
        )
    }
    
    private let eventRepository: EventRepository
    private var enrichmentTask: Task<Void, Never>?
    private var enrichmentSignature: String?
    
    public init(placeID: Place.ID) {
        self.placeID = placeID
        self.name = ""
        self.subtitle = ""
        self.eventRepository = Container.shared.eventRepository()
        super.init()
        self.setupListener()
    }
    
    deinit {
        enrichmentTask?.cancel()
    }
    
    public func setupListener() {
        
        eventRepository.store
            .observeEvents(for: self.placeID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (events: [EventRecord]) in
                
                self.events = events
                    .map { $0.toBase() }
                    .map({ (event: Event) in
                        return EventListItemViewModel(
                            eventID: event.id,
                        title: event.name,
                        startDate: event.startDate,
                        endDate: event.endDate,
                        location: event.place?.name,
                        media: event.mediaCollections.getFirstMedia(for: "header"),
                        isOpenEnd: event.extras?.openEnd ?? false,
                        scheduleDisplayMode: event.scheduleDisplayMode
                    )
                })
                
            }
            .store(in: &cancellables)
        
    }
    
    func refreshMapKitEnrichment() {
        
        guard let point, point.latitude != 0, point.longitude != 0 else {
            mapItem = nil
            enrichmentSignature = nil
            enrichmentTask?.cancel()
            return
        }
        
        let venueName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let addressLine1 = addressLine1?.trimmingCharacters(in: .whitespacesAndNewlines)
        let addressLine2 = addressLine2?.trimmingCharacters(in: .whitespacesAndNewlines)
        let signature = [
            venueName,
            addressLine1 ?? "",
            addressLine2 ?? "",
            "\(point.latitude)",
            "\(point.longitude)"
        ].joined(separator: "|")
        
        guard signature != enrichmentSignature else { return }
        
        enrichmentSignature = signature
        enrichmentTask?.cancel()
        
        let coordinate = point.toCoordinate()
        
        enrichmentTask = Task { [weak self] in
            let mapItem = await Self.resolveMapItem(
                venueName: venueName,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                coordinate: coordinate
            )
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                guard let self else { return }
                self.mapItem = mapItem
            }
        }
        
    }
    
    private static func resolveMapItem(
        venueName: String,
        addressLine1: String?,
        addressLine2: String?,
        coordinate: CLLocationCoordinate2D
    ) async -> MKMapItem? {
        
        let query = [
            venueName,
            addressLine1,
            addressLine2
        ]
        .compactMap { $0?.nilIfEmpty }
        .joined(separator: ", ")
        
        guard !query.isEmpty else { return nil }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 600,
            longitudinalMeters: 600
        )
        
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems.max { lhs, rhs in
                score(for: lhs, venueName: venueName, coordinate: coordinate) <
                score(for: rhs, venueName: venueName, coordinate: coordinate)
            }
        } catch {
            return nil
        }
        
    }
    
    private static func score(
        for mapItem: MKMapItem,
        venueName: String,
        coordinate: CLLocationCoordinate2D
    ) -> Double {
        
        let normalizedVenueName = venueName.normalizedForVenueLookup
        let normalizedCandidateName = (mapItem.name ?? "").normalizedForVenueLookup
        
        var score: Double = 0
        
        if normalizedCandidateName == normalizedVenueName {
            score += 200
        } else if normalizedCandidateName.contains(normalizedVenueName) || normalizedVenueName.contains(normalizedCandidateName) {
            score += 120
        }
        
        let venueLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let candidateLocation = CLLocation(
            latitude: mapItem.placemark.coordinate.latitude,
            longitude: mapItem.placemark.coordinate.longitude
        )
        
        let distancePenalty = venueLocation.distance(from: candidateLocation) / 10
        
        return score - distancePenalty
    }
    
}

private extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        guard let value = self?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        
        return value
    }
}

private extension String {
    var normalizedForVenueLookup: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .replacingOccurrences(of: "[^a-z0-9]+", with: "", options: .regularExpression)
    }
}
