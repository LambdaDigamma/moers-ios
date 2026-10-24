//
//  NowPlayableError.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation

/// `NowPlayableError` declares errors specific to the NowPlayable protocol.
public enum NowPlayableError: LocalizedError {
    
    case noRegisteredCommands
    case cannotSetCategory(Error)
    case cannotActivateSession(Error)
    case cannotReactivateSession(Error)
    
    public var errorDescription: String? {
        
        switch self {
                
            case .noRegisteredCommands:
                return String(localized: "At least one remote command must be registered.", bundle: .module)
                
            case .cannotSetCategory(let error):
                return String(localized: "The audio session category could not be set:\n\(error.localizedDescription)", bundle: .module)
                
            case .cannotActivateSession(let error):
                return String(localized: "The audio session could not be activated:\n\(error.localizedDescription)", bundle: .module)
                
            case .cannotReactivateSession(let error):
                return String(localized: "The audio session could not be resumed after interruption:\n\(error.localizedDescription)", bundle: .module)
                
        }
        
    }
    
}
