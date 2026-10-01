//
//  EventListItem.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import MediaLibraryKit
import FactoryKit
import Combine

@Observable
public class EventListItemViewModel: StandardViewModel, Identifiable, Hashable, Equatable {
    
    public let id: UUID = .init()
    
    public let eventID: Event.ID?
    
    public var title: String
    public var startDate: Date?
    public var endDate: Date?
    public var location: String?
    public var color: Color = .yellow
    public var media: Media?
    
    public var isOpenEnd: Bool = false
    public var scheduleDisplayMode: EventScheduleDisplayMode = .dateTime
    
    public var isLiked: Bool = false
    
    private let favoriteEventsStore: FavoriteEventsStore?

    // This type only releases references; actor hopping is not needed in deinit.
    nonisolated deinit {}
    
    public init(
        eventID: Event.ID? = nil,
        title: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        media: Media? = nil,
        isOpenEnd: Bool = false,
        isLiked: Bool = false,
        scheduleDisplayMode: EventScheduleDisplayMode = .dateTime
    ) {
        self.eventID = eventID
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.media = media
        self.isLiked = isLiked
        self.isOpenEnd = isOpenEnd
        self.scheduleDisplayMode = scheduleDisplayMode
        self.favoriteEventsStore = Container.shared.favoriteEventsStore()
        super.init()
        self.setupListeners()
    }
    
    public var isActive: Bool {
        isActive(at: Date())
    }

    public func isActive(at now: Date) -> Bool {
        return EventUtilities.isActive(
            startDate: startDate,
            endDate: endDate,
            now: now
        )
    }

    public var showsDateComponent: Bool {
        return scheduleDisplayMode.showsDateComponent
    }

    public var showsTimeComponent: Bool {
        return scheduleDisplayMode.showsTimeComponent
    }
    
    public var dateRange: ClosedRange<Date>? {
        if showsTimeComponent && !isOpenEnd {
            return EventUtilities.dateRange(
                startDate: startDate,
                endDate: endDate
            )
        }

        return nil
        
    }
    
    public var timeDisplayMode: TimeDisplayMode {
        timeDisplayMode(at: Date())
    }

    public func timeDisplayMode(at now: Date) -> TimeDisplayMode {
        return EventUtilities.timeDisplayMode(
            startDate: startDate,
            endDate: endDate,
            scheduleDisplayMode: scheduleDisplayMode,
            now: now
        )
    }
    
    public func setupListeners() {
        guard cancellables.isEmpty else { return }
        
        guard let favoriteEventsStore else { return }
        guard let eventID else { return }

        favoriteEventsStore.isLiked(eventID: eventID)
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in

            } receiveValue: { [weak self] (isLiked: Bool) in

                self?.isLiked = isLiked

            }
            .store(in: &cancellables)
        
    }
    
    public static func == (lhs: EventListItemViewModel, rhs: EventListItemViewModel) -> Bool {
        
        return lhs.eventID == rhs.eventID &&
        lhs.title == rhs.title &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.location == rhs.location &&
        lhs.color == rhs.color &&
        lhs.media == rhs.media &&
        lhs.isOpenEnd == rhs.isOpenEnd &&
        lhs.scheduleDisplayMode == rhs.scheduleDisplayMode &&
        lhs.isLiked == rhs.isLiked
        
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(eventID)
        hasher.combine(title)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(location)
        hasher.combine(color)
        hasher.combine(media)
        hasher.combine(isOpenEnd)
        hasher.combine(scheduleDisplayMode)
        hasher.combine(isLiked)
    }
    
}

private struct ShowFavoriteIconKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var showFavoriteIcon: Bool {
        get { self[ShowFavoriteIconKey.self] }
        set { self[ShowFavoriteIconKey.self] = newValue }
    }
}

public extension View {
    func showFavoriteIcon(_ value: Bool) -> some View {
        environment(\.showFavoriteIcon, value)
    }
}

public struct EventListItem: View {
    
    @Environment(\.showFavoriteIcon) var showFavoriteIcon
    
    private var viewModel: EventListItemViewModel
    
    public init(viewModel: EventListItemViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        HStack(alignment: .center) {
            
            VStack(alignment: .leading, spacing: 6) {
                
                HStack(alignment: .top) {
                    
                    Text(viewModel.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                }
                
                EventSubtitleView(viewModel: viewModel)
                
            }
            .padding(.leading, 16)
            .background(
                ZStack {
                    Rectangle()
                        .fill(viewModel.color)
                        .frame(width: 2)
                        .cornerRadius(4)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            )
            
            if viewModel.isLiked && showFavoriteIcon {
                Image(systemName: "heart.fill")
                    .imageScale(.small)
                    .foregroundColor(.red)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct EventListItem_Previews: PreviewProvider {
    static var previews: some View {
        
        let noTime = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            location: "Aula Gymnasium Filder Benden",
            isLiked: true,
            scheduleDisplayMode: .hidden
        )
        
        let future = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            startDate: Date(timeIntervalSinceNow: 160 * 60),
            endDate: Date(timeIntervalSinceNow: 190 * 60),
            location: "Aula Gymnasium Filder Benden",
            scheduleDisplayMode: .dateTime
        )
        
        let upcoming = EventListItemViewModel(
            title: "Matthew Welch solo bagpipes: Matthew Welch plays Braxton, Glass, Welch & More! (US)",
            startDate: Date(timeIntervalSinceNow: 5 * 60),
            endDate: Date(timeIntervalSinceNow: 35 * 60),
            location: "Aula Gymnasium Filder Benden",
            scheduleDisplayMode: .date
        )
        
        upcoming.color = .blue
        
        let activeViewModel = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            startDate: Date(timeIntervalSinceNow: -5 * 60),
            endDate: Date(timeIntervalSinceNow: 35 * 60),
            location: "Aula Gymnasium Filder Benden",
            scheduleDisplayMode: .dateTime
        )
        
        return Group {
            
            EventListItem(viewModel: noTime)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            EventListItem(viewModel: future)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            EventListItem(viewModel: upcoming)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .environment(\.locale, Locale(identifier: "de"))

            EventListItem(viewModel: activeViewModel)
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
        }
        
    }
}
