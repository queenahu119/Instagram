//
//  EditProfileViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 9/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

enum ProfileField: String {
    case name = "Name"
    case username = "Username"
    case email = "Email"
    case bio = "Bio"
}

struct Profile {
    var field: String
    var data: String
}

class EditProfileModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager

        self.accountData = []
        self.profilePicture = nil
    }

    private var profilePicture: URL? {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    private var accountData: [Profile] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    var numberOfCells: Int {
        return accountData.count
    }

    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }

    func initFetch() {

        fetchProfileData()
    }

    func getProfile() -> [Profile] {
        return accountData
    }

    func getProfileImage(completion: @escaping (UIImage?, URLResponse?, Error?)->()) {

        if let imageFile = self.profilePicture {
            dataManager.fetchImage(imageUrl: imageFile) { (image, error) in
                completion(image, nil, error)
            }
        }
    }


    func getCellViewModel( at indexPath: IndexPath ) -> Profile? {
        return accountData[indexPath.row]
    }

    //MARK: - callback
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: ((_ title: String, _ message: String)->())?
    var updateLoadingStatus: (()->())?
    var updateInfoAfterCompletion: ((Bool, String?, String?)->())?


    //MARK: - action

    func fetchProfileData() {

        guard let userID = CurrentAccount.shared().baseUserId else {
            return
        }

        DispatchQueue.global().async { [weak self] in
            self?.dataManager.fetchUserData(userId: userID) { [weak self] (profile, error) in

                DispatchQueue.main.async {
                    if let profile = profile {

                        self?.accountData = [
                            Profile(field: ProfileField.name.rawValue, data: profile.fullname),
                            Profile(field: ProfileField.username.rawValue, data: profile.username),
                            Profile(field: ProfileField.email.rawValue, data: profile.email),
                            Profile(field: ProfileField.bio.rawValue, data: profile.bio)]

                        self?.profilePicture = profile.profilePicture
                    }
                }
            }
        }

    }

    func submitProfile(info: [Profile], profileImage: UIImage?) {

        self.isLoading = true
        dataManager.updateProfile(info, profileImage) { [weak self] (error) in
            self?.isLoading = false

            if error == nil {
                self?.updateInfoAfterCompletion!(true, "Update Successfully.", "")
            } else {
                self?.updateInfoAfterCompletion!(false, "Have some problems.", "Please try again later.")
            }
        }
    }
}

