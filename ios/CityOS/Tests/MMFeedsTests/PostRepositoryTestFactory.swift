import GRDB
@testable import MMFeeds

@MainActor
enum PostRepositoryTestFactory {
    static func make(service: (any PostService)? = nil) throws -> PostRepository {
        let database = try DatabaseQueue()
        try database.write { connection in
            try connection.create(table: PostTableDefinition.tableName) { table in
                PostTableDefinition.apply(table)
            }
        }
        let post = Post.stub(withID: 42).setting(\.feedID, to: 1).setting(\.pageID, to: nil)
        return PostRepository(
            service: service ?? MockPostService(result: .success(post), results: .success([post])),
            store: PostStore(writer: database, reader: database)
        )
    }
}
