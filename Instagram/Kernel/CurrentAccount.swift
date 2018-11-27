//
//  CurrentAccount.swift
//  Instagram
//
//  Created by QueenaHuang on 2/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

class CurrentAccount {

    // MARK: - Properties
    private static var sharedCurrentAccount: CurrentAccount = {
        let currentAccount = CurrentAccount()

        return currentAccount
    }()

    // MARK: -

    var baseUserId: String?
    var baseUsername: String?
    var baseProfilePicture: URL?

    // Initialization

    fileprivate init() {
        self.baseUserId = ""
        self.baseUsername = ""
        self.baseProfilePicture = nil
    }

    private init(baseUserId: String, baseUsername: String) {
        self.baseUserId = baseUserId
        self.baseUsername = baseUsername
    }

    // MARK: - Accessors

    class func shared() -> CurrentAccount {
        return sharedCurrentAccount
    }

}
