//
//  ParseDataAdapter.swift
//  Instagram
//
//  Created by Queena Huang on 8/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

protocol DataAdapterProtocol {
    func isUserLogin() -> Bool 
    func signUp(_ username: String, password: String, completion: @escaping (ProfilData?, Error?)-> ())
    func logIn(_ username: String, password: String, completion: @escaping (ProfilData?, Error?)-> ())
}

public class ParseDataAdapter {

    func setCurrentUser(_ user: PFUser) {
        CurrentAccount.shared().baseUserId = (user.objectId)!
        CurrentAccount.shared().baseUsername = (user.username)!
        CurrentAccount.shared().baseProfilePicture = user["profile_picture"] as? PFFile
    }

    func isUserLogin() -> Bool {
        if let currentUser = PFUser.current() {
            self.setCurrentUser(currentUser)
            return true
        } else {
            return false
        }
    }

}

extension ParseDataAdapter: DataAdapterProtocol {
    
    func signUp(_ username: String, password: String, completion: @escaping (ProfilData?, Error?)-> ()) {
        let user = PFUser()
        user.username = username
        user.password = password

        user.signUpInBackground { (success, error) in

            if success {
                // to do
                var accountData = ProfilData()
                accountData = ProfilData(id: user.objectId ?? "xxxx", username: user.username ?? "default user", fullname: "", email: user.email ?? "email", profilePicture: user["profile_picture"] as? PFFile, bio: "")

                completion(accountData, error)
            } else {
                completion(nil, error)
            }
        }
    }

    func logIn(_ username: String, password: String, completion: @escaping (ProfilData?, Error?)-> ()) {

        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in

            if let user = user {
                self.setCurrentUser(user)

                // to do
                var accountData = ProfilData()
                accountData = ProfilData(id: user.objectId ?? "xxxx", username: user.username ?? "default user", fullname: "", email: user.email ?? "email", profilePicture: user["profile_picture"] as? PFFile, bio: "")

                completion(accountData, nil)
            } else {
                var errorObj = QNAError.logingError(comment: nil) as QNAError

                if let error = error {
                    let message = error.localizedDescription
                    errorObj = QNAError.logingError(comment: message)
                }


                completion(nil, errorObj)
            }
        }
    }
}
