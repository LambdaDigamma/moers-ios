import Foundation
import Core
import ModernNetworking

nonisolated struct EventResourceMetadata: Decodable {

    let currentPage: Int?
    let from: Int?
    let lastPage: Int?
    let path: String?
    let perPage: Int?
    let to: Int?
    let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case path
        case perPage = "per_page"
        case to
        case total
    }

    var resourceMeta: ResourceMeta {
        ResourceMeta(
            currentPage: currentPage,
            from: from,
            lastPage: lastPage ?? 1,
            links: [],
            path: path ?? "",
            perPage: perPage ?? 10,
            to: to,
            total: total
        )
    }

}
