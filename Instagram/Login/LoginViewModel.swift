//
//  LoginViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 6/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit
import Parse

class LoginViewModel: NSObject {

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    var currentUser = PFUser.current()

    override init() {

    }

    func initFetch() {
    }

    //MARK: - callback
    var reloadPhotoListViewClosure: (()->())?
    var reloadUserClosure: (()->())?
    var showAlertClosure: ((_ title: String, _ message: String)->())?
    var updateLoadingStatus: (()->())?

    func isLogin() -> Bool {
        if (currentUser != nil) {

            let user = currentUser
            CurrentAccount.shared().baseUserId = (user?.objectId)!
            CurrentAccount.shared().baseUsername = (user?.username)!
            CurrentAccount.shared().baseProfilePicture = user!["profile_picture"] as? PFFile

            return true
        } else {
            return false
        }
    }

    func signUp(data: [String: String], performSegue: @escaping ()->(), showAlert: @escaping (_ title: String, _ message: String)->()) {

        let user = PFUser()

        guard let username = data["username"] else {
            return
        }
        guard let password = data["password"] else {
            return
        }
        user.username = username
        user.password = password


        user.signUpInBackground(block: { (success, error) in

            self.isLoading = false

            if let error = error {

                showAlert("Could not sign you up", error.localizedDescription)

            } else {
                print("Sign up!")

                performSegue()
            }
        })
    }

    func logIn(data: [String: String], performSegue: @escaping ()->(), showAlert: @escaping (_ title: String, _ message: String)->()) {

        guard let username = data["username"] else {
            return
        }
        guard let password = data["password"] else {
            return
        }

        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            self.isLoading = false

            if let user = user {
                print("Log In Successful")

                CurrentAccount.shared().baseUserId = (user.objectId)!
                CurrentAccount.shared().baseUsername = (user.username)!
                CurrentAccount.shared().baseProfilePicture = user["profile_picture"] as? PFFile
                
                performSegue()

            } else {
                var errorText = "Unknown Error: Please try again!"

                if let error = error {
                    errorText = error.localizedDescription
                }
                showAlert("Could not sign you up", errorText)

            }
        }
    }

}
