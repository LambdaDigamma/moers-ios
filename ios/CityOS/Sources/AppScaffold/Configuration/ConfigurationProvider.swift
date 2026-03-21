//
//  ConfigurationProvider.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

import Foundation
import Combine


public class ConfigurationProvider<Configuration: AppConfigurable> {

    @Published public private(set) var configuration: Configuration
    
    private let localConfigurationLoader: AnyLocalConfigurationLoader<Configuration>
    private let remoteConfigurationLoader: AnyRemoteConfigurationLoader<Configuration>
    
    public init(remoteConfigurationLoader: AnyRemoteConfigurationLoader<Configuration>,
         localConfigurationLoader: AnyLocalConfigurationLoader<Configuration>) {

        self.remoteConfigurationLoader = remoteConfigurationLoader
        self.localConfigurationLoader = localConfigurationLoader

        self.configuration = localConfigurationLoader.fetch()
    }
    
    public convenience init<RemoteLoader: RemoteConfigurationLoading, LocalLoader: LocalConfigurationLoading>(
        remoteLoader: RemoteLoader, localLoader: LocalLoader
    ) where RemoteLoader.Configuration == Configuration, LocalLoader.Configuration == Configuration {
        self.init(remoteConfigurationLoader: AnyRemoteConfigurationLoader(wrappedLoader: remoteLoader),
                  localConfigurationLoader: AnyLocalConfigurationLoader(wrappedLoader: localLoader))
    }
    
    private var cancellable: AnyCancellable?
    private var syncQueue = DispatchQueue(label: "config_queue_\(UUID().uuidString)")

    public func updateConfiguration() {

        syncQueue.sync {

            guard self.cancellable == nil else {
                return
            }

            self.cancellable = self.remoteConfigurationLoader.fetch()
                .sink(receiveCompletion: { completion in
                    self.cancellable = nil // clear cancellable so we could start a new load
                }, receiveValue: { [weak self] newConfiguration in
                    self?.configuration = newConfiguration
                    self?.localConfigurationLoader.persist(newConfiguration)
                })

        }

    }
    
}
