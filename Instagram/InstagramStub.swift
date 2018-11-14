//
//  InstagramStub.swift
//  Instagram
//
//  Created by Queena Huang on 12/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

struct InstagramStub {
    static func detectAndConfigure() {
        if detect() {
            print("Using stub API")
            configure()
        }
    }

    static func detect() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("USE_STUB_API")
    }

    static func delay() -> TimeInterval {
        if ProcessInfo.processInfo.arguments.contains("SUPRESS_API_DELAY") {
            print("Supressing delay in stub API responses")
            return 0
        } else {
            print("Using delay of 1 second in stub API responses")
            return 1
        }
    }

    static func fakeCurrentUser(_ json: [String: Any]) {
        CurrentAccount.shared().baseUserId = json["id"] as! String
        CurrentAccount.shared().baseUsername = json["user"] as! String
    }

    static func configure() {
        let mockDataAdapter = MockDataAdapter()
        mockDataAdapter.url = URL(fileURLWithPath: "GetLoginMember")
        DataAdapterFactory.sharedInstance.testDataAdapter = mockDataAdapter

        let responses = FakeResponses.sharedInstance

        responses.addResponse(
            FakeResponse(pattern: ".*GetLoginMember.*", json: [
                FakeResponsesJson.login.rawValue:
                    [ "user": "bbbb",
                      "id": "1111",
                      "email": "bbbb@gamil.com"],
                FakeResponsesJson.signup.rawValue:
                    [ "user": "cccc",
                      "id": "2222",
                      "email": "cccc@gamil.com"]
                ], isLogin: false))

    }

}
