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
    
    var isFavoritesFilterEnabled: Bool = true
    
    @State private var venues: [Place] = []
    
    private let repository: PlaceRepository = Container.shared.placeRepository()
    
    public init(filter: Binding<EventFilter>, isFavoritesFilterEnabled: Bool = true) {
        self._filter = filter
        self.isFavoritesFilterEnabled = isFavoritesFilterEnabled
    }
    
    public var body: some View {
        NavigationView {
            List {
                
                if isFavoritesFilterEnabled {
                    Section(header: Text(EventPackageStrings.favoritesSection)) {
                        Toggle(EventPackageStrings.showOnlyFavorites, isOn: $filter.showOnlyFavorites)
                    }
                }
                
                Section(header: Text(EventPackageStrings.venuesSection)) {
                    
                    HStack {
                        Button(EventPackageStrings.selectAll) {
                            filter.venueIDs = Set(venues.map { $0.id })
                        }
                        .buttonStyle(.borderless)
                        
                        Spacer()
                        
                        Button(EventPackageStrings.deselectAll) {
                            filter.venueIDs = []
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                    
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
