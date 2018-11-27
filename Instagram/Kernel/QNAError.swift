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
    case getAllUsers
    case deleteFollowing(comment: String?)
    case addFollowing(comment: String?)
    case addMedia(comment: String?)
    case addComment(comment: String?)
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
        case .getAllUsers:
            return NSLocalizedString("Could not get all users. ", comment: "")
        case .deleteFollowing(comment: let comment):
            return NSLocalizedString("Delete followings failed. ", comment: comment ?? "")
        case .addFollowing(comment: let comment):
            return NSLocalizedString("Add followings failed ", comment: comment ?? "")
        case .addMedia(comment: let comment):
            return NSLocalizedString("Add media failed ", comment: comment ?? "")
        case .addComment(comment: let comment):
            return NSLocalizedString("Add comment failed ", comment: comment ?? "")
        }

    }
}
