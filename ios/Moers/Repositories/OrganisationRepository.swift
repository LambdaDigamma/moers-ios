//
//  OrganisationRepository.swift
//  Moers
//
//  Created by Lennart Fischer on 20.07.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import Combine
import Factory
import ModernNetworking
import MMAPI

@available(iOS 13.0, *)
class BaseOrganisationRepository {
    @Published var organisations = Resource<[Organisation]>.loading
}

@available(iOS 13.0, *)
protocol OrganisationRepository: BaseOrganisationRepository {
    
}

extension Organisation: Model {
    
    public static var decoder: JSONDecoder {
        
        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
        
    }
    
}

@available(iOS 13.0, *)
class RemoteOrganisationRepository: BaseOrganisationRepository, OrganisationRepository, ObservableObject {
    
    private let api: API
    
    @Injected(\.httpLoader) private var loader: HTTPLoader
    
    init(api: API? = nil) {
        self.api = api ?? API(loader: loader)
        super.init()
        self.loadData()
    }
    
    private var organisationsCancellable: AnyCancellable?
    
    private func loadData() {
        
        var r = HTTPRequest()
        r.path = "/api/v2/organisations"
        
        let organisations: AnyPublisher<[Organisation], HTTPError> = api.sendRequestCombine(r)
        
        print(r)
        
        organisationsCancellable = organisations
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .mapError { error -> Error in
                print(error.underlyingError)
                return error
            }
            .replaceError(with: [])
            .sink { [weak self] organisations in
                print(organisations)
                self?.organisations = Resource.success(organisations)
            }
        
    }
    
}
