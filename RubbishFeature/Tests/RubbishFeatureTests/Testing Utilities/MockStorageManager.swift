//
//  MockStorageManager.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 22.07.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

@testable import RubbishFeature

//class MockStorageManager<T: Codable>: AnyStoragable<T> {
//
//    public let shouldReload: Bool
//
//    init(shouldReload: Bool = true) {
//        self.shouldReload = shouldReload
//        super.init()
//    }
//
//    override func lastReload(forKey key: String) -> Date? {
//        return nil
//    }
//
//    override func setLastReload(_ date: Date?, forKey key: String) {
//
//    }
//
//    override func shouldReload(interval: Double, forKey key: String) -> Bool {
//        return true
//    }
//
//    override func read(forKey key: String, with decoder: JSONDecoder) -> Signal<[T], Error> {
//
//        return Signal { observer in
//
//            return BlockDisposable {}
//
//        }
//
//    }
//
//    override func write(data: Data, forKey key: String) {
//
//    }
//
//}
