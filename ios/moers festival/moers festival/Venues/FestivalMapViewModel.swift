//
//  FestivalMapViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import UIKit
import Core
import MMEvents
import SwiftUI
import Combine
import Factory

@MainActor
class FestivalMapViewModel: StandardViewModel {
    
    @Published var places: [FestivalPlaceRowUi] = []
    
    private let placeRepository: PlaceRepository
    
    override init() {
        self.placeRepository = Container.shared.placeRepository()
        super.init()
    }
    
    public func load() {
        
        self.setupObserver()
        
//        self.placeRepository.data()
//            .map({
//                $0.map { (place: Place) in
//                    FestivalPlaceRowUi(
//                        id: place.id,
//                        name: place.name,
//                        description: "\(place.streetName ?? "") \(place.streetNumber ?? "")",
//                        timeInformation: nil
//                    )
//                }
//            })
//            .sink { (completion: Subscribers.Completion<Error>) in
//
//            } receiveValue: { (places: [FestivalPlaceRowUi]) in
//                print("Received places data")
//                self.places = places
//            }
//            .store(in: &cancellables)

        
//        self.placeRepository.refresh()
//
//        Task() {
//            do {
//
//                let places = try await placeRepository.fetch().map({ (place: Place) in
//                    FestivalPlaceRowUi(
//                        id: place.id,
//                        name: place.name,
//                        description: "\(place.streetName ?? "") \(place.streetNumber ?? "")",
//                        timeInformation: nil
//                    )
//                })
//
//                self.places = places
//
//            } catch {
//                print(error)
//            }
//        }
        
    }
    
    private func setupObserver() {
        
        placeRepository.changeObserver()
            .map({
                $0.map { (place: Place) in
                    FestivalPlaceRowUi(
                        id: place.id,
                        name: place.name,
                        description: "\(place.streetName ?? "") \(place.streetNumber ?? "")",
                        timeInformation: nil
                    )
                }
            })
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (places: [FestivalPlaceRowUi]) in
                print("Received places data")
                self.places = places
            }
            .store(in: &cancellables)
        
    }
    
    public func refresh() {
        
        self.placeRepository.refresh()
        
    }
    
}
