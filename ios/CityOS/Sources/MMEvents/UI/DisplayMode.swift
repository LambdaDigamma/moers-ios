//
//  DisplayMode.swift
//  MMEvents
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

public enum DisplayMode {
    
    case overview(favouriteEvents: [EventViewModel<Event>],
                  activeEvents: [EventViewModel<Event>],
                  upcomingEvents: [EventViewModel<Event>])
    case list(keyedEvents: [(header: String, events: [EventViewModel<Event>])])
    case search(searchTerm: String, searchedEvents: [(header: String, events: [EventViewModel<Event>])])
    case favourites(keyedEvents: [(header: String, events: [EventViewModel<Event>])])
    case filter(filteredEvents: [EventViewModel<Event>])
    
}
