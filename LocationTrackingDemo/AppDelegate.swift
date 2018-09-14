//
//  AppDelegate.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        JediWrapper.setup()
        return true
    }

}

