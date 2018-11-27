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

    func logOut() {
        dataAdapter.logOut()
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

    func fetchAllUser(completion: @escaping ([ProfilData], Error?)-> Void) {

        dataAdapter.fetchAllUser { (users, error)  in
            completion(users, error)
        }
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
                    if error == nil {
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

                self.fetchPostsByUser(userId: user, completion: { (posts, error) in
                    if error == nil {
                        if !posts.isEmpty {
                            totalPosts = posts as? [Post]
                        }
                    } else {
                        print(error ?? QNAError.getPosts)
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

    func addFollowing(id: String, completion: @escaping (Error?)-> Void) {
        dataAdapter.addFollowing(id: id) { (error) in
            completion(error)
        }
    }

    func deleteFollowing(id: String, completion: @escaping (Error?)-> Void) {
        dataAdapter.deleteFollowing(id: id) { (error) in
            completion(error)
        }
    }

    func fetchFollowing(userId: String, completion: @escaping ([String], _ error: Error?)-> Void) {

        dataAdapter.fetchFollowing(userId: userId) { (followings, error) in
            completion(followings, error)
        }
    }

    //MARK: -

    func addMedia(info: [String: AnyObject], completion: @escaping (Error?)-> Void) {
        dataAdapter.addMedia(info: info) { (error) in
            completion(error)
        }
    }

    func addComment(data: [String: String], completion: @escaping (Error?)-> Void) {
        dataAdapter.addComment(data: data) { (error) in
            completion(error)
        }
    }

    func updateProfile(_ info: [Profile], _ profileImage: UIImage?, completion: @escaping (Error?)-> Void) {
        var imageData: Data? = nil
        if let image = profileImage {
            imageData = image.toJPEGNSData(.lowest)
        }

        dataAdapter.updateProfile(info, imageData) { (error) in
            completion(error)
        }
    }

}
