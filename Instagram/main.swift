//
//  main.swift
//  Instagram
//
//  Created by Queena Huang on 13/11/18.
//  Copyright © 2018 queenahu. All rights reserved.
//

import Foundation
import UIKit

let unitTest = NSClassFromString("XCTestCase") != nil
let useStubApi = ProcessInfo.processInfo.arguments.contains("USE_STUB_API")
let isRunningTests = unitTest || useStubApi
let appDelegateClass = isRunningTests ? NSStringFromClass(FakeAppDelegate.self) : NSStringFromClass(AppDelegate.self)
let args = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))

UIApplicationMain(CommandLine.argc, args, nil, appDelegateClass)
