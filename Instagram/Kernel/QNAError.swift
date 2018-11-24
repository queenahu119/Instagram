//
//  QNAError.swift
//  Instagram
//
//  Created by Queena Huang on 6/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

public enum QNAError: Error {
    case logingError(comment: String?)
    case signupError(comment: String?)
    case getAccountInfoError
    case getPosts
    case getComments
    case getFollowings
}

extension QNAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .logingError(comment: let comment):
            return NSLocalizedString("Could not log in. \(String(describing: comment ?? ""))", comment: comment ?? "")
        case .signupError(comment: let comment):
            return NSLocalizedString("Could not sign you up. \(comment ?? "")", comment: comment ?? "")
        case .getAccountInfoError:
            return NSLocalizedString("Could not get account information. ", comment: "")
        case .getPosts:
            return NSLocalizedString("Could not get posts. ", comment: "")
        case .getComments:
            return NSLocalizedString("Could not get comments. ", comment: "")
        case .getFollowings:
            return NSLocalizedString("Could not get followings. ", comment: "")
        }

    }
}
