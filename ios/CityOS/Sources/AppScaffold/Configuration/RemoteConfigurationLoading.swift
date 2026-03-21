//
//  RemoteConfigLoading.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

import Foundation
import Combine

public protocol RemoteConfigurationLoading {

    associatedtype Configuration

    func fetch() -> AnyPublisher<Configuration, Error>
    
}

public class AnyRemoteConfigurationLoader<Configuration>: RemoteConfigurationLoading {
    
    private let _fetch: () -> AnyPublisher<Configuration, Error>
    
    public init<Loader: RemoteConfigurationLoading>(wrappedLoader: Loader) where Loader.Configuration == Configuration {
        _fetch = wrappedLoader.fetch
    }
    
    public func fetch() -> AnyPublisher<Configuration, Error> {
        return _fetch()
    }
    
}

public class DefaultRemoteConfigurationLoader<Configuration: AppConfigurable>: RemoteConfigurationLoading {
    
    public let configurationURL: URL
    
    public init(configurationURL: URL) {
        self.configurationURL = configurationURL
    }
    
    public func fetch() -> AnyPublisher<Configuration, Error> {
        return URLSession.shared.dataTaskPublisher(for: configurationURL)
            .map(\.data)
            .decode(type: Configuration.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
}
