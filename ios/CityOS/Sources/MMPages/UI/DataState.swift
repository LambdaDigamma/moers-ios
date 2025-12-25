//
//  DataState.swift
//  
//
//  Created by Lennart Fischer on 04.01.22.
//

import Foundation

public enum DataState<D, E: Error> {
    
    case loading
    case success(D)
    case error(E)
    
}

extension DataState {
    
    public var loading: Bool {
        
        if case .loading = self {
            return true
        }
        
        return false
        
    }
    
    public var error: E? {
        
        switch self {
            case .error(let error):
                return error
            default:
                return nil
        }
        
    }
    
    public var value: D? {
        
        switch self {
            case .success(let value):
                return value
            default:
                return nil
        }
        
    }
    
}

#if canImport(SwiftUI)

import SwiftUI

@available(OSX 10.15, *)
@available(iOS 13.0, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
public extension DataState {
    
    /**
     Transform a `Resource<D>` to a `Resource<D>`
     */
    func transform<S>(_ transform: @escaping (D) -> S) -> DataState<S, E> {
        switch self {
            case .loading:
                return .loading
            case .error(let error):
                return .error(error)
            case .success(let value):
                return .success(transform(value))
        }
    }
    
    func isLoading<Content: View>(@ViewBuilder content: @escaping () -> Content) -> Content? {
        
        if loading {
            return content()
        }
        
        return nil
    }
    
    func hasResource<Content: View>(@ViewBuilder content: @escaping (D) -> Content) -> Content? {
        if let value = value {
            return content(value)
        }
        
        return nil
    }
    
    func hasError<Content: View>(@ViewBuilder content: @escaping (E) -> Content) -> Content? {
        
        if let error = error {
            return content(error)
        }
        
        return nil
    }
}

#endif
