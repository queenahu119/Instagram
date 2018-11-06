//
//  EditProfileViewModel.swift
//  Instagram
//
//  Created by QueenaHuang on 9/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse


class EditProfileModel: NSObject {

    let dataManager : DataManager

    init(dataManager: DataManager = DataManager()) {
        self.dataManager = dataManager

        self.accountData = []
        self.profilePicture = nil
    }

    private var profilePicture: PFFile? {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    private var accountData: [[String: String]] {
        didSet {
            self.reloadAccountInfoClosure?()
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

    func getAccountInfo() -> [String: String] {

        var info: [String: String] = [:]
        for dic in accountData {

            if let fieldName = dic["fieldName"], let data = dic["data"] {
//                print("[\(fieldName)]: \(data)")
                info.updateValue(data, forKey: fieldName)
            }
        }

        return info
    }

    func getProfileImage(completion: @escaping (UIImage?, URLResponse?, Error?)->()) {

        if let imageFile = self.profilePicture {

            dataManager.fetchImage(imageFile: imageFile) { (image, response, error) in
                completion(image, response, error)
            }
        }

    }


    func getCellViewModel( at indexPath: IndexPath ) -> [String: String?] {
        return accountData[indexPath.row]
    }

    //MARK: - callback
    var reloadTableViewClosure: (()->())?
    var reloadAccountInfoClosure: (()->())?
    var showAlertClosure: ((_ title: String, _ message: String)->())?
    var updateLoadingStatus: (()->())?
    var updateInfoAfterCompletion: ((Bool, String?, String?)->())?


    //MARK: - action

    func fetchProfileData() {

        dataManager.fetchUserData(userId: (PFUser.current()?.objectId)!) { [weak self] (profilData, response, error) in
            if let profilData = profilData {
                self?.accountData = [
                    ["fieldName": "Name", "data": profilData.fullname],
                    ["fieldName": "Username", "data": profilData.username],
                    ["fieldName": "Email", "data": profilData.email],
                    ["fieldName": "Bio", "data": profilData.bio]]

                self?.profilePicture = profilData.profilePicture
            }
        }
    }

    func submitProfile(info: [String: String], profileImage: UIImage?) {

        self.isLoading = true

        let scoreQuery = PFUser.query()
        scoreQuery?.whereKey("objectId", equalTo: PFUser.current()?.objectId)
        scoreQuery?.getFirstObjectInBackground { (object, error) -> Void in

            if let error = error {
                print("update account: ", error)
            } else if let user = object as? PFUser {

                user.username = info["Username"]
                user["full_name"] = info["Name"] ?? ""
                user.email = info["Email"]
                user["bio"] = info["Bio"] ?? ""

                if let image = profileImage, let imageData = image.toJPEGNSData(.lowest) {
                    let imageFile = PFFile(name: "image.png", data: imageData)
                    user["profile_picture"] = imageFile
                }

                user.saveInBackground(block: { (success, error) in
                    
                    self.isLoading = false
                    if (success) {

                        self.updateInfoAfterCompletion!(success, "Update Successfully.", "")
                    } else {

                        self.updateInfoAfterCompletion!(success, "Have some problems.", "Please try again later.")
                    }
                })
            }

        }

    }
}

