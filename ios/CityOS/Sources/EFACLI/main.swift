//
//  Start.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Darwin
import Foundation
import ModernNetworking
import EFAAPI

print("Enter a search term…")

guard let searchTerm = readLine(), !searchTerm.isEmpty else {
    exit(EXIT_FAILURE)
}

let transitService = DefaultTransitService(
    loader: DefaultTransitService.defaultLoader()
)

print("Searching for term \(searchTerm)")

Task {
    do {
        let transitLocations = try await transitService.findTransitLocation(
            for: searchTerm,
            filtering: []
        )
        
        for location in transitLocations {
            print("\(location.name): \(location.statelessIdentifier)")
        }
        
        exit(EXIT_SUCCESS)
    } catch {
        print(error.localizedDescription)
        exit(EXIT_FAILURE)
    }
}

RunLoop.current.run()
