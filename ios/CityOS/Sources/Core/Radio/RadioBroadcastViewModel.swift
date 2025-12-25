//
//  RadioBroadcastViewModel.swift
//  
//
//  Created by Lennart Fischer on 01.10.21.
//

import Foundation

public class RadioBroadcastViewModel: Identifiable, ObservableObject {
    
    public let id: Int
    public var title: String
    public var subtitle: String = ""
    public var imageURL: String?
    public var description: String?
    @Published public var enabledReminder: Bool = false
    
    public init(from broadcast: RadioBroadcast) {
        self.id = broadcast.id
        self.title = broadcast.title
        self.subtitle = getSubtitle(for: broadcast)
        self.description = broadcast.description
        self.imageURL = broadcast.attach
    }
    
    public init(
        id: Int,
        title: String,
        subtitle: String,
        imageURL: String? = nil,
        description: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.description = description
    }
    
    private func getSubtitle(for broadcast: RadioBroadcast) -> String {
        if let startDate = broadcast.startsAt, let endDate = broadcast.endsAt {
            return Self.intervalFormatter.string(
                from: startDate,
                to: endDate
            )
        } else {
            return AppStrings.Buergerfunk.unknownTime
        }
    }
    
    internal static let intervalFormatter: DateIntervalFormatter = {
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
        
    }()
    
}
