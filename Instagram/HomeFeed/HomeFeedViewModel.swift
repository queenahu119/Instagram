//
//  HomeFeedViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 7/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import UIKit
import Parse

class HomeFeedViewModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }

    private var followings: [String] = [""] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    //MARK: - callback
    var reloadTableViewClosure: (()->())?
    var reloadUserClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?


    private var cellViewModel: [FeedCellViewModel] = [FeedCellViewModel](){
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var numberOfTableCells : Int {
        return cellViewModel.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    func initFetch() {

    }

    func getCellViewModel(at indexPath: IndexPath) -> FeedCellViewModel {
        return cellViewModel[indexPath.row]
    }

    func getProfileImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageFile = cellViewModel[indexPath.row].profileImageUrl {

            dataManager.fetchImage(imageFile: imageFile) { (image, response, error) in
                completion(image, response, error)
            }
        } else {
            let defaultImage = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

            completion(defaultImage, nil, nil)
        }
    }

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageFile = cellViewModel[indexPath.row].imageUrls.first as? PFFile {

            dataManager.fetchImage(imageFile: imageFile) { (image, response, error) in
                completion(image, response, error)
            }
        } else {
            let defaultImage = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

            completion(defaultImage, nil, nil)
        }
    }

    func fetchMedias() {

        self.isLoading = true

        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let group = DispatchGroup()


            if let userID = PFUser.current()?.objectId {

                group.enter()

                self.dataManager.fetchFollowing(userId: userID, completion: { (users) in
                    self.followings = users

                    self.followings.append(userID)
                    group.leave()
                })

                group.wait()
            }

            var listByUser:[FeedCellViewModel] = [FeedCellViewModel]()

            for user in self.followings {

                group.enter()
                print("fetchPosts user: ", user)
                self.dataManager.fetchPosts(userId: user, completion: { (success, objects, error) in
                    if success {

                        for post in objects {
                            if let post = post {

                                var commentString = ""

                                for comment in post.comments {
                                    if let text = comment?.text {
                                        commentString = commentString + "\(text) \n"
                                    }
                                }
                                
                                listByUser.append(FeedCellViewModel(id: post.id ?? "", userId: post.userId ?? "", username: post.username!, profileImageUrl: post.profileImageUrl, location: post.location, numOfLike: post.numOfLike, comments: commentString, imageUrls: post.imageUrls, dateText: post.createdTime))
                            }
                        }

                    }
                    group.leave()
                })
            }

            group.wait()

            DispatchQueue.main.async { [unowned self] in

//                for post in listByUser {
//
//                    listByUser.append(post)
//                }

                listByUser.sort(by: {Double(($0.dateText?.timeIntervalSinceNow)!) > Double(($1.dateText?.timeIntervalSinceNow)!)})

                self.cellViewModel = listByUser

                self.isLoading = false
            }
        }

    }


}

struct FeedCellViewModel {
    let id: String
    let userId: String
    let username: String
    let profileImageUrl: PFFile?
    let location: String?
    let numOfLike: String?
    let comments: String?

    let imageUrls: [PFFile?]
    let dateText: Date?
}
