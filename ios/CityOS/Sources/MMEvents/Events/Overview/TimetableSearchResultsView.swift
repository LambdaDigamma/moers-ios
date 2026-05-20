//
//  TimetableSearchResultsView.swift
//
//
//  Created by Lennart Fischer on 19.05.26.
//

import SwiftUI

struct TimetableSearchResultsView: View {

    let query: String
    let sections: [EventListSection]
    let state: TimetableSearchState
    let onSelectEvent: (Event.ID) -> Void
    let onRetrySearch: () -> Void

    init(
        query: String,
        sections: [EventListSection],
        state: TimetableSearchState,
        onSelectEvent: @escaping (Event.ID) -> Void = { _ in },
        onRetrySearch: @escaping () -> Void = {}
    ) {
        self.query = query
        self.sections = sections
        self.state = state
        self.onSelectEvent = onSelectEvent
        self.onRetrySearch = onRetrySearch
    }

    var body: some View {

        Group {

            if state == .loading && sections.isEmpty {
                ProgressView()
                    .accessibilityLabel(EventPackageStrings.searchingEvents)
            } else if state == .failed {
                placeholder(
                    systemImage: "exclamationmark.triangle",
                    text: EventPackageStrings.searchFailed,
                    buttonTitle: EventPackageStrings.retrySearch,
                    action: onRetrySearch
                )
            } else if state == .loaded && sections.isEmpty {
                placeholder(
                    systemImage: "magnifyingglass.circle",
                    text: EventPackageStrings.noSearchResults
                )
            } else if sections.isEmpty {
                Color.clear
            } else {
                List {
                    ForEach(sections) { section in
                        Section {
                            ForEach(section.events) { event in
                                Button(action: {
                                    if let eventID = event.eventID {
                                        onSelectEvent(eventID)
                                    }
                                }) {
                                    EventListItem(viewModel: event)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("Event-Search-Row-\(event.eventID ?? 0)")
                            }
                        } header: {
                            Text(section.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .textCase(nil)
                        }
                    }
                }
                .listStyle(.plain)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

    }

    private func placeholder(
        systemImage: String,
        text: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> some View {

        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text(text)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
        }

    }

}
