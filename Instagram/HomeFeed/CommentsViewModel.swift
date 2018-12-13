//
//  CommentsViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 2/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class CommentsViewModel: NSObject {
    let dataManager : DataManager
    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }

    private var postId: String = ""
    private var profileImage: URL? = nil

    private var cellViewModel : [CommentCellViewModel] = [CommentCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var numberOfCells: Int {
        return cellViewModel.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    func getCellViewModel(at indexPath: IndexPath) -> CommentCellViewModel {
        return cellViewModel[indexPath.row]
    }

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, Error?) -> Void) {

        if let imageUrl = cellViewModel[indexPath.row].imageUrl {
            dataManager.fetchImage(imageUrl: imageUrl) { (image, error) in
                completion(image, error)
            }
        }
    }

    func getProfileImage() {

        if let imageUrl = self.profileImage {
            dataManager.fetchImage(imageUrl: imageUrl) { [weak self] (image, error) in
                self?.updateProfileImageAfterCompletion!(image, nil, nil)
            }
        } else {
            let defaultImage = defaultBackgroundColor.imageRepresentation
            self.updateProfileImageAfterCompletion!(defaultImage, nil, nil)
        }
    }
    
    //MARK: - callback
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var updateFollowButtonLoadingStatus: (()->())?
    var updateInfoAfterCompletion: ((Bool, String?, String?)->())?
    var updateProfileImageAfterCompletion: ((UIImage?, URLResponse?, Error?)->())?
    var postAfterCompletion: ((Bool, String?, String?)->())?

    //MARK: -

    func initFetch(postId: String) {
        self.isLoading = true

        self.postId = postId
        self.profileImage = CurrentAccount.shared().baseProfilePicture

        var list = [CommentCellViewModel]()

        dataManager.fetchComments(postId: postId) { [weak self] (objects, error) in
            self?.isLoading = false

            if error == nil {
                for comment in objects {

                    if let comment = comment {

                        let text = String(describing: comment.username ?? "")
                            + ": " + String(describing: comment.text ?? "")
                        let data = CommentCellViewModel(postId: comment.postId ?? "", userId: comment.userId ?? "", replyUser: comment.replyUser, text: text, isLike: comment.isLike, imageUrl: comment.profileImageUrl)

                        list.append(data)
                    }
                }
                self?.cellViewModel = list
            }
        }

        getProfileImage()
    }


    func writeComment(replayToUserId: String?, text: String?) {

        self.isLoading = true

        var data: [String: String] = [String: String]()

        data["text"] = text ?? ""
        data["post_id"] = postId
        data["replay_to_user"] = replayToUserId ?? ""

        dataManager.addComment(data: data) { [weak self] (error) in
            self?.isLoading = false

            if error != nil {
                self?.postAfterCompletion!(false, "Comment Could Not Be Posted!", "Please try again later.")
            } else {
                self?.postAfterCompletion!(true, nil, nil)
            }
        }
    }
}

struct CommentCellViewModel {
    var postId: String
    var userId: String
    var replyUser: String?
    var text: String?
    var isLike: Bool
    let imageUrl: URL?
}
