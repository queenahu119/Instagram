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

    func getProfileImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, Error?) -> Void) {

        if let imageUrl = cellViewModel[indexPath.row].profileImageUrl {
            dataManager.fetchImage(imageUrl: imageUrl) { (image, error) in
                completion(image, error)
            }
        } else {
            let defaultImage = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

            completion(defaultImage, nil)
        }
    }

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, Error?) -> Void) {

        // to do: multi-photos
        if let imageUrl = cellViewModel[indexPath.row].imageUrls.first as? URL {
            dataManager.fetchImage(imageUrl: imageUrl) { (image, error) in
                completion(image, error)
            }
        } else {
            let defaultImage = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

            completion(defaultImage, nil)
        }
    }

    func fetchAllMedias() {
        self.isLoading = true
        guard let userID = CurrentAccount.shared().baseUserId else {
            print("No one login.")
            return
        }

        dataManager.fetchMedias(userId: userID) { (posts) in
            guard let posts = posts else {
                print("No any post.")
                return
            }

            var listByUser:[FeedCellViewModel] = [FeedCellViewModel]()

            for post in posts {
                var commentString = ""
                for comment in post.comments {
                    if let text = comment?.text {
                        commentString = commentString + "\(text) \n"
                    }
                }

                listByUser.append(FeedCellViewModel(id: post.id ?? "", userId: post.userId ?? "", username: post.username!, profileImageUrl: post.profileImageUrl, location: post.location, numOfLike: post.numOfLike, comments: commentString, imageUrls: post.imageUrls, dateText: post.createdTime))
            }

            listByUser.sort(by: {Double(($0.dateText?.timeIntervalSinceNow)!) > Double(($1.dateText?.timeIntervalSinceNow)!)})

            self.cellViewModel = listByUser
            self.isLoading = false
        }
    }


}

struct FeedCellViewModel {
    let id: String
    let userId: String
    let username: String
    let profileImageUrl: URL?
    let location: String?
    let numOfLike: String?
    let comments: String?

    let imageUrls: [URL?]
    let dateText: Date?
}
