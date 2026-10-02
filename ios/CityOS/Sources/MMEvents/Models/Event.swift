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
    public var excerpt: String? = nil
    public var teaser: String? = nil
    public var subtitle: String? = nil
    public var url: String? = nil
    public var calendarURL: String? = nil
    public var startDate: Date? = nil
    public var endDate: Date? = nil
    public var category: String? = nil
    public var collection: String? = nil
    public var attendanceMode: String? = nil
    public var isOnline: Bool = false
    public var isMultiDay: Bool = false
    private var decodedShowsDateComponent: Bool? = nil
    private var decodedShowsTimeComponent: Bool? = nil
    public var imagePath: String? = nil
    public var web: URL? = nil
    public var image: URL? = nil
    public var extras: EventExtras? = nil
    public var pageID: Page.ID? = nil
    public var placeID: Place.ID? = nil
    public var artists: [String?]? = nil
    public var organisationName: String? = nil
    public var organisationSlug: String? = nil
    public var organisationLogoPath: String? = nil
    public var organizerStreet: String? = nil
    public var organizerPostcode: String? = nil
    public var organizerCity: String? = nil
    public var organizerPhone: String? = nil
    public var organizerEmail: String? = nil
    public var organizerWebsite: String? = nil
    public var createdAt: Date? = Date()
    public var updatedAt: Date? = Date()
    public var publishedAt: Date?
    public var cancelledAt: Date?
    public var archivedAt: Date?
    public var deletedAt: Date?
    
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
        excerpt: String? = nil,
        teaser: String? = nil,
        subtitle: String? = nil,
        url: String? = nil,
        calendarURL: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        category: String? = nil,
        collection: String? = nil,
        attendanceMode: String? = nil,
        isOnline: Bool = false,
        isMultiDay: Bool = false,
        imagePath: String? = nil,
        web: URL? = nil,
        image: URL? = nil,
        extras: EventExtras? = nil,
        artists: [String]? = nil,
        pageID: Page.ID? = nil,
        placeID: Place.ID? = nil,
        organisationName: String? = nil,
        organisationSlug: String? = nil,
        organisationLogoPath: String? = nil,
        organizerStreet: String? = nil,
        organizerPostcode: String? = nil,
        organizerCity: String? = nil,
        organizerPhone: String? = nil,
        organizerEmail: String? = nil,
        organizerWebsite: String? = nil,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        publishedAt: Date? = nil,
        cancelledAt: Date? = nil,
        archivedAt: Date? = nil,
        deletedAt: Date? = nil,
        mediaCollections: MediaCollectionsContainer = MediaCollectionsContainer()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.excerpt = excerpt
        self.teaser = teaser
        self.subtitle = subtitle
        self.url = url
        self.calendarURL = calendarURL
        self.startDate = startDate
        self.endDate = endDate
        self.category = category
        self.collection = collection
        self.attendanceMode = attendanceMode
        self.isOnline = isOnline
        self.isMultiDay = isMultiDay
        self.imagePath = imagePath
        self.web = web
        self.image = image
        self.extras = extras
        self.artists = artists
        self.pageID = pageID
        self.placeID = placeID
        self.organisationName = organisationName
        self.organisationSlug = organisationSlug
        self.organisationLogoPath = organisationLogoPath
        self.organizerStreet = organizerStreet
        self.organizerPostcode = organizerPostcode
        self.organizerCity = organizerCity
        self.organizerPhone = organizerPhone
        self.organizerEmail = organizerEmail
        self.organizerWebsite = organizerWebsite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.cancelledAt = cancelledAt
        self.archivedAt = archivedAt
        self.deletedAt = deletedAt
        self.mediaCollections = mediaCollections
    }
    
    // Relations
    public var page: Page? = nil
    public var place: Place? = nil
    
    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case description = "description"
        case excerpt = "excerpt"
        case teaser = "teaser"
        case subtitle = "subtitle"
        case url = "url"
        case calendarURL = "calendarUrl"
        case startDate = "start_date"
        case cityStartDate = "startDate"
        case endDate = "end_date"
        case cityEndDate = "endDate"
        case category = "category"
        case collection = "collection"
        case attendanceMode = "attendanceMode"
        case isOnline = "isOnline"
        case isMultiDay = "isMultiDay"
        case showsDateComponent = "showsDateComponent"
        case showsTimeComponent = "showsTimeComponent"
        case imagePath = "image_path"
        case headerImageURL = "headerImageUrl"
        case web = "web"
        case image = "image"
        case extras = "extras"
        case pageID = "page_id"
        case cityPageID = "pageId"
        case placeID = "place_id"
        case cityPlaceID = "placeId"
        case artists = "artists"
        case page = "page"
        case place = "place"
        case createdAt = "created_at"
        case cityCreatedAt = "createdAt"
        case updatedAt = "updated_at"
        case cityUpdatedAt = "updatedAt"
        case publishedAt = "published_at"
        case cityPublishedAt = "publishedAt"
        case cancelledAt = "cancelled_at"
        case cityCancelledAt = "cancelledAt"
        case archivedAt = "archived_at"
        case cityArchivedAt = "archivedAt"
        case deletedAt = "deleted_at"
        case cityDeletedAt = "deletedAt"
        case mediaCollections = "media_collections"
        case scheduleDisplay = "scheduleDisplay"
        case locationName = "locationName"
        case street = "street"
        case postcode = "postcode"
        case city = "city"
        case latitude = "latitude"
        case longitude = "longitude"
        case organisationName = "organisationName"
        case organisationSlug = "organisationSlug"
        case organisationLogoPath = "organisationLogoPath"
        case organizerStreet = "organizerStreet"
        case organizerPostcode = "organizerPostcode"
        case organizerCity = "organizerCity"
        case organizerPhone = "organizerPhone"
        case organizerEmail = "organizerEmail"
        case organizerWebsite = "organizerWebsite"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(ID.self, forKey: .id)
        self.name = try Self.decodeLocalizedString(from: container, forKey: .name)
            ?? container.decode(String.self, forKey: .name)

        let decodedDescription = try Self.decodeLocalizedString(from: container, forKey: .description)
        let decodedExcerpt = try Self.decodeIfPresent(String.self, from: container, forKeys: .excerpt)
        let decodedTeaser = try Self.decodeIfPresent(String.self, from: container, forKeys: .teaser)

        self.excerpt = decodedExcerpt
        self.teaser = decodedTeaser
        self.subtitle = try Self.decodeIfPresent(String.self, from: container, forKeys: .subtitle)

        self.description = decodedDescription ?? decodedTeaser ?? decodedExcerpt
        self.url = try Self.decodeIfPresent(String.self, from: container, forKeys: .url)
        self.calendarURL = try Self.decodeIfPresent(String.self, from: container, forKeys: .calendarURL)
        self.startDate = try Self.decodeIfPresent(Date.self, from: container, forKeys: .startDate, .cityStartDate)
        self.endDate = try Self.decodeIfPresent(Date.self, from: container, forKeys: .endDate, .cityEndDate)
        self.category = try Self.decodeLocalizedString(from: container, forKey: .category)
        self.collection = try Self.decodeIfPresent(String.self, from: container, forKeys: .collection)
        self.attendanceMode = try Self.decodeIfPresent(String.self, from: container, forKeys: .attendanceMode)
        self.isOnline = try Self.decodeIfPresent(Bool.self, from: container, forKeys: .isOnline) ?? false
        self.isMultiDay = try Self.decodeIfPresent(Bool.self, from: container, forKeys: .isMultiDay) ?? false
        self.decodedShowsDateComponent = try Self.decodeIfPresent(Bool.self, from: container, forKeys: .showsDateComponent)
        self.decodedShowsTimeComponent = try Self.decodeIfPresent(Bool.self, from: container, forKeys: .showsTimeComponent)

        let headerImageURL = try Self.decodeIfPresent(String.self, from: container, forKeys: .headerImageURL)
        self.imagePath = try Self.decodeIfPresent(String.self, from: container, forKeys: .imagePath) ?? headerImageURL
        self.web = try Self.decodeIfPresent(URL.self, from: container, forKeys: .web) ?? URL(string: url ?? "")
        self.image = try Self.decodeIfPresent(URL.self, from: container, forKeys: .image)
            ?? self.imagePath.flatMap(URL.init(string:))

        self.pageID = try Self.decodeIfPresent(Page.ID.self, from: container, forKeys: .pageID, .cityPageID)
        self.placeID = try Self.decodeIfPresent(Place.ID.self, from: container, forKeys: .placeID, .cityPlaceID)
        self.artists = try Self.decodeIfPresent([String?].self, from: container, forKeys: .artists)
        self.createdAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .createdAt, .cityCreatedAt)
        self.updatedAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .updatedAt, .cityUpdatedAt)
        self.publishedAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .publishedAt, .cityPublishedAt)
        self.cancelledAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .cancelledAt, .cityCancelledAt)
        self.archivedAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .archivedAt, .cityArchivedAt)
        self.deletedAt = try Self.decodeIfPresent(Date.self, from: container, forKeys: .deletedAt, .cityDeletedAt)
        self.mediaCollections = try Self.decodeIfPresent(
            MediaCollectionsContainer.self,
            from: container,
            forKeys: .mediaCollections
        ) ?? MediaCollectionsContainer()

        var decodedExtras = try Self.decodeIfPresent(EventExtras.self, from: container, forKeys: .extras)
        let locationName = try Self.decodeIfPresent(String.self, from: container, forKeys: .locationName)
        let street = try Self.decodeIfPresent(String.self, from: container, forKeys: .street)
        let postcode = try Self.decodeIfPresent(String.self, from: container, forKeys: .postcode)
        let city = try Self.decodeIfPresent(String.self, from: container, forKeys: .city)
        let latitude = try Self.decodeIfPresent(Double.self, from: container, forKeys: .latitude)
        let longitude = try Self.decodeIfPresent(Double.self, from: container, forKeys: .longitude)
        let organisationName = try Self.decodeIfPresent(String.self, from: container, forKeys: .organisationName)
        self.organisationName = organisationName
        self.organisationSlug = try Self.decodeIfPresent(String.self, from: container, forKeys: .organisationSlug)
        self.organisationLogoPath = try Self.decodeIfPresent(String.self, from: container, forKeys: .organisationLogoPath)
        self.organizerStreet = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerStreet)
        self.organizerPostcode = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerPostcode)
        self.organizerCity = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerCity)
        self.organizerPhone = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerPhone)
        self.organizerEmail = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerEmail)
        self.organizerWebsite = try Self.decodeIfPresent(String.self, from: container, forKeys: .organizerWebsite)
        let scheduleDisplay = try Self.decodeIfPresent(
            EventScheduleDisplayMode.self,
            from: container,
            forKeys: .scheduleDisplay
        )

        if locationName != nil || street != nil || postcode != nil || city != nil || latitude != nil
            || longitude != nil || organisationName != nil || scheduleDisplay != nil {
            var mergedExtras = decodedExtras ?? EventExtras()

            mergedExtras.location = mergedExtras.location ?? locationName
            mergedExtras.street = mergedExtras.street ?? street
            mergedExtras.postcode = mergedExtras.postcode ?? postcode
            mergedExtras.place = mergedExtras.place ?? city
            mergedExtras.lat = mergedExtras.lat ?? latitude
            mergedExtras.lng = mergedExtras.lng ?? longitude
            mergedExtras.organizer = mergedExtras.organizer ?? organisationName
            mergedExtras.scheduleDisplay = mergedExtras.scheduleDisplay ?? scheduleDisplay

            decodedExtras = mergedExtras
        }

        self.extras = decodedExtras
        self.page = try Self.decodeIfPresent(Page.self, from: container, forKeys: .page)
        self.place = try Self.decodeIfPresent(Place.self, from: container, forKeys: .place)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(excerpt, forKey: .excerpt)
        try container.encodeIfPresent(teaser, forKey: .teaser)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(calendarURL, forKey: .calendarURL)
        try container.encodeIfPresent(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(collection, forKey: .collection)
        try container.encodeIfPresent(attendanceMode, forKey: .attendanceMode)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(isMultiDay, forKey: .isMultiDay)
        try container.encode(showsDateComponent, forKey: .showsDateComponent)
        try container.encode(showsTimeComponent, forKey: .showsTimeComponent)
        try container.encodeIfPresent(imagePath, forKey: .imagePath)
        try container.encodeIfPresent(web, forKey: .web)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(extras, forKey: .extras)
        try container.encodeIfPresent(pageID, forKey: .pageID)
        try container.encodeIfPresent(placeID, forKey: .placeID)
        try container.encodeIfPresent(artists, forKey: .artists)
        try container.encodeIfPresent(page, forKey: .page)
        try container.encodeIfPresent(place, forKey: .place)
        try container.encodeIfPresent(organisationName, forKey: .organisationName)
        try container.encodeIfPresent(organisationSlug, forKey: .organisationSlug)
        try container.encodeIfPresent(organisationLogoPath, forKey: .organisationLogoPath)
        try container.encodeIfPresent(organizerStreet, forKey: .organizerStreet)
        try container.encodeIfPresent(organizerPostcode, forKey: .organizerPostcode)
        try container.encodeIfPresent(organizerCity, forKey: .organizerCity)
        try container.encodeIfPresent(organizerPhone, forKey: .organizerPhone)
        try container.encodeIfPresent(organizerEmail, forKey: .organizerEmail)
        try container.encodeIfPresent(organizerWebsite, forKey: .organizerWebsite)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(publishedAt, forKey: .publishedAt)
        try container.encodeIfPresent(cancelledAt, forKey: .cancelledAt)
        try container.encodeIfPresent(archivedAt, forKey: .archivedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
        try container.encode(mediaCollections, forKey: .mediaCollections)
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
        return decodedShowsDateComponent ?? scheduleDisplayMode.showsDateComponent
    }

    public var showsTimeComponent: Bool {
        return decodedShowsTimeComponent ?? scheduleDisplayMode.showsTimeComponent
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


    static func decodeIfPresent<T: Decodable>(
        _ type: T.Type,
        from container: KeyedDecodingContainer<CodingKeys>,
        forKeys keys: CodingKeys...
    ) throws -> T? {
        for key in keys {
            if let value = try container.decodeIfPresent(type, forKey: key) {
                return value
            }
        }

        return nil
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
