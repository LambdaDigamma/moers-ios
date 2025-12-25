//
//  Start.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Darwin
import Foundation
import ModernNetworking
import Combine
import EFAAPI

print("Enter a search term…")

guard let searchTerm = readLine(), !searchTerm.isEmpty else {
    exit(EXIT_FAILURE)
}

var cancellables = Set<AnyCancellable>()
let transitService = DefaultTransitService(loader: DefaultTransitService.defaultLoader())

print("Searching for term \(searchTerm)")

transitService.findTransitLocation(for: searchTerm, filtering: [])
    .sink { (completion: Subscribers.Completion<HTTPError>) in
        
        switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                exit(EXIT_FAILURE)
            default:
                break
        }
        
    } receiveValue: { (transitLocations: [TransitLocation]) in
        
        transitLocations.forEach { (location: TransitLocation) in
            print("\(location.name): \(location.statelessIdentifier)")
        }
        
        exit(EXIT_SUCCESS)
        
    }
    .store(in: &cancellables)


RunLoop.current.run()
