//
//  User.swift
//  MyInstagram
//
//  Created by QueenaHuang on 2017/12/10.
//  Copyright © 2017年 queenahuang. All rights reserved.
//

import UIKit
import Parse

struct ProfilData {
    let id: String
    let username: String
    let fullname : String
    let email: String
    let profilePicture: URL?
    let bio: String

    var post: Int
    var followers: Int
    var following: Int


    init() {
        self.id = ""
        self.username = ""
        self.fullname = ""
        self.email = ""
        self.profilePicture = nil
        self.bio = ""

        self.post = 0
        self.followers = 0
        self.following = 0
    }

    init(id: String, username: String, fullname: String, email: String, profilePicture: URL?, bio:String) {
        self.id = id
        self.username = username
        self.fullname = fullname
        self.email = email
        self.profilePicture = profilePicture
        self.bio = bio

        self.post = 0
        self.followers = 0
        self.following = 0
    }
}
