//
//  MockDataAdapter.swift
//  InstagramTests
//
//  Created by Queena Huang on 9/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

class MockDataAdapter {
    var shouldReturnError = false
    var loginWasCalled = false
    var signupWasCalled = false

    enum MockServiceError: Error {
        case login
        case signup
    }

    func reset() {
        shouldReturnError = false
        loginWasCalled = false
        signupWasCalled = false
    }

    convenience init() {
        self.init(false)
    }

    init(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
}

extension MockDataAdapter: DataAdapterProtocol {

    func isUserLogin() -> Bool {
        let api = "GetLogin"
        if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
            return fakeResponse.isLogin
        }
        return false
    }

    func signUp(_ username: String, password: String, completion: @escaping (ProfilData?, Error?) -> ()) {
        signupWasCalled = true

        if shouldReturnError {
            completion(nil, MockServiceError.signup)
        } else {

            let api = "GetSignUpMember"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let data = json[FakeResponsesJson.signup.rawValue] as? [String: String] {

                    InstagramStub.fakeCurrentUser(data)

                    // to do
                    var accountData = ProfilData()
                    accountData = ProfilData(id: data["id"] ?? "", username: data["user"] ?? "", fullname: "", email: data["email"] ?? "", profilePicture: nil, bio: "")
                    completion(accountData, nil)
                } else {
                    completion(nil, fakeResponse.error)
                }
            } else {
                completion(nil, QNAError.logingError(comment: "No FakeResponses data"))
            }
        }
    }

    func logIn(_ username: String, password: String, completion: @escaping (ProfilData?, Error?) -> ()) {
        loginWasCalled = true

        if shouldReturnError {
            completion(nil, MockServiceError.login)
        } else {

            let api = "GetLoginMember"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let data = json[FakeResponsesJson.login.rawValue] as? [String: String] {

                    InstagramStub.fakeCurrentUser(data)

                    // to do
                    var accountData = ProfilData()
                    accountData = ProfilData(id: data["id"] ?? "", username: data["user"] ?? "", fullname: "", email: data["email"] ?? "", profilePicture: nil, bio: "")
                    completion(accountData, nil)
                } else {
                    completion(nil, fakeResponse.error)
                }
            } else {
                completion(nil, QNAError.logingError(comment: "No FakeResponses data"))
            }
        }
    }
}
