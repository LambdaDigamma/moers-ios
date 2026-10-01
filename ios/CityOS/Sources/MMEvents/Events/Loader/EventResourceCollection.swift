import Foundation
import Core
import ModernNetworking

nonisolated struct EventResourceCollection: Model {

    let data: [Event]
    let links: ResourceLinks
    let meta: ResourceMeta

    enum CodingKeys: String, CodingKey {
        case data
        case links
        case meta
    }

    var resourceCollection: ResourceCollection<Event> {
        ResourceCollection(data: data, links: links, meta: meta)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.data = try container.decode([Event].self, forKey: .data)
        self.links = (try? container.decode(ResourceLinks.self, forKey: .links)) ?? ResourceLinks()

        if let resourceMeta = try? container.decode(ResourceMeta.self, forKey: .meta) {
            self.meta = resourceMeta
        } else {
            self.meta = try container.decode(EventResourceMetadata.self, forKey: .meta).resourceMeta
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(links, forKey: .links)
        try container.encode(meta, forKey: .meta)
    }

    static var decoder: JSONDecoder { Event.decoder }
}
