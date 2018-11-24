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
    func fetchAccountInfo(userId: String, completion:@escaping (ProfilData?, Error?)->())
    func fetchPostsByUser(userId: String, completion: @escaping (_ medias: [Post?], _ error: Error?) -> Void)
    func fetchComments(postId: String, completion: @escaping (_ medias: [Comment?], _ error: Error?) -> Void)

    func fetchFollowing(userId: String, completion: @escaping ([String], _ error: Error?)-> Void)
}

public class ParseDataAdapter {

    func setCurrentUser(_ user: PFUser) {
        CurrentAccount.shared().baseUserId = (user.objectId)!
        CurrentAccount.shared().baseUsername = (user.username)!
        CurrentAccount.shared().baseProfilePicture = user["profile_picture"] as? URL
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
                accountData = ProfilData(id: user.objectId ?? "xxxx", username: user.username ?? "default user", fullname: "", email: user.email ?? "email", profilePicture: user["profile_picture"] as? URL, bio: "")

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
                accountData = ProfilData(id: user.objectId ?? "xxxx", username: user.username ?? "default user", fullname: "", email: user.email ?? "email", profilePicture: user["profile_picture"] as? URL, bio: "")

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

    // MARK: get user data
    func fetchAccountInfo(userId: String, completion:@escaping (ProfilData?, Error?)->()) {

        var accountData: ProfilData = ProfilData()

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:userId)

            if let owner = try query?.getFirstObject() as? PFUser {

                let username = String(describing: owner.username ?? "")
                let fullName = String(describing: owner["full_name"] ?? "")
                let email = String(describing: owner.email ?? "")
                let bio = String(describing: owner["bio"] ?? "")

                var profileImgeURL: URL? = nil
                if let profileImageUrlString = (owner["profile_picture"] as? PFFile)?.url {
                    profileImgeURL = URL(string: profileImageUrlString)
                }

                accountData = ProfilData(id: owner.objectId!, username: username, fullname: fullName, email: email, profilePicture: profileImgeURL, bio: bio)

                completion(accountData, nil)
            }
        } catch {
            print("\(#function), get user's object failed from Parse server.")
            completion(nil, QNAError.getAccountInfoError)
        }
    }

    func fetchPostsByUser(userId: String, completion: @escaping (_ medias: [Post?], _ error: Error?) -> Void) {

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:userId)

            if let userData = try query?.getFirstObject() as? PFUser {

                let getImagesQuery = PFQuery(className: "Photos")

                getImagesQuery.whereKey("user", equalTo: userData)

                getImagesQuery.findObjectsInBackground(block: { (objects, error) in
                    if let error = error {
                        print("error:\(error)")
                        completion([], error)

                    } else if let posts = objects {

                        var list = [Post]()

                        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in

                            for post in posts {

                                var data: Post = Post()
                                data.id = post.objectId
                                data.userId = (post["user"] as? PFUser)?.objectId

                                data.username = userData.username
                                data.profileImageUrl = userData["profile_picture"] as? URL
                                data.createdTime = post.createdAt
                                data.imageUrls = [post["imageFile"] as? URL]

                                let group = DispatchGroup()
                                group.enter()

                                self.fetchComments(postId: post.objectId!, completion: { (objects, error) in
                                    if error == nil {
                                        data.comments = objects
                                    }
                                    group.leave()
                                })

                                group.wait()
                                list.append(data)
                            }

                            DispatchQueue.main.async {
                                completion(list, nil)
                            }
                        }
                    }
                })
            }

        } catch {
            print("\(#function), get User's object failed.")
        }

    }

    func fetchMedias(userId: String, completion: @escaping (_ success : Bool, _ medias: [URL], _ error: Error?) -> () ) {

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:userId)

            if let userData = try query?.getFirstObject() as? PFUser {

                let getImagesQuery = PFQuery(className: "Photos")

                getImagesQuery.whereKey("user", equalTo: userData)

                getImagesQuery.findObjectsInBackground(block: { (objects, error) in
                    if let error = error {
                        print("error:\(error)")
                        completion(false, [], error)

                    } else if let posts = objects {

                        var list = [URL]()

                        for post in posts {

                            if let imageFile = post["imageFile"] as? URL {
                                list.append(imageFile)
                            }
                        }

                        completion(true, list, nil)
                    }
                })
            }
        } catch {
            print("\(#function), get PFUser's object failed.")
        }

    }

    func fetchComments(postId: String, completion: @escaping (_ medias: [Comment?], _ error: Error?) -> Void) {
        var list = [Comment]()

        do {
            let postQuery = PFQuery(className: "Photos")
            postQuery.whereKey("objectId", equalTo: postId)

            let postObject = try postQuery.getFirstObject()
            let commentQuery = PFQuery(className: "Comments")
            commentQuery.whereKey("parent", equalTo: postObject)
            commentQuery.order(byAscending: "createdAt")

            commentQuery.findObjectsInBackground(block: { (objects, error) in
                if let error = error {
                    print("error:\(error)")
                    completion([], error)

                } else if let posts = objects {
                    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in

                        for post in posts {
                            var commData: Comment = Comment()

                            if let parent = post["parent"] as? PFObject {
                                commData.postId = parent.objectId
                            }

                            commData.text = post["text"] as? String

                            if let user = post["user"] as? PFObject,
                                let userId = user.objectId {
                                commData.userId = userId

                                let group = DispatchGroup()
                                group.enter()

                                self.fetchAccountInfo(userId: userId, completion: { (profileObject, error) in
                                    if let userData = profileObject {
                                        commData.username = userData.username
                                        commData.profileImageUrl = userData.profilePicture
                                    }
                                    group.leave()
                                })

                                group.wait()
                                list.append(commData)
                            }
                        }

                        DispatchQueue.main.async {
                            completion(list, nil)
                        }
                    }
                }
            })
        } catch {
            print("\(#function), Photos table: get object failed.")
        }
    }

    // MARK: - follow
    func fetchFollowing(userId: String, completion: @escaping ([String], _ error: Error?)-> Void) {
        var list: [String] = [String]()
        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:userId)

            if let followId = try query?.getFirstObject() as? PFUser {
                let query = PFQuery(className: "Following")
                query.whereKey("user", equalTo: followId)

                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            if let userObject = object["following"] as? PFUser {
                                list.append(userObject.objectId!)
                            }
                        }
                    }
                    completion(list, nil)
                })
            }
        } catch {
            completion([], QNAError.getFollowings)
            print("\(#function), get PFUser's object failed.")
        }
    }
}
