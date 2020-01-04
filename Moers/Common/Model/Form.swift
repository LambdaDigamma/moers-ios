//
//  Form.swift
//  Moers
//
//  Created by Lennart Fischer on 04.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import MMAPI

protocol FormView {
    
    func displayErrors(_ errors: [String])
    
    func currentData() -> Codable
    
}

class Form {
    
    public var keyedViews: [String: FormView] = [:]
    public private(set) var errorBag: ErrorBag?
    
    public func registerView(for key: String, view: FormView) {
        keyedViews[key] = view
    }
    
    public func keyedValues() -> [String: Codable] {
        
        let keyedValues = keyedViews.mapValues { $0.currentData() }
        
        return keyedValues
        
    }
    
    internal func receivedError(errorBag: ErrorBag) {
        
        self.errorBag = errorBag
        self.displayErrorsInViews()
        
    }
    
    internal func displayErrorsInViews() {
        
        guard let errorBag = errorBag else { return }
        
        for (key, errors) in errorBag.errors {
            keyedViews[key]?.displayErrors(errors)
        }
        
    }
    
}
