//
//  DataManager.swift
//  Instagram
//
//  Created by QueenaHuang on 3/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import UIKit
import Parse

class DataManager : NSObject {

    lazy var dataAdapter = DataAdapterFactory.sharedInstance.dataAdapter
    lazy var session = URLSession(configuration: .default)
    var imageCache = NSCache<NSString, UIImage>()

    func isUserLogin() -> Bool {
        return dataAdapter.isUserLogin()
    }

    func signUp(_ username: String, password: String, completion: @escaping (Bool, Error?)-> ()) {

        dataAdapter.signUp(username, password: password) { (user, error) in

            if user != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }

    func logIn(_ username: String, password: String, completion: @escaping (Bool, Error?)-> ()) {

        dataAdapter.logIn(username, password: password) { (user, error) in
            if user != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    func fetchImage(imageUrl: URL, completion:@escaping (UIImage?, Error?)->()) {

        let imageKey = imageUrl.absoluteString as NSString
        if let cacheImage = self.imageCache.object(forKey: imageKey) {
            completion(cacheImage, nil)
        } else {

            let task = session.dataTask(with: imageUrl) { (data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        completion(nil, error)
                        return
                }

                self.imageCache.setObject(image, forKey: imageKey)
                completion(image, nil)
            }
            task.resume()
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

                            let accountData = ProfilData(id: id, username: username, fullname: fullName, email: email, profilePicture: user["profile_picture"] as? URL, bio: bio)

                            list.append(accountData)
                        }
                    }
                }
            }

            completion(list)
        })

    }

    func fetchUserData(userId: String, completion:@escaping (ProfilData?, Error?)->()) {

        dataAdapter.fetchAccountInfo(userId: userId) { (data, error) in
            completion(data, error)
        }
    }

    func fetchPostsByUser(userId: String, completion: @escaping (_ medias: [Post?], _ error: Error?) -> ()) {

        dataAdapter.fetchPostsByUser(userId: userId) { (posts, error) in
            completion(posts, error)
        }
    }


    func fetchComments(postId: String, completion: @escaping (_ medias: [Comment?], _ error: Error?) -> () ) {

        dataAdapter.fetchComments(postId: postId) { (comments, error) in
            completion(comments, error)
        }
    }


    func fetchMedias(userId: String, completion: @escaping (_ medias: [Post]?) -> () ) {
        var followings: [String] = [""]
        var totalPosts: [Post]? = nil

        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let group = DispatchGroup()

            // step1: get followings
            if let userID = CurrentAccount.shared().baseUserId {
                group.enter()

                self.fetchFollowing(userId: userID, completion: { (users, error) in
                    if error != nil {
                        followings = users
                        followings.append(userID)

                    }
                    group.leave()
                })
                group.wait()
            }

            // step2: get all posts of followings
            for user in followings {
                group.enter()
                print("fetchPosts user: ", user)

                self.fetchPostsByUser(userId: user, completion: { (posts, error) in
                    if error == nil {
                        if !posts.isEmpty {
                            totalPosts = posts as? [Post]
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                    group.leave()
                })
            }

            group.wait()

            DispatchQueue.main.async {
                completion(totalPosts)
            }
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

    func fetchFollowing(userId: String, completion: @escaping ([String], _ error: Error?)-> Void) {

        dataAdapter.fetchFollowing(userId: userId) { (followings, error) in
            completion(followings, error)
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
