import Foundation
import Core
import ModernNetworking

nonisolated struct EventResource: Model {

    let data: Event

    enum CodingKeys: String, CodingKey {
        case data
    }

    var resource: Resource<Event> {
        Resource(data: data)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.data) {
            self.data = try container.decode(Event.self, forKey: .data)
        } else {
            self.data = try Event(from: decoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }

    static var decoder: JSONDecoder { Event.decoder }
}
