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
import Factory
import Combine

public class EventListItemViewModel: StandardViewModel, Identifiable, Hashable, Equatable {
    
    public let id: UUID = .init()
    
    public let eventID: Event.ID?
    
    @Published public var title: String
    @Published public var startDate: Date?
    @Published public var endDate: Date?
    @Published public var location: String?
    @Published public var color: Color = .yellow
    @Published public var media: Media?
    
    @Published public var isOpenEnd: Bool = false
    @Published public var isPreview: Bool = false
    
    @Published public var isLiked: Bool = false
    
    private let favoriteEventsStore: FavoriteEventsStore?
    
    public init(
        eventID: Event.ID? = nil,
        title: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        location: String? = nil,
        media: Media? = nil,
        isOpenEnd: Bool = false,
        isLiked: Bool = false,
        isPreview: Bool
    ) {
        self.eventID = eventID
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.media = media
        self.isLiked = isLiked
        self.isOpenEnd = isOpenEnd
        self.isPreview = isPreview
        self.favoriteEventsStore = Container.shared.favoriteEventsStore()
        super.init()
        self.setupListeners()
    }
    
    public var isActive: Bool {
        return EventUtilities.isActive(
            startDate: startDate,
            endDate: endDate
        )
    }
    
    public var dateRange: ClosedRange<Date>? {
        
        if isPreview {
            return nil
        }
        
        if !isOpenEnd {
            
            return EventUtilities.dateRange(
                startDate: startDate,
                endDate: endDate
            )
            
        } else {
            return nil
        }
        
    }
    
    public var timeDisplayMode: TimeDisplayMode {
        return EventUtilities.timeDisplayMode(
            startDate: startDate,
            endDate: endDate,
            isPreview: isPreview
        )
    }
    
    public func setupListeners() {
        
        guard let favoriteEventsStore else { return }
        guard let eventID else { return }

        favoriteEventsStore.isLiked(eventID: eventID)
            .sink { (completion: Subscribers.Completion<Error>) in

            } receiveValue: { (isLiked: Bool) in

                self.isLiked = isLiked

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
    
    @ObservedObject private var viewModel: EventListItemViewModel
    
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
                
                subtitle()
                
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
    
    @ViewBuilder
    private func subtitle() -> some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            switch viewModel.timeDisplayMode {
                    
                case .live:
                    
                    (viewModel.location != nil ? Text("\(viewModel.location ?? "")") : Text(""))
//                        .padding(.leading, 8)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    LiveBadge()
                    
                case .relative:
                    if let startDate = viewModel.startDate {
                        
                        Group {
                            
                            Text(startDate, format: .relative(presentation: .numeric)) +
                            (viewModel.location != nil ?
                             Text(" · \(viewModel.location ?? "")") :
                                Text(""))
                            
                        }.lineLimit(1)
                        
                    }
                    
                case .range:
                    
                    if let dateRange = viewModel.dateRange {
                        
                        Group {
                            
                            Text(dateRange) +
                            (viewModel.location != nil ? Text(" · \(viewModel.location ?? "")") : Text(""))
                            
                        }
                        .lineLimit(1)
                        
                    } else if let startDate = viewModel.startDate, !viewModel.isPreview {
                        
                        Group {
                            
                            Text(startDate, style: .time) +
                            
                            (viewModel.location != nil ? Text(" · \(viewModel.location ?? "")") : Text(""))
                            
                        }
                        .lineLimit(1)
                        
                    } else if viewModel.isPreview {
                        
                        Text("No time yet", bundle: .module)
                            .lineLimit(1)
                        
                    }
                    
                case .none:
                    Text("No time yet", bundle: .module)
                    
            }
            
        }
        .foregroundColor(.secondary)
        .font(.callout)
        
    }
    
}

struct EventListItem_Previews: PreviewProvider {
    static var previews: some View {
        
        let noTime = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            location: "Aula Gymnasium Filder Benden",
            isLiked: true,
            isPreview: false
        )
        
        let future = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            startDate: Date(timeIntervalSinceNow: 160 * 60),
            endDate: Date(timeIntervalSinceNow: 190 * 60),
            location: "Aula Gymnasium Filder Benden",
            isPreview: false
        )
        
        let upcoming = EventListItemViewModel(
            title: "Matthew Welch solo bagpipes: Matthew Welch plays Braxton, Glass, Welch & More! (US)",
            startDate: Date(timeIntervalSinceNow: 5 * 60),
            endDate: Date(timeIntervalSinceNow: 35 * 60),
            location: "Aula Gymnasium Filder Benden",
            isPreview: false
        )
        
        upcoming.color = .blue
        
        let activeViewModel = EventListItemViewModel(
            title: "Ghost Dogs (DE)",
            startDate: Date(timeIntervalSinceNow: -5 * 60),
            endDate: Date(timeIntervalSinceNow: 35 * 60),
            location: "Aula Gymnasium Filder Benden",
            isPreview: false
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
