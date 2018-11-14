//
//  ParseApiTest.swift
//  InstagramTests
//
//  Created by Queena Huang on 9/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import XCTest
import Parse
@testable import Instagram

class ParseApiTest: XCTestCase {
    let dataAdapter = MockDataAdapter()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginResponse() {
        let expectation = self.expectation(description: "Login Response Parse Expectation")

//        parseDataAdapter.shouldReturnError = true

        dataAdapter.url = URL(fileURLWithPath: "GetLoginMember")
        
        dataAdapter.logIn("aaaa", password: "password") { (user, error) in
            XCTAssertNil(error)
            guard let user = user else {
                XCTFail()
                return
            }

            XCTAssertNotNil(user)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testSignUpResponse() {
        let expectation = self.expectation(description: "SignUp Response Parse Expectation")

//        parseDataAdapter.shouldReturnError = true

        dataAdapter.url = URL(fileURLWithPath: "GetLoginMember")

        dataAdapter.signUp("aaaa", password: "password") { (user, error) in
            XCTAssertNil(error)
            guard let user = user else {
                XCTFail()
                return
            }

            XCTAssertNotNil(user)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10.0, handler: nil)
    }

}
