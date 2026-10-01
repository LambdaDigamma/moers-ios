//
//  Event.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import MMPages
@preconcurrency import MediaLibraryKit

nonisolated public struct Event: BaseEvent, Equatable, Hashable, Sendable {
    
    public typealias ID = Int
    
    public var id: ID
    public var name: String
    public var description: String? = nil
    public var url: String? = nil
    public var startDate: Date? = nil
    public var endDate: Date? = nil
    public var category: String? = nil
    public var imagePath: String? = nil
    public var web: URL? = nil
    public var image: URL? = nil
    public var extras: EventExtras? = nil
    public var pageID: Page.ID? = nil
    public var placeID: Place.ID? = nil
    public var artists: [String?]? = nil
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    public var publishedAt: Date?
    
    public var mediaCollections: MediaCollectionsContainer
    
    public var headerMedia: Media? {
        return mediaCollections.getFirstMedia(for: "header")
            ?? mediaCollections.getFirstMedia(for: "default")
            ?? mediaCollections.getFirstMedia(for: "insel")
    }
    
    public init(
        id: ID,
        name: String,
        description: String? = nil,
        url: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: String? = nil,
        imagePath: String? = nil,
        web: URL? = nil,
        image: URL? = nil,
        extras: EventExtras? = nil,
        artists: [String]? = nil,
        pageID: Page.ID? = nil,
        placeID: Place.ID? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        publishedAt: Date? = nil,
        mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.url = url
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.imagePath = imagePath
        self.web = web
        self.image = image
        self.extras = extras
        self.artists = artists
        self.pageID = pageID
        self.placeID = placeID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.mediaCollections = mediaCollections
    }
    
    // Relations
    public var page: Page? = nil
    public var place: Place? = nil
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case description = "description"
        case url = "url"
        case startDate = "start_date"
        case endDate = "end_date"
        case category = "category"
        case imagePath = "image_path"
        case web = "web"
        case image = "image"
        case extras = "extras"
        case pageID = "page_id"
        case placeID = "place_id"
        case artists = "artists"
        case page = "page"
        case place = "place"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case mediaCollections = "media_collections"
    }

    private enum DTOCodingKeys: String, CodingKey {
        case startDate
        case endDate
        case pageID = "pageId"
        case placeID = "placeId"
        case createdAt
        case updatedAt
        case publishedAt
        case locationName
        case street
        case postcode
        case city
        case latitude
        case longitude
        case organisationName
        case scheduleDisplay
        case headerImageURL = "headerImageUrl"
        case calendarURL = "calendarUrl"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dtoContainer = try decoder.container(keyedBy: DTOCodingKeys.self)

        self.id = try container.decode(ID.self, forKey: .id)
        self.name = try Self.decodeLocalizedString(from: container, forKey: .name)
            ?? container.decode(String.self, forKey: .name)
        self.description = try Self.decodeLocalizedString(from: container, forKey: .description)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
            ?? dtoContainer.decodeIfPresent(Date.self, forKey: .startDate)
        self.endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
            ?? dtoContainer.decodeIfPresent(Date.self, forKey: .endDate)
        self.category = try Self.decodeLocalizedString(from: container, forKey: .category)
        self.imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
            ?? dtoContainer.decodeIfPresent(String.self, forKey: .headerImageURL)
        self.web = try container.decodeIfPresent(URL.self, forKey: .web)
            ?? self.url.flatMap(URL.init(string:))
        self.image = try container.decodeIfPresent(URL.self, forKey: .image)
            ?? self.imagePath.flatMap(URL.init(string:))

        var decodedExtras = try container.decodeIfPresent(EventExtras.self, forKey: .extras)
        Self.mergeDTOExtras(from: dtoContainer, into: &decodedExtras)
        self.extras = decodedExtras

        self.pageID = try container.decodeIfPresent(Page.ID.self, forKey: .pageID)
            ?? dtoContainer.decodeIfPresent(Page.ID.self, forKey: .pageID)
        self.placeID = try container.decodeIfPresent(Place.ID.self, forKey: .placeID)
            ?? dtoContainer.decodeIfPresent(Place.ID.self, forKey: .placeID)
        self.artists = try container.decodeIfPresent([String?].self, forKey: .artists)
            ?? container.decodeIfPresent([String].self, forKey: .artists)?.map(Optional.some)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
            ?? dtoContainer.decodeIfPresent(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
            ?? dtoContainer.decodeIfPresent(Date.self, forKey: .updatedAt)
        self.publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)
            ?? dtoContainer.decodeIfPresent(Date.self, forKey: .publishedAt)
        self.mediaCollections = try container.decodeIfPresent(MediaCollectionsContainer.self, forKey: .mediaCollections)
            ?? MediaCollectionsContainer()
        self.page = try container.decodeIfPresent(Page.self, forKey: .page)
        self.place = try container.decodeIfPresent(Place.self, forKey: .place)
    }
    
    public var isOpenEnd: Bool {
        
        if let openEnd = extras?.openEnd {
            return openEnd
        }
        
        return false
        
    }

    public var scheduleDisplayMode: EventScheduleDisplayMode {
        if let scheduleDisplay = extras?.scheduleDisplay {
            return scheduleDisplay
        }

        if extras?.isPreview == true {
            return .date
        }

        return .dateTime
    }

    public var showsDateComponent: Bool {
        return scheduleDisplayMode.showsDateComponent
    }

    public var showsTimeComponent: Bool {
        return scheduleDisplayMode.showsTimeComponent
    }
    
    public var isPreview: Bool {
        return scheduleDisplayMode == .date
    }
    
}

nonisolated extension Event {
    
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()

            if let timestamp = try? container.decode(Double.self) {
                return Date(timeIntervalSince1970: timestamp)
            }

            let value = try container.decode(String.self)

            guard let date = Self.date(from: value) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid event date: \(value)"
                )
            }

            return date
        }
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return decoder
    }
    
    public static func stub(withID id: Event.ID) -> Event {
        
        return Event(
            id: id,
            name: "Test Event",
            description: nil,
            url: nil,
            startDate: nil,
            endDate: nil,
            category: nil,
            imagePath: nil,
            extras: nil,
            createdAt: Date(),
            updatedAt: Date(),
            publishedAt: Date()
        )
        
    }
    
}

nonisolated private extension Event {

    static func decodeLocalizedString<Key: CodingKey>(
        from container: KeyedDecodingContainer<Key>,
        forKey key: Key
    ) throws -> String? {
        if let value = try? container.decodeIfPresent(String.self, forKey: key) {
            return value
        }

        if let translations = try? container.decodeIfPresent([String: String].self, forKey: key) {
            return translations[Locale.current.language.languageCode?.identifier ?? ""]
                ?? translations[Locale.preferredLanguages.first ?? ""]
                ?? translations["de"]
                ?? translations["en"]
                ?? translations.values.first
        }

        return nil
    }

    private static func mergeDTOExtras(
        from container: KeyedDecodingContainer<DTOCodingKeys>,
        into extras: inout EventExtras?
    ) {
        func merge<Value>(_ keyPath: WritableKeyPath<EventExtras, Value?>, value: Value?) {
            guard let value else { return }

            if extras == nil {
                extras = EventExtras()
            }

            if extras?[keyPath: keyPath] == nil {
                extras?[keyPath: keyPath] = value
            }
        }

        merge(\.location, value: try? container.decodeIfPresent(String.self, forKey: .locationName))
        merge(\.street, value: try? container.decodeIfPresent(String.self, forKey: .street))
        merge(\.postcode, value: try? container.decodeIfPresent(String.self, forKey: .postcode))
        merge(\.place, value: try? container.decodeIfPresent(String.self, forKey: .city))
        merge(\.lat, value: try? container.decodeIfPresent(Double.self, forKey: .latitude))
        merge(\.lng, value: try? container.decodeIfPresent(Double.self, forKey: .longitude))
        merge(\.organizer, value: try? container.decodeIfPresent(String.self, forKey: .organisationName))
        merge(\.scheduleDisplay, value: try? container.decodeIfPresent(EventScheduleDisplayMode.self, forKey: .scheduleDisplay))
    }

    static func date(from value: String) -> Date? {
        for formatter in iso8601Formatters {
            if let date = formatter.date(from: value) {
                return date
            }
        }

        for formatter in dateFormatters {
            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }

    static var iso8601Formatters: [ISO8601DateFormatter] {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]

        return [fractional, plain]
    }

    static var dateFormatters: [DateFormatter] {
        [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        ].map { dateFormat in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = dateFormat
            return formatter
        }
    }

}
