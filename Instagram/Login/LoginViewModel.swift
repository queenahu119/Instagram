//
//  LoginViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 6/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class LoginViewModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }

    func initFetch() {
    }

    //MARK: - callback
    var reloadPhotoListViewClosure: (()->())?
    var reloadUserClosure: (()->())?
    var showAlertClosure: ((_ title: String, _ message: String)->())?
    var updateLoadingStatus: (()->())?

    func isLogin() -> Bool {
        let ret = dataManager.isUserLogin()
        return ret
    }

    func signUp(data: [String: String], performSegue: @escaping ()->(), showAlert: @escaping (_ title: String, _ message: String)->()) {

        guard let username = data["username"] else {
            return
        }
        guard let password = data["password"] else {
            return
        }

        dataManager.signUp(username, password: password) { (success, error) in
            if let error = error {
                showAlert("Could not sign you up", error.localizedDescription)
            } else {
                performSegue()
            }
        }
    }

    func logIn(data: [String: String], performSegue: @escaping ()->(), showAlert: @escaping (_ title: String, _ message: String)->()) {

        guard let username = data["username"] else {
            return
        }
        guard let password = data["password"] else {
            return
        }

        dataManager.logIn(username, password: password) { (success, error) in
            if success {
                performSegue()
            } else {
                if let error = error {
                    showAlert(error.localizedDescription , "Hello")
                }
            }
        }
    }

}
