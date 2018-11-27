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
        case accountInfo
        case getposts
        case getComments
        case getFollowing
        case getAllUsers
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
                    let data = json[FakeResponsesJson.object.rawValue] as? [String: Any] {

                    InstagramStub.fakeCurrentUser(data)

                    // to do
                    var accountData = ProfilData()
                    accountData = ProfilData(id: data["id"] as! String , username: data["user"] as! String, fullname: "", email: data["email"] as! String, profilePicture: nil, bio: "")
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
                    let data = json[FakeResponsesJson.object.rawValue] as? [String: Any] {

                    InstagramStub.fakeCurrentUser(data)

                    // to do
                    var accountData = ProfilData()
                    accountData = ProfilData(id: data["id"] as! String, username: data["user"] as! String , fullname: "", email: data["email"] as! String , profilePicture: nil, bio: "")
                    completion(accountData, nil)
                } else {
                    completion(nil, fakeResponse.error)
                }
            } else {
                completion(nil, QNAError.logingError(comment: "No FakeResponses data"))
            }
        }
    }

    func logOut() {

    }
    
    // MARK: get user data
    func fetchAccountInfo(userId: String, completion: @escaping (ProfilData?, Error?) -> ()) {

        if shouldReturnError {
            completion(nil, MockServiceError.accountInfo)
        } else {

            let api = "GetAccountInfo"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let data = json[FakeResponsesJson.object.rawValue] as? [ProfilData] {

                    completion(data.first, nil)
                } else {
                    completion(nil, fakeResponse.error)
                }
            } else {
                completion(nil, QNAError.getAccountInfoError)
            }
        }
    }

    func fetchPostsByUser(userId: String, completion: @escaping (_ medias: [Post?], _ error: Error?) -> Void) {

        if shouldReturnError {
            completion([], MockServiceError.getposts)
        } else {
            let api = "GetPosts"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let list = json[FakeResponsesJson.object.rawValue] as? [Post] {

                    completion(list, nil)
                } else {
                    completion([], fakeResponse.error)
                }
            } else {
                completion([], QNAError.getPosts)
            }
        }
    }

    func fetchComments(postId: String, completion: @escaping (_ medias: [Comment?], _ error: Error?) -> Void) {

        if shouldReturnError {
            completion([], MockServiceError.getComments)
        } else {
            let api = "GetComments"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let list = json[FakeResponsesJson.object.rawValue] as? [Comment] {

                    let results = list.filter { $0.postId == postId }
                    
                    completion(results, nil)
                } else {
                    completion([], fakeResponse.error)
                }
            } else {
                completion([], QNAError.getPosts)
            }
        }
    }

    // MARK: - follow
    func fetchFollowing(userId: String, completion: @escaping ([String], _ error: Error?)-> Void) {
        if shouldReturnError {
            completion([], MockServiceError.getFollowing)
        } else {
            let api = "GetFollowing"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let list = json[FakeResponsesJson.object.rawValue] as? [String] {

                    completion(list, nil)
                } else {
                    completion([], fakeResponse.error)
                }
            } else {
                completion([], QNAError.getFollowings)
            }
        }
    }

    func fetchAllUser(completion: @escaping ([ProfilData], Error?)-> Void) {
        if shouldReturnError {
            completion([], MockServiceError.getAllUsers)
        } else {
            let api = "GetAllUsers"
            if let fakeResponse = FakeResponses.sharedInstance.responseMatching(api) {
                if let json = fakeResponse.json,
                    let list = json[FakeResponsesJson.object.rawValue] as? [ProfilData] {

                    completion(list, nil)
                } else {
                    completion([], fakeResponse.error)
                }
            } else {
                completion([], QNAError.getAllUsers)
            }
        }
    }

    func addFollowing(id: String, completion: @escaping (Error?)-> Void) {
        completion(nil)
    }

    func deleteFollowing(id: String, completion: @escaping (Error?)-> Void) {
        completion(nil)
    }

    func addMedia(info: [String: AnyObject], completion: @escaping (Error?)-> Void) {
        completion(nil)
    }

    func addComment(data: [String: String], completion: @escaping (Error?)-> Void) {
        completion(nil)
    }

    func updateProfile(_ info: [Profile], _ profileImageData: Data?, completion: @escaping (Error?)-> Void) {
        completion(nil)
    }
}
