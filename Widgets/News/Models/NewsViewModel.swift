//
//  NewsViewModel.swift
//  
//
//  Created by Lennart Fischer on 10.06.21.
//

import Foundation
import WidgetKit
import UIKit

public struct NewsViewModel: Identifiable, Equatable, TimelineEntry {

    public var id: UUID = UUID()
    public var topic: String?
    public var headline: String
    public var imageName: String?
    public var link: URL
    public var imageURL: URL?

    public var image: () -> UIImage? = {
        return nil
    }

    public var date: Date = Date()

    public init(id: UUID = UUID(), topic: String? = nil, headline: String, imageName: String? = nil, link: URL, imageURL: URL? = nil) {
        self.id = id
        self.topic = topic
        self.headline = headline
        self.imageName = imageName
        self.link = link
        self.imageURL = imageURL
        self.image = {
            if let imageName = imageName {
                return UIImage(named: imageName)
            }
            return nil
        }
    }
    
    public static func == (lhs: NewsViewModel, rhs: NewsViewModel) -> Bool {
        return lhs.id == rhs.id
            && lhs.topic == rhs.topic
            && lhs.headline == rhs.headline
            && lhs.link == rhs.link
    }
    
}
