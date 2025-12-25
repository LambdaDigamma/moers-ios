//
//  Storage.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation

public typealias Handler<T> = (Result<T, Error>) -> Void

public protocol ReadableStorage {
    func fetchValue(for key: String) throws -> Data
    func fetchValue(for key: String, handler: @escaping Handler<Data>)
}

public protocol WritableStorage {
    func save(value: Data, for key: String) throws
    func save(value: Data, for key: String, handler: @escaping Handler<Data>)
}

public typealias Storage = ReadableStorage & WritableStorage
