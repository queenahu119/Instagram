//
//  ProfileViewModel.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/14.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import Foundation
import UIKit
import Parse

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

        if let imageFile = cellViewModel[indexPath.row].imageFile {

            dataManager.fetchImage(imageFile: imageFile) { (image, response, error) in
                completion(image, response, error)
            }
        }
    }

    func getProfileImage(url: URL?, completion:@escaping (UIImage?, URLResponse?, Error?)->()) -> () {

        if let imageFile = self.profile.profilePicture {

            dataManager.fetchImage(imageFile: imageFile, completion: { (image, response, error) in

                completion(image, response, error)
            })
        }
    }
    
    func initFetchUserInfo() {
        fetchProfileData()

        fetchMedias()
    }

    func fetchProfileData() {

        guard let objectId = PFUser.current()?.objectId else {
            print("Fail to get objectId.")
            return
        }

        dataManager.fetchUserData(userId:objectId) { [weak self] (profilData, response, error) in
            if let profilData = profilData {

                self?.profile = profilData

            }
        }

    }

    func fetchMedias() {
        self.isLoading = true

        guard let objectId = PFUser.current()?.objectId else {
            print("Fail to get objectId.")
            self.isLoading = false
            return
        }

        dataManager.fetchMedias(userId:objectId) { (success, posts, error) in

            self.isLoading = false

            if success {
                var list = [PhotoListCellViewModel]()
                for imageFile in posts {

                    list.append(PhotoListCellViewModel(titleText: "", descText: "", imageFile: imageFile, dateText: ""))

                }
                self.cellViewModel = list
            }
        }
    }
}

struct PhotoListCellViewModel {
    let titleText: String
    let descText: String
    let imageFile: PFFile?
    let dateText: String
}
