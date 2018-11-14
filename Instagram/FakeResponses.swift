//
//  FakeResponses.swift
//  Instagram
//
//  Created by Queena Huang on 12/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

enum FakeResponsesJson: String {
    case login
    case signup

}

class FakeResponses {
    static let sharedInstance = FakeResponses()
    fileprivate init() {}

    fileprivate var responses: [FakeResponse] = []

    func clearResonses() {
        responses = []
    }

    func addResponse(_ response: FakeResponse) {
        responses.append(response)
    }

    func responseMatching(_ url: String) -> FakeResponse? {
        return responses.filter { response in
            return url.range(of: response.pattern, options: .regularExpression) != nil
            }.first
    }
}

struct FakeResponse {
    let pattern: String
    let code: Int
    let json: [String: Any]?
    let error: NSError?
    let delay: TimeInterval
    let isLogin: Bool

    init(pattern: String, code: Int = 200, json: [String: Any]? = nil, error: NSError? = nil, delay: TimeInterval = 0, isLogin: Bool = false) {
        self.pattern = pattern
        self.code = code
        self.json = json
        self.error = error
        self.delay = delay
        self.isLogin = isLogin
    }
}
