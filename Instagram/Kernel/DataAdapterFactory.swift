//
//  DataAdapterFactory.swift
//  Instagram
//
//  Created by Queena Huang on 8/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

class DataAdapterFactory {
    static let sharedInstance = DataAdapterFactory()
    fileprivate init() {}

    var defaultDataAdapter: DataAdapterProtocol {
        return ParseDataAdapter()
    }

    var testDataAdapter: DataAdapterProtocol? = nil

    var dataAdapter: DataAdapterProtocol {
        return testDataAdapter ?? defaultDataAdapter
    }
}
