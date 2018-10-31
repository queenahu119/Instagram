//
//  CommentsViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 2/2/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

class CommentsViewModel: NSObject {

    let dataManager : DataManagerProtocol

    init(dataManager: DataManagerProtocol = DataManager()) {
        self.dataManager = dataManager
    }

    private var postId: String = ""

    private var profileImage: PFFile? = nil

    private var cellViewModel : [CommentCellViewModel] = [CommentCellViewModel](){
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

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageFile = cellViewModel[indexPath.row].imageFile {

            dataManager.fetchImage(imageFile: imageFile) { (image, response, error) in
                completion(image, response, error)
            }
        }
    }

    func getProfileImage() {

        if let imageFile = self.profileImage  {

            dataManager.fetchImage(imageFile: imageFile) { [weak self] (image, response, error) in

                self?.updateProfileImageAfterCompletion!(image, nil, nil)
            }
        } else {
            let defaultImage = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).imageRepresentation

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

        dataManager.fetchComments(postId: postId) { (success, objects, error) in
            if success {

                for comment in objects {

                    if let comment = comment {

                        let text = String(describing: comment.username ?? "")
                            + ": " + String(describing: comment.text ?? "")
                        let data = CommentCellViewModel(postId: comment.postId ?? "", userId: comment.userId ?? "", replyUser: comment.replyUser, text: text, isLike: comment.isLike, imageFile: comment.profileImageUrl)

                        list.append(data)
                    }

                }
                self.cellViewModel = list

                self.isLoading = false
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

        dataManager.addComment(data: data) { [weak self] (success) in
            self?.isLoading = false

            if (success) {

                self?.postAfterCompletion!(success, nil, nil)
            } else {

                self?.postAfterCompletion!(success, "Comment Could Not Be Posted!", "Please try again later.")
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
    let imageFile: PFFile?
}
