//
//  DataManager.swift
//  Instagram
//
//  Created by QueenaHuang on 3/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

protocol DataManagerProtocol {

    func fetchImage(imageFile: PFFile, completion:@escaping (UIImage?, URLResponse?, Error?)->())
    func fetchAllUser(completion: @escaping ([ProfilData])-> Void)
    func fetchUserData(userId: String, completion:@escaping (ProfilData?, URLResponse?, Error?)->())
    func fetchMedias(userId: String, completion: @escaping (_ success : Bool, _ medias: [PFFile], _ error: Error?) -> () )
    func fetchPosts(userId: String, completion: @escaping (_ success : Bool, _ medias: [Post?], _ error: Error?) -> () )
    func fetchComments(postId: String, completion: @escaping (_ success : Bool, _ medias: [Comment?], _ error: Error?) -> () )

    func addFollowing(id: String, completion: @escaping (Bool)-> Void)
    func deleteFollowing(id: String, completion: @escaping (Bool)-> Void)
    func fetchFollowing(userId: String, completion: @escaping ([String])-> Void)


    func addMedia(info: [String: AnyObject], completion: @escaping (Bool)-> Void)
    func addComment(data: [String: String], completion: @escaping (Bool)-> Void)
}

class DataManager : NSObject {

    var imageCache = NSCache<NSString, UIImage>()

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

    func signUp(_ username: String, password: String, completion: @escaping (Bool, Error?)-> ()) {
        let user = PFUser()
        user.username = username
        user.password = password

        user.signUpInBackground { (success, error) in
            completion(success, error)
        }
    }

    func logInWithUsername(_ username: String, password: String, completion: @escaping (Bool, QNAError?)-> ()) {

        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in

            if let user = user {
                self.setCurrentUser(user)
                completion(true, nil)
            } else {
                var errorObj = QNAError.logingError(comment: nil) as QNAError

                if let error = error {
                    let message = error.localizedDescription
                    errorObj = QNAError.logingError(comment: message)
                }

                completion(false, errorObj)
            }
        }
    }
    
    func fetchImage(imageFile: PFFile, completion:@escaping (UIImage?, URLResponse?, Error?)->()) {

        let imageKey = imageFile.url! as NSString
        if let cacheImage = self.imageCache.object(forKey: imageKey) {

            completion(cacheImage, nil, nil)
        } else {

            // download image
            imageFile.getDataInBackground { (data, error) in

//                sleep(1) // test cache

                if let imageData = data {
                    if let imageToDisplay = UIImage(data:imageData) {
                        self.imageCache.setObject(imageToDisplay, forKey: imageKey)

                        completion(imageToDisplay, nil, error)
                    }
                }
            }

        }
    }

    func fetchAllUser(completion: @escaping ([ProfilData])-> Void) {

        var list: [ProfilData] = [ProfilData]()


        let query = PFUser.query()

        query?.whereKey("objectId", notEqualTo: PFUser.current()?.objectId)
        query?.findObjectsInBackground(block: { (objects, error) in

            if let error = error  {
                print("error: \(error)")
            } else if let users = objects {

                for object in users {

                    if let user = object as? PFUser {
                        if let id = user.objectId {

                            let username = String(describing: user.username ?? "")
                            let fullName = String(describing: user["full_name"] ?? "")
                            let email = String(describing: user.email ?? "")
                            let bio = String(describing: user["bio"] ?? "")

                            let accountData = ProfilData(id: id, username: username, fullname: fullName, email: email, profilePicture: user["profile_picture"] as? PFFile, bio: bio)

                            list.append(accountData)
                        }
                    }
                }
            }

            completion(list)
        })

    }

    func fetchUserData(userId: String, completion:@escaping (ProfilData?, URLResponse?, Error?)->()) {

        var accountData: ProfilData = ProfilData()

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:userId)

            if let owner = try query?.getFirstObject() as? PFUser {

                let username = String(describing: owner.username ?? "")
                let fullName = String(describing: owner["full_name"] ?? "")
                let email = String(describing: owner.email ?? "")
                let bio = String(describing: owner["bio"] ?? "")

                accountData = ProfilData(id: owner.objectId!, username: username, fullname: fullName, email: email, profilePicture: owner["profile_picture"] as? PFFile, bio: bio)

                completion(accountData, nil, nil)
            }
        } catch {
            print("\(#function), get User's object failed.")

        }

    }

    func fetchPosts(userId: String, completion: @escaping (_ success : Bool, _ medias: [Post?], _ error: Error?) -> () ) {

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

                        var list = [Post]()

                        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in

                            for post in posts {

                                var data: Post = Post()
                                data.id = post.objectId
                                data.userId = (post["user"] as? PFUser)?.objectId

                                data.username = userData.username
                                data.profileImageUrl = userData["profile_picture"] as? PFFile
                                data.createdTime = post.createdAt
                                data.imageUrls = [post["imageFile"] as? PFFile]

                                let group = DispatchGroup()
                                group.enter()

                                self.fetchComments(postId: post.objectId!, completion: { (sucess, objects, error) in
                                    if sucess {
                                        data.comments = objects
                                    }
                                    group.leave()
                                })

                                group.wait()
                                list.append(data)
                            }

                            DispatchQueue.main.async {
                                completion(true, list, nil)
                            }
                        }
                    }
                })
            }

        } catch {
            print("\(#function), get User's object failed.")
        }

    }


    func fetchComments(postId: String, completion: @escaping (_ success : Bool, _ medias: [Comment?], _ error: Error?) -> () ) {

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
                    completion(false, [], error)

                } else if let posts = objects {

                    DispatchQueue.global(qos: .userInitiated).async { [unowned self] in

                        for post in posts {
                            var commData: Comment = Comment()

                            if let parent = post["parent"] as? PFObject {
                                commData.postId = parent.objectId
                            }

                            commData.text = post["text"] as? String

                            if let user = post["user"] as? PFObject {
                                commData.userId = user.objectId

                                let group = DispatchGroup()
                                group.enter()

                                self.fetchUserData(userId: commData.userId! , completion: { (object, response, error) in
                                    if let userData = object {
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
                            completion(true, list, nil)
                        }
                    }

                }
            })


        } catch {
            print("\(#function), Photos table: get object failed.")
        }

    }


    func fetchMedias(userId: String, completion: @escaping (_ success : Bool, _ medias: [PFFile], _ error: Error?) -> () ) {

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

                        var list = [PFFile]()

                        for post in posts {

                            if let imageFile = post["imageFile"] as? PFFile {
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

    func addFollowing(id: String, completion: @escaping (Bool)-> Void) {

        var ret: Bool = false

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:id)

            if let followId = try query?.getFirstObject() as? PFUser {

                let following = PFObject(className: "Following")
                following["user"] = PFUser.current()
                following["following"] = followId

                following.saveInBackground { (sucess, error) in
                    if sucess {
                        print("Follow \(followId.username!) success.")
                        ret = true
                    } else {
                        print("Follow \(followId.username!) failed.")
                    }

                    completion(ret)
                }
            }
        } catch {
            print("\(#function), get PFUser's object failed.")
        }

    }

    func deleteFollowing(id: String, completion: @escaping (Bool)-> Void) {

        var ret: Bool = false

        do {
            let query = PFUser.query()
            query?.whereKey("objectId", equalTo:id)

            if let followId = try query?.getFirstObject() as? PFUser {

                let query = PFQuery(className: "Following")

                query.whereKey("user", equalTo: PFUser.current())
                query.whereKey("following", equalTo: followId)

                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {

                            let username = object["username"]

                            object.deleteInBackground(block: { (sucess, error) in
                                if sucess {
                                    print("Unfollow \(username) success.")
                                    ret = true
                                } else {
                                    print("Unfollow \(username) failed.")
                                }
                            })
                        }
                    }

                    completion(ret)
                })
            }
        } catch {
            print("\(#function), get PFUser's object failed.")
        }

    }

    func fetchFollowing(userId: String, completion: @escaping ([String])-> Void) {

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
                            if let userObject = object["following"] as? PFUser{
                                list.append(userObject.objectId!)
                            }


                        }
                    }
                    completion(list)
                })
            }
        } catch {
            print("\(#function), get PFUser's object failed.")
        }

    }

    //MARK: -

    func addMedia(info: [String: AnyObject], completion: @escaping (Bool)-> Void) {

        let comment = info["comment"]?.text ?? ""

        var post = PFObject(className:"Photos")
        
        post["user"] = PFUser.current()

        if let image = info["image"]?.image, let imageData = image.toJPEGNSData(.lowest) {
            let imageFile = PFFile(name: "image.png", data: imageData)
            post["imageFile"] = imageFile

            // Create the comment
            var myComment = PFObject(className:"Comments")
            myComment["text"] = comment
            myComment["user"] = PFUser.current()
            myComment["replay_to_user"] = ""

            // Add a relation between the Post and Comment
            myComment["parent"] = post

            // This will save both myPost and myComment
            myComment.saveInBackground(block: { (success, error) in

                completion(success)
            })


        }
    }

    func addComment(data: [String: String], completion: @escaping (Bool)-> Void) {

        let myComment = PFObject(className:"Comments")
        myComment["text"] = data["text"]
        myComment["user"] = PFUser.current()
        myComment["replay_to_user"] = data["replay_to_user"]

        myComment["parent"] = PFObject(withoutDataWithClassName:"Photos", objectId:data["post_id"])

        myComment.saveInBackground(block: { (success, error) in

            completion(success)
        })

    }

}
