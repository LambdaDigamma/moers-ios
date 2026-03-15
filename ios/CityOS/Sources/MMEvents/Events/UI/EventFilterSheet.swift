//
//  EventFilterSheet.swift
//  
//
//  Created by Gemini CLI on 15.03.26.
//

import SwiftUI
import Factory

public struct EventFilterSheet: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var filter: EventFilter
    
    @State private var venues: [Place] = []
    
    private let repository: PlaceRepository = Container.shared.placeRepository()
    
    public init(filter: Binding<EventFilter>) {
        self._filter = filter
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text(EventPackageStrings.venuesSection)) {
                    ForEach(venues, id: \.id) { venue in
                        Button(action: {
                            if filter.venueIDs.contains(venue.id) {
                                filter.venueIDs.remove(venue.id)
                            } else {
                                filter.venueIDs.insert(venue.id)
                            }
                        }) {
                            HStack {
                                Text(venue.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if filter.venueIDs.contains(venue.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(EventPackageStrings.filter)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(EventPackageStrings.done) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(EventPackageStrings.reset) {
                        filter = EventFilter()
                    }
                }
            }
            .task {
                do {
                    let allVenues = try await repository.fetch()
                    self.venues = allVenues.sorted(by: { $0.name < $1.name })
                } catch {
                    print("Failed to fetch venues: \(error)")
                }
            }
        }
    }
    
}
