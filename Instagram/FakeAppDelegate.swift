//
//  FakeAppDelegate.swift
//  Instagram
//
//  Created by Queena Huang on 12/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import UIKit

class FakeAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        print("FakeAppDelegate")
        window = UIWindow()
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()

        InstagramStub.detectAndConfigure()
        return true
    }
}
