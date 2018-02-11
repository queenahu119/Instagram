//
//  PostViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 8/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse


class PostViewModel: NSObject {

    //MARK: - callback
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var postAfterCompletion: ((Bool, String?, String?)->())?


    let dataManager : DataManagerProtocol

    init(dataManager: DataManagerProtocol = DataManager()) {
        self.dataManager = dataManager
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    func initFetch() {

    }

    func postMedia(info: [String: AnyObject]) {

        self.isLoading = true

        dataManager.addMedia(info: info) { [weak self] (success) in
            self?.isLoading = false

            if (success) {

                self?.postAfterCompletion!(success, "Image Posted!", "Your image have been posted sucessfully.")
            } else {

                self?.postAfterCompletion!(success, "Image Could Not Be Posted!", "Please try again later.")
            }
        }

    }
}


