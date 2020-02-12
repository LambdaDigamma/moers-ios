//
//  FormTests.swift
//  MoersTests
//
//  Created by Lennart Fischer on 04.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import XCTest
@testable import MMAPI
@testable import Moers

class FormTests: XCTestCase {

    var form: Form!
    var errorBag: ErrorBag!
    
    override func setUp() {
        self.form = Form()
        self.errorBag = ErrorBag(
            message: "There are errors.",
            errors: [
                "url": [
                    "The format is incorrect."
                ]
            ])
    }

    override func tearDown() {
        self.form = nil
    }
    
    public func testReceivingErrors() {
        
        form.receivedError(errorBag: errorBag)

        XCTAssertEqual(errorBag, form.errorBag)
        
    }
    
    public func testDisplaymentOfErrorsAfterReceivingError() {
        
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
