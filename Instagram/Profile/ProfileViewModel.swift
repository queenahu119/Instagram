//
//  ProfileViewModel.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/14.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager
    }

    private var profile : ProfilData = ProfilData(){
        didSet {
            self.reloadUserClosure?()
        }
    }

    private var cellViewModel : [PhotoListCellViewModel] = [PhotoListCellViewModel](){
        didSet {
            self.reloadPhotoListViewClosure?()
        }
    }

    var numberOfPhotoCells : Int {
        return cellViewModel.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }


    //MARK: - callback
    var reloadPhotoListViewClosure: (()->())?
    var reloadUserClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?

    //MARK: -

    func getUserInfoViewModel() -> ProfilData {
        return profile
    }

    func getCellViewModel(at indexPath: IndexPath) -> PhotoListCellViewModel {
        return cellViewModel[indexPath.row]
    }

    func getImageOfCell(at indexPath: IndexPath, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageUrl = cellViewModel[indexPath.row].imageUrl {
            dataManager.fetchImage(imageUrl: imageUrl) { (image, error) in
                completion(image, nil, error)
            }
        }
    }

    func getProfileImage(url: URL?, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageUrl = self.profile.profilePicture {
            dataManager.fetchImage(imageUrl: imageUrl, completion: { (image, error) in
                completion(image, nil, error)
            })
        }
    }
    
    func initFetchUserInfo() {

        fetchProfileData()
        fetchOwnMedias()
    }

    func fetchProfileData() {
        guard let userId = CurrentAccount.shared().baseUserId else {
            print("Fail to get objectId.")
            return
        }

        dataManager.fetchUserData(userId: userId) { [weak self] (profilData, error) in
            if let profilData = profilData {
                self?.profile = profilData
            }
        }
    }

    func fetchOwnMedias() {
        self.isLoading = true

        guard let userId = CurrentAccount.shared().baseUserId else {
            print("Fail to get objectId.")
            self.isLoading = false
            return
        }

        dataManager.fetchMedias(userId: userId) { (posts) in
            self.isLoading = false
            if let posts = posts {
                var list = [PhotoListCellViewModel]()
                for post in posts {
                    if let url = post.imageUrls.first {
                        list.append(PhotoListCellViewModel(titleText: "", descText: "", imageUrl: url, dateText: ""))
                    }
                }
                self.cellViewModel = list
            }
        }
    }
}

struct PhotoListCellViewModel {
    let titleText: String
    let descText: String
    let imageUrl: URL?
    let dateText: String
}
