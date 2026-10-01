//
//  DiskStorage.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation

nonisolated public enum StorageError: Error {
    case notFound
    case cantWrite(Error)
}

nonisolated public final class DiskStorage {
    private let queue: DispatchQueue
    private let path: URL
    
    public init(
        path: URL,
        queue: DispatchQueue = .init(label: "DiskCache.Queue")
    ) {
        self.path = path
        self.queue = queue
    }
}

nonisolated extension DiskStorage: WritableStorage {
    
    public func save(value: Data, for key: String) throws {
        try Self.save(value: value, for: key, path: path)
    }
    
    public func save(value: Data, for key: String, handler: @escaping Handler<Data>) {
        let path = self.path

        queue.async {
            do {
                try Self.save(value: value, for: key, path: path)
                handler(.success(value))
            } catch {
                handler(.failure(error))
            }
        }
    }
    
}

nonisolated extension DiskStorage {
    
    private static func save(value: Data, for key: String, path: URL) throws {
        let url = path.appendingPathComponent(key)
        do {
            try createFolders(in: url)
            try value.write(to: url, options: .atomic)
        } catch {
            throw StorageError.cantWrite(error)
        }
    }

    private static func fetchValue(for key: String, path: URL) throws -> Data {
        let url = path.appendingPathComponent(key)
        guard let data = FileManager.default.contents(atPath: url.path) else {
            throw StorageError.notFound
        }
        return data
    }

    private static func createFolders(in url: URL) throws {
        let folderUrl = url.deletingLastPathComponent()
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
}

nonisolated extension DiskStorage: ReadableStorage {
    
    public func fetchValue(for key: String) throws -> Data {
        try Self.fetchValue(for: key, path: path)
    }
    
    public func fetchValue(for key: String, handler: @escaping Handler<Data>) {
        let path = self.path

        queue.async {
            handler(Result { try Self.fetchValue(for: key, path: path) })
        }
    }
    
}
