//
//  Photos.swift
//  Instagram
//
//  Created by QueenaHuang on 27/1/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

/*struct Media {
    var id: String?
    var imageUrl: PFFile?
    var createdTime: Date?

    init(id: String? = nil,
         imageUrl: PFFile? = nil,
         createdTime: Date? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.createdTime = createdTime
    }
}*/

struct Comment {
    var postId: String?
    var userId: String?
    var username: String?
    var profileImageUrl: PFFile?
    var replyUser: String?
    var text: String?
    var isLike: Bool

    init(postId: String? = nil,
         userId: String? = nil,
         username: String? = nil,
         profileImageUrl: PFFile? = nil,
         replyUser: String? = nil,
         text: String? = nil,
         isLike: Bool = false) {
        self.postId = postId
        self.userId = userId
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.replyUser = replyUser
        self.text = text
        self.isLike = isLike
    }
}

struct Post {
    var id: String?
    var userId: String?
    var username: String?
    var profileImageUrl: PFFile?
    var location: String?
    var numOfLike: String?
    var comments: [Comment?]

    var imageUrls: [PFFile?]
    var createdTime: Date?

    init(id: String? = nil,
         userId: String? = nil,
         username: String? = nil,
         profileImageUrl: PFFile? = nil,
         location: String? = nil,
         numOfLike: String? = nil,
         comments: [Comment] = [],
         imageUrls: [PFFile] = [],
         createdTime: Date? = nil
        ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.location = location
        self.numOfLike = numOfLike
        self.comments = comments
        self.imageUrls = imageUrls
        self.createdTime = createdTime
    }
}
