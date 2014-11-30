//
//  AppDelegate.swift
//  AnyRead
//
//  Created by wuhanchu on 14/11/18.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics
import MoPub

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // fabric
        Fabric.with([Crashlytics(),MoPub()])
        
        
   
        // create firest view
        var firstViewController = ManagerViewController(style: UITableViewStyle.Grouped)
        
        // create the navigatiionController
        var navigationController = UINavigationController(rootViewController: firstViewController)
        
        // createa the windows
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = navigationController
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
   

        
        
        // return
        return true;
    }
    
    func applicationDidFinishLaunching(application: UIApplication) {
//        Crashlytics.startWithAPIKey("3d2e4cb0ef419ff07f5b46cc47fce5396f6a010e 41c3cd5846982dda19ee5b806f30339db1d297ac7831bc650553bbf49e5ed98b")
    }
}

