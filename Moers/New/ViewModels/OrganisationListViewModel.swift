//
//  OrganisationListViewModel.swift
//  Moers
//
//  Created by Lennart Fischer on 20.07.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import Combine
import Resolver
import ModernNetworking
import MMAPI

@available(iOS 13.0, *)
class OrganisationListViewModel: ObservableObject {
    
    
    @Published var organisationRepository: OrganisationRepository
    @Published var organisations = UIResource<[Organisation]>.loading
    
    private var cancellables = Set<AnyCancellable>()
    
    init(organisationRepository: OrganisationRepository = Resolver.resolve()) {
        
        self.organisationRepository = organisationRepository
        
        organisationRepository.$organisations
        .assign(to: \.organisations, on: self)
        .store(in: &cancellables)
        
    }
    
    
}
