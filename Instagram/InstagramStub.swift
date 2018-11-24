//
//  InstagramStub.swift
//  Instagram
//
//  Created by Queena Huang on 12/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import Parse

struct InstagramStub {
    static func detectAndConfigure() {
        if detect() {
            print("Using stub API")
            configure()
        }
    }

    static func detect() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("USE_STUB_API")
    }

    static func delay() -> TimeInterval {
        if ProcessInfo.processInfo.arguments.contains("SUPRESS_API_DELAY") {
            print("Supressing delay in stub API responses")
            return 0
        } else {
            print("Using delay of 1 second in stub API responses")
            return 1
        }
    }

    static func fakeCurrentUser(_ json: [String: Any]) {
        CurrentAccount.shared().baseUserId = json["id"] as? String
        CurrentAccount.shared().baseUsername = json["user"] as? String
        CurrentAccount.shared().baseProfilePicture = json["profileImage"] as! URL
    }

    static func configure() {
        DataAdapterFactory.sharedInstance.testDataAdapter = MockDataAdapter()

        let responses = FakeResponses.sharedInstance

        responses.addResponse(
            FakeResponse(pattern: ".*GetLoginMember.*", json: [
                "responseObject":
                    [ "user": "Ida",
                      "id": "1111",
                      "email": "ida4@some.info",
                      "profileImage": URL(string: "https://pngimage.net/wp-content/uploads/2018/06/profile-image-png-1.png")!]
                ], isLogin: false))

        responses.addResponse(
            FakeResponse(pattern: ".*GetSignUpMember.*", json: [
                FakeResponsesJson.object.rawValue:
                    [ "user": "dddd",
                      "id": "3333",
                      "email": "dddd@gamil.com",
                      "profileImage": URL(string: "https://www.lawyersweekly.com.au/images/LW_Media_Library/594partner-profile-pic-An.jpg")!]
                ], isLogin: false))


        configProfile(responses)
        configDownloadImageByMockURLSession(responses)

        configPosts(responses)
        configFollowing(responses)

    }

    static func configProfile(_ responses: FakeResponses) {

        let profileUrl = URL(string: "https://pngimage.net/wp-content/uploads/2018/06/profile-image-png-1.png")!
        var account = ProfilData(id: "1111", username: "Ida", fullname: "Ida Adams", email: "ida4@some.info", profilePicture: profileUrl, bio: "Here's who people are repping this Ausmusic T-Shirt Day ")
        account.followers = 102
        account.following = 23
        account.post = 15

        responses.addResponse(
            FakeResponse(pattern: ".*GetAccountInfo.*", json: [
                FakeResponsesJson.object.rawValue:
                    [account]
                ], isLogin: false))
    }

    static func configDownloadImageByMockURLSession(_ responses: FakeResponses) {

        if let image = UIImage(named: "defaultPrpfile") {
            guard let body = UIImageJPEGRepresentation(image, 1.0) else {
                return
            }

            let headers = ["Content-Type" : "image/jpeg", "Custom-Header" : "Is custom"]

            responses.addResponse(
                FakeResponse(pattern: ".*blogspot.*", json: [
                    FakeResponsesJson.object.rawValue:
                        ["data": body, "headers": headers]
                    ], delay: DefaultDelay, isLogin: false))
        }
    }

    fileprivate static func configPosts(_ responses: FakeResponses) {

        let profileUrl = URL(string: "https://pngimage.net/wp-content/uploads/2018/06/profile-image-png-1.png")
        let comment: Comment = Comment(postId: "a1111", userId: "1111", username: "Ida", profileImageUrl: profileUrl, replyUser: "John", text: "Apparently letting a kid be a kid is bad for their developmental health, according to the glut of questionable news articles on the subject", isLike: true)
        let comment1: Comment = Comment(postId: "a1111", userId: "2222", username: "apple", profileImageUrl: profileUrl, replyUser: "John", text: "Favourite part of Australia's semi-final victory?", isLike: false)
        let comment2: Comment = Comment(postId: "a1111", userId: "3333", username: "orage", profileImageUrl: profileUrl, replyUser: "Tom", text: "A fifth consecutive #WT20 final for Australia awaits as Alyssa Healy claims a fourth Player of the Match award in a huge win. ", isLike: false)
        let comment3: Comment = Comment(postId: "a1112", userId: "4444", username: "Mary01", profileImageUrl: profileUrl, replyUser: "Mary", text: "Australia vs Ireland -- Player of the match - ALYSSA HEALY", isLike: false)
        let comment4: Comment = Comment(postId: "a1113", userId: "5555", username: "Darcex", profileImageUrl: profileUrl, replyUser: "lauren", text: "Here are the details of my #BlackFriday sale and photos of everything that will be available. Sale kicks off Friday at 10am EST and runs til Monday! 🖤 ", isLike: false)
        let comment5: Comment = Comment(postId: "a1113", userId: "6666", username: "Victoria's Secret", profileImageUrl: profileUrl, replyUser: "customer", text: "#BlackFriday is SO ON: get a FREE tote when you spend $75 + a FREE blanket if you spend $150! Excl. & limits apply. S&H applies. Ends 11.23. 🇺🇸🇨🇦 only. ", isLike: false)
        let comment6: Comment = Comment(postId: "a1114", userId: "7777", username: "Burn The Stage The Movie", profileImageUrl: profileUrl, replyUser: "BTS", text: "BTS 2018 Summer Package Photobook FOR $6.99 and FREE WORLDWIDE SHIPPING ✈️🔥", isLike: false)

        responses.addResponse(
            FakeResponse(pattern: ".*GetComments.*", json: [
                FakeResponsesJson.object.rawValue:
                    [comment, comment1, comment2, comment3, comment4, comment5, comment6]
                ], isLogin: false))

        var post: Post = Post()
        post.id = "a1115"
        post.userId = "1111"
        post.username = "Ida"
        post.profileImageUrl = profileUrl
        post.createdTime = Date(timeIntervalSinceNow: -5000)
        post.comments = []
        post.imageUrls = [URL(string: "http://cdn.newsapi.com.au/image/v1/789daefd20cd7a2dab6fc9f2526b5263?width=1024")]

        let post2: Post = Post(id: "a1111", userId: "1111", username: "Ida", profileImageUrl: profileUrl, location: "Sydney", numOfLike: "23", comments: [comment, comment1, comment2], imageUrls: [URL(string: "https://www.marieclaire.com.au/media/13713/051216-best-beach-australia.jpg")!], createdTime: Date(timeIntervalSinceNow: -3000))
        let post3: Post = Post(id: "a1112", userId: "1111", username: "Ida", profileImageUrl: profileUrl, location: "taipei", numOfLike: "12", comments: [comment3], imageUrls: [URL(string: "http://d3lp4xedbqa8a5.cloudfront.net/s3/digital-cougar-assets/AusGeo/2016/12/05/64305/Direction-Island-HR-(4-of-18).jpg")!], createdTime: Date(timeIntervalSinceNow: -2000))
        let post4: Post = Post(id: "a1113", userId: "1111", username: "Ida", profileImageUrl: profileUrl, location: "taipei", numOfLike: "12", comments: [comment4, comment5], imageUrls: [URL(string: "https://vacationidea.com/pix/img25Hy8R/tips/best-time-to-visit-sydney-australia_f.jpg")!], createdTime: Date(timeIntervalSinceNow: -1000))
        let post5: Post = Post(id: "a1114", userId: "1111", username: "Ida", profileImageUrl: profileUrl, location: "taipei", numOfLike: "12", comments: [comment6], imageUrls: [URL(string: "https://www.goway.com.au/media/cache/d7/98/d7987f155ad24875edf7cbbdbd1903a9.jpg")!], createdTime: Date(timeIntervalSinceNow: -500))

        let post6: Post = Post(id: "a1115", userId: "1111", username: "Ida", profileImageUrl: profileUrl, location: "taipei", numOfLike: "12", comments: [], imageUrls: [URL(string: "https://1.bp.blogspot.com/-Y5jR4Uk1C88/Ttuq8_S_jgI/AAAAAAAAA_c/nGtPuXz9gIw/s1600/sea-sunset-wallpapers_11288_1920x1440.jpg")!], createdTime: Date(timeIntervalSinceNow: -400))


        responses.addResponse(
            FakeResponse(pattern: ".*GetPosts.*", json: [
                FakeResponsesJson.object.rawValue:
                    [post, post2, post3, post4, post5, post6]
                ], isLogin: false))
    }

    static func configFollowing(_ responses: FakeResponses) {

        responses.addResponse(
            FakeResponse(pattern: ".*GetFollowing.*", json: [
                FakeResponsesJson.object.rawValue:
                    ["2222", "3333", "4444", "5555"]
                ], isLogin: false))
    }

}
