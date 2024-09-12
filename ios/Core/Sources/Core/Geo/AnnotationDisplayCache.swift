//
//  AnnotationDisplayCache.swift
//  
//
//  Created by Lennart Fischer on 12.05.22.
//

import Foundation

public class AnnotationDisplayCache {
    
    private var annotationStore: [String: Bool]
    
    public init(initalValues: [String: Bool] = [:]) {
        self.annotationStore = initalValues
    }
    
    /// Returns if the map is already showing annotations of the given type.
    ///
    /// - Parameter key: annotation type key
    /// - Returns: if the annotation type is in the store
    public func isShowingAnnotations(for key: String) -> Bool {
        
        if let isShowing = annotationStore[key] {
            return isShowing
        }
        
        return false
        
    }
    
    public func setShowingAnnotations(_ value: Bool, for key: String) {
        annotationStore[key] = value
    }
    
}

