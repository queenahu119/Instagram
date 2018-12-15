//
//  PostViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 8/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation

class PostViewModel: NSObject {

    //MARK: - callback
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var postAfterCompletion: ((Bool, String?, String?)->())?

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
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

        DispatchQueue.global().async { [weak self] in
            self?.dataManager.addMedia(info: info) { [weak self] (error) in

                DispatchQueue.main.async {
                    self?.isLoading = false
                    if error == nil {
                        self?.postAfterCompletion!(true, "Image Posted!", "Your image have been posted sucessfully.")
                    } else {
                        self?.postAfterCompletion!(false, "Image Could Not Be Posted!", "Please try again later.")
                    }
                }
            }
        }

    }
}


