//
//  UpcomingWidgetIntent.swift
//  
//
//  Created by Lennart Fischer on 05.04.26.
//


import AppIntents

@available(iOSApplicationExtension 17.0, *)
struct UpcomingWidgetIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Upcoming Events"
    static let description = IntentDescription("Shows live and upcoming events, optionally filtered by venues.")

    @Parameter(title: "Venues")
    var venues: [VenueEntity]?

    init() {
        self.venues = nil
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Upcoming events")
    }

}
