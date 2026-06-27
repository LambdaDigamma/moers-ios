//
//  Storage.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation

public typealias Handler<T> = @Sendable (Result<T, Error>) -> Void

nonisolated public protocol ReadableStorage {
    func fetchValue(for key: String) throws -> Data
    func fetchValue(for key: String, handler: @escaping Handler<Data>)
}

nonisolated public protocol WritableStorage {
    func save(value: Data, for key: String) throws
    func save(value: Data, for key: String, handler: @escaping Handler<Data>)
}

public typealias Storage = ReadableStorage & WritableStorage
