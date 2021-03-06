//
//  DiscoverPeopleViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 23/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import UIKit

class DiscoverPeopleViewModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }

    private var followings: [String] = [""] {
        didSet {
            DispatchQueue.main.async {
                self.reloadTableViewClosure?()
            }
        }
    }

    private var cellViewModel : [PeopleCellViewModel] = [PeopleCellViewModel](){
        didSet {
            DispatchQueue.main.async {
                self.reloadTableViewClosure?()
            }
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

    var isFollowButtonLoading: Bool = false {
        didSet {
            self.updateFollowButtonLoadingStatus?()
        }
    }

    //MARK: - callback
    var reloadTableViewClosure: (()->())?
    var updateLoadingStatus: (()->())?
    var updateFollowButtonLoadingStatus: (()->())?
    var updateInfoAfterCompletion: ((Bool, String?, String?)->())?


    //MARK: -
    func initFetch() {

        fetchUsers()
    }

    func getCellViewModel(at indexPath: IndexPath) -> PeopleCellViewModel {
        return cellViewModel[indexPath.row]
    }

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageUrl = cellViewModel[indexPath.row].imageUrl {
            dataManager.fetchImage(imageUrl: imageUrl) { (image, error) in
                completion(image, nil, error)
            }
        }
    }

    func fetchUsers() {
        self.isLoading = true
        var allUser: [ProfilData] = []

        guard let userID = CurrentAccount.shared().baseUserId else {
            print("No one login.")
            self.isLoading = false
            return
        }

        DispatchQueue.global(qos: .background).async { [unowned self] in
            let group = DispatchGroup()
            group.enter()
            self.dataManager.fetchAllUser { (users, error) in
                if error == nil {
                    allUser = users
                }
                group.leave()
            }

            group.enter()
            self.dataManager.fetchFollowing(userId: userID, completion: { (users, error) in
                self.followings = users

                group.leave()
            })
            group.wait()

            DispatchQueue.main.async { [weak self] in
                var list = [PeopleCellViewModel]()

                for user in allUser {
                    var isFollow: Bool = false

                    if let followings = self?.followings {
                        if followings.contains(where: {$0 == user.id}) {
                            isFollow = true
                        }
                    }

                    list.append(PeopleCellViewModel(userId: user.id, usernameText: user.username, fullnameText: user.fullname, imageUrl: user.profilePicture, isFollowing: isFollow))
                }
                self?.cellViewModel = list
                self?.isLoading = false
            }
        }

    }

    func setFollowing(index: Int) {
        self.isFollowButtonLoading = true

        let user_id = cellViewModel[index].userId
        let status = cellViewModel[index].isFollowing

        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let group = DispatchGroup()
            group.enter()

            if status {
                self.dataManager.deleteFollowing(id: user_id, completion: { (success) in

                    group.leave()
                })

            } else {
                self.dataManager.addFollowing(id: user_id, completion: { (success) in

                    group.leave()
                })
            }

            group.wait()

            DispatchQueue.main.async { [weak self] in

                self?.fetchUsers()
                self?.isFollowButtonLoading = false
            }
        }
    }

}

struct PeopleCellViewModel {
    let userId: String
    let usernameText: String
    let fullnameText: String
    let imageUrl: URL?
    var isFollowing: Bool
}

