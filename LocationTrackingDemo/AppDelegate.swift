//
//  AppDelegate.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        BITHockeyManager.shared().configure(withIdentifier: "3522dc26589d4cae90921e1b1c374747")
        BITHockeyManager.shared().crashManager.crashManagerStatus = BITCrashManagerStatus.autoSend
        BITHockeyManager.shared().isUpdateManagerDisabled = true
        BITHockeyManager.shared().start()
        return true
    }

}

