//
//  PostStore.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation
import GRDB
import Factory
import Combine

public class PostStore {
    
    private let writer: DatabaseWriter
    private let reader: DatabaseReader
    
    public init(
        writer: DatabaseWriter,
        reader: DatabaseReader
    ) {
        self.writer = writer
        self.reader = reader
    }
    
    func fetch() async throws -> [PostRecord] {
        
        try await reader.read { db in
            return try PostRecord
                .order(PostRecord.Columns.publishedAt.desc)
                .fetchAll(db)
        }
        
    }
    
    func fetch() -> AnyPublisher<[PostRecord], Error> {
        
        reader.readPublisher { db in
            return try PostRecord
                .order(PostRecord.Columns.publishedAt.desc)
                .fetchAll(db)
        }.eraseToAnyPublisher()
        
    }
    
    func show(postID: Post.ID) async throws -> PostRecord {
        
        try await reader.read({ db in
            
            return try PostRecord.find(db, key: postID)
            
        })
        
    }
    
    func insert(_ post: PostRecord) async throws -> PostRecord {
        
        try await writer.write { db in
            return try post.inserted(db)
        }
        
    }
    
    @discardableResult
    func updateOrCreate(_ posts: [PostRecord]) async throws -> [PostRecord] {
        
        try await writer.write({ db in
            
            var updatedPosts: [PostRecord] = []
            
            for post in posts {
                updatedPosts.append(try post.inserted(db, onConflict: .replace))
            }
            
            return updatedPosts
            
        })
        
    }
    
    func delete(_ post: PostRecord) async throws -> Bool {
        
        try await writer.write { db in
            return try post.delete(db)
        }
        
    }
    
    // MARK: - Observer -
    
    func changeObserver() -> AnyPublisher<[PostRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PostRecord
                    .order(PostRecord.Columns.publishedAt.desc)
                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
    func postObserver(postID: Post.ID) -> AnyPublisher<PostRecord?, Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PostRecord
                    .fetchOne(db, key: postID)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).print().eraseToAnyPublisher()
        
    }
    
    func feedObserver(feedID: Feed.ID, numberOfPosts: Int = 50) -> AnyPublisher<[PostRecord], Error> {
        
        let observation = ValueObservation
            .tracking { db in
                try PostRecord
                    .order(PostRecord.Columns.publishedAt.desc)
                    .limit(numberOfPosts)
                    .fetchAll(db)
            }
            .removeDuplicates()
        
        return observation.publisher(in: reader).eraseToAnyPublisher()
        
    }
    
}
