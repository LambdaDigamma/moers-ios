//
//  MMEventsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.06.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import MMEvents
import Combine
import OSLog

class MMEventsViewController: EventsViewController {

    private var cancellables = Set<AnyCancellable>()
    public var coordinator: EventCoordinator?
    private let logger = Logger(subsystem: subsystem, category: "MMEventsViewController")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.numberOfDisplayedUpcomingEvents = 15
        self.sectionUpcomingTitle = String.localized("Upcoming").uppercased()
        self.sectionActiveTitle = String.localized("ActiveEventsHeadline").uppercased()
        
    }
    
    override func loadData() {
        
        guard let eventService = coordinator?.eventService else { return }
        
        let eventObserver = eventService.loadEvents()
        
        eventObserver.sink { [weak self] completion in
            
            switch completion {
                case .failure(let error):
                    
                    self?.logger.error("Error while loading: \(error.localizedDescription)")
                    
                default:
                    break
            }
            
        } receiveValue: { events in
            
            self.events = events.map({ event in
                return EventViewModel<MMEvents.Event>(event: event)
            })
            
            self.rebuildData()
            
        }.store(in: &cancellables)
        
    }
    
    override func filterActive(events: [EventViewModel<Event>]) -> [EventViewModel<Event>] {
        return events.filter { (event) -> Bool in
            return isActive(event: event)
        }
    }
    
    override func filterUpcoming(events: [EventViewModel<Event>]) -> [EventViewModel<Event>] {
        
        return events.filter({ !$0.isLongEvent }).filter { (event) -> Bool in
            return !isActive(event: event)
        }
        
    }
    
    override func showEventDetailViewController(for event: EventViewModel<Event>) {
        
//        let viewModel = EventDetailsViewModel(model: event.model)
//        let detailViewController = MMUI.EventDetailViewController(viewModel: viewModel)
//
//        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }
    
    private func isActive(event: EventViewModel<Event>) -> Bool {
        
        if let startDate = event.model.startDate {
            return startDate.isToday
        } else if let startDate = event.model.startDate, let endDate = event.model.endDate {
            return (startDate...endDate).contains(Date())
        } else if event.model.startDate == nil {
            return false
        } else {
            return false
        }
        
    }
    
}
