//
//  LocalConfigurationLoading.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

import Foundation
import Combine

public protocol LocalConfigurationLoading {
    
    associatedtype Configuration
    
    func fetch() -> Configuration
    func persist(_ configuration: Configuration)
    
}

public class AnyLocalConfigurationLoader<Configuration>: LocalConfigurationLoading {
    
    private let _fetch: () -> Configuration
    private let _persist: (_ configuration: Configuration) -> ()
    
    public init<Loader: LocalConfigurationLoading>(wrappedLoader: Loader) where Loader.Configuration == Configuration {
        _fetch = wrappedLoader.fetch
        _persist = wrappedLoader.persist
    }
    
    public func fetch() -> Configuration {
        _fetch()
    }
    
    public func persist(_ configuration: Configuration) {
        _persist(configuration)
    }
}

public class DefaultLocalConfigurationLoader<Configuration: AppConfigurable>: LocalConfigurationLoading {
    
    /// Save your configuration json file in your project which is bundled into your app.
    /// Defaults to `config.json`.
    public let configurationFileName: String
    
    public init(configurationFileName: String = "config.json") {
        self.configurationFileName = configurationFileName
    }
    
    private var cachedConfigUrl: URL? {

        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        return documentsUrl.appendingPathComponent(configurationFileName)
    }

    private var cachedConfig: Configuration? {
        let jsonDecoder = JSONDecoder()

        guard let configUrl = cachedConfigUrl,
              let data = try? Data(contentsOf: configUrl),
              let config = try? jsonDecoder.decode(Configuration.self, from: data) else {
            return nil
        }

        return config
    }

    public var defaultConfig: Configuration {

        let jsonDecoder = JSONDecoder()

        guard let url = Bundle.main.url(forResource: configurationFileName.replacingOccurrences(of: ".json", with: ""), withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Bundle must include default config. Check and correct this mistake.")
        }
        
        do {
            
            let config = try jsonDecoder.decode(Configuration.self, from: data)
            
            return config
            
        } catch let error as DecodingError {
            print(error)
            fatalError("Decoding failed.")
        } catch {
            fatalError("Decoding failed.")
        }
        
    }

    public func fetch() -> Configuration {

        if let cachedConfig = self.cachedConfig {
            return cachedConfig
        } else {
            let config = self.defaultConfig
            persist(config)
            return config
        }

    }

    public func persist(_ config: Configuration) {

        guard let configUrl = cachedConfigUrl else {
            // should never happen, you might want to handle this
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(config)
            try data.write(to: configUrl)
        } catch {
            // you could forward this error somewhere
            print(error)
        }

    }
    
}
