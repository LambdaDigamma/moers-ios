//
//  NewsLoader.swift
//
//
//  Created by Lennart Fischer on 10.06.21.
//

import Foundation

public protocol NewsLoader {

    func fetchEntry() async throws -> NewsEntry

}
