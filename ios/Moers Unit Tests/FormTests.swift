//
//  FormTests.swift
//  Moers Unit Tests
//
//  Created by Lennart Fischer on 04.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import Core
@testable import MapFeature
@testable import Moers

@MainActor
class FormTests: XCTestCase {

    var form: Form!
    var errorBag: ErrorBag!
    
    override func setUp() async throws {
        try await super.setUp()
        self.form = Form()
        self.errorBag = ErrorBag(
            message: "There are errors.",
            errors: [
                "url": [
                    "The format is incorrect."
                ]
            ])
    }

    override func tearDown() async throws {
        self.form = nil
    }
    
    public func testReceivingErrors() async {
        
        form.receivedError(errorBag: errorBag)

        XCTAssertEqual(errorBag, form.errorBag)
        
    }
    
    public func testDisplaymentOfErrorsAfterReceivingError() async {
        
        let formViewMock = FormViewMock()
        let formKey = "url"

        form.registerView(for: formKey, view: formViewMock)
        form.receivedError(errorBag: errorBag)

        XCTAssertEqual(formViewMock.errors, errorBag.errors[formKey])
        
    }
    
}

class FormViewMock: FormView {
    
    var errors: [String] = []

    func displayErrors(_ errors: [String]) {
        self.errors = errors
    }
    
    func currentData() -> Codable {
        return ["testData": "test"]
    }
    
}
