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
}

extension QNAError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .logingError(comment: let comment):
            return NSLocalizedString("Could not log in. \(String(describing: comment ?? ""))", comment: comment ?? "")
        case .signupError(comment: let comment):
            return NSLocalizedString("Could not sign you up. \(comment ?? "")", comment: comment ?? "")
        }
    }
    public var failureReason: String? {
        switch self {
        case .logingError(comment: let comment):
            return NSLocalizedString("I don't know why.", comment: comment ?? "")
        case .signupError(comment: let comment):
            return NSLocalizedString("I don't know why.", comment: comment ?? "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .logingError(comment: let comment):
            return NSLocalizedString("Please try again!", comment: comment ?? "")
        case .signupError(comment: let comment):
            return NSLocalizedString("Please try again!", comment: comment ?? "")
        }
    }
}
