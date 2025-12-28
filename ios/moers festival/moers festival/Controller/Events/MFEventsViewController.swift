//
//  MFEventsViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 31.01.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import Fuse
import Combine
import MMEvents
import Resolver
import UniformTypeIdentifiers

class MFEventsViewController: MMEvents.EventsViewController {

    public var coordinator: EventCoordinator?
    
    @LazyInjected var eventService: LegacyEventService
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveConfig), name: .DidReceiveRemoteConfig, object: nil)
        
        self.setupListeners()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadData()
        self.activateActivity()
        
        AnalyticsManager.shared.logOpenEventsOverview()
        
    }
    
    // MARK: - Private Methods
    
    internal override func loadData() {

        let networkEvents = eventService.loadEvents()
        
        networkEvents.sink { (completion: Subscribers.Completion<Error>) in
            print(completion)
        } receiveValue: { (events: [Event]) in
            
            self.events = events.map { EventViewModel(event: $0) }
            self.rebuildData()
            self.setupSearchableContent()

        }.store(in: &cancellables)
        
    }
    
    private func setupMockedEvents() -> [Event] {
        
        let event01 = Event(id: 1, name: "Event 1", startDate: Date(timeIntervalSinceNow: -29 * 60), endDate: nil)
        let event02 = Event(id: 2, name: "Event 2", startDate: Date(timeIntervalSinceNow: -1 * 60), endDate: Date(timeIntervalSinceNow: 2 * 60))
        let event03 = Event(id: 3, name: "Event 3", startDate: Date(timeIntervalSinceNow: 1 * 60), endDate: nil)
        let event04 = Event(id: 4, name: "Event 4", startDate: Date(timeIntervalSinceNow: 20 * 60), endDate: nil)
        let event05 = Event(id: 5, name: "Event 5", startDate: Date(timeIntervalSinceNow: 65 * 60), endDate: nil)
        
        let mockedEvents: [Event] = [event01, event02, event03, event04, event05]
        
        return mockedEvents
        
    }
        
    private func setupListeners() {
        
        NotificationCenter.default
            .publisher(for: .updatedEvents)
            .sink { (_: Notification) in
                self.loadData()
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - State Handling
    
    override func showEventDetailViewController(for event: EventViewModel<MMEvents.Event>) {
        
        self.coordinator?.pushEventDetail(eventID: event.model.id)
        
//        self.coordinator?.showEventDetailViewController(with: event.model)
        
    }
    
    override func showFavourites() {
        super.showFavourites()
        
        AnalyticsManager.shared.logOpenEventsFavourites()
        
    }
    
    @discardableResult
    override func showNext() -> EventsViewController {
        let eventViewController = super.showNext()
        
        AnalyticsManager.shared.logOpenEventsList()
        
        eventViewController.onShowEvent = { [weak self] (eventID, pageID) in
            
            guard let eventID = eventID else { return }
            
            self?.coordinator?.pushEventDetail(eventID: eventID)

        }
        
        return eventViewController
    }
    
    @objc func didReceiveConfig() {
        
        self.numberOfDisplayedUpcomingEvents = ConfigManager.shared.numberOfDisplayedUpcomingEvents
        
        self.rebuildData()
        
    }
    
    override func filterUpcoming(events: [EventViewModel<Event>]) -> [EventViewModel<Event>] {
        
        return events.filter { (event: EventViewModel<Event>) in
            if let startDate = event.model.startDate {
                return startDate > Date()
            }
            return false
        }
        
    }
    
}

extension MFEventsViewController {
    
    private func activateActivity() {
        
        let activity = NSUserActivity(activityType: "de.okfn.niederrhein.moers-festival.openNextEvents")
        
        let title = String.localized("ShowNextEvents")
        
        activity.title = title
        activity.isEligibleForSearch = true
        activity.keywords = [String.localized("EventKeyword"), String.localized("MFKeyword")]
        
        if #available(iOS 12.0, *) {
            activity.isEligibleForPrediction = true
        }
        
        userActivity = activity
        userActivity!.becomeCurrent()
        
    }
    
    private func setupSearchableContent() {
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            var searchableItems: [CSSearchableItem] = []
            
            for viewModel in self.events {
                
                let event = viewModel.model
                
                let searchableItemAttributeSet = CSSearchableItemAttributeSet(
                    itemContentType: UTType.text.identifier
                )
                
                searchableItemAttributeSet.title = event.name
                searchableItemAttributeSet.contentDescription = event.description
//                searchableItemAttributeSet.namedLocation = event.getLocation()?.name ?? String.localized("VenueUnknown") // TODO:
//                searchableItemAttributeSet.city = event.getLocation()?.place ?? String.localized("CityUnknown") // TODO:
                searchableItemAttributeSet.endDate = event.endDate
                searchableItemAttributeSet.startDate = event.startDate
                searchableItemAttributeSet.keywords = event.name.components(separatedBy: " ") + (event.description ?? "").components(separatedBy: " ")
                
                if let url = event.image {
                    if let data = try? Data(contentsOf: url) {
                        searchableItemAttributeSet.thumbnailData = data
                    }
                }
                
                let searchableItem = CSSearchableItem(uniqueIdentifier: "de.okfn.niederrhein.moers-festival.events.\(event.id)",
                    domainIdentifier: "events",
                    attributeSet: searchableItemAttributeSet)
                
                searchableItems.append(searchableItem)
                
            }
            
            
            CSSearchableIndex.default().deleteAllSearchableItems { (error) in
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
            }
            
        }
        
    }
    
}
