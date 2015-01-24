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
class AppDelegate: UIResponder, UIApplicationDelegate, ISSViewDelegate {
    // windows
    var window: UIWindow?
    // feedDelegate
    var feedDataDelegate: FeedDataDelegate?
    
    // applicaiton init
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // fabric
        Fabric.with([Crashlytics(),MoPub()])
        ShareSDK.registerApp(AppKeySercet.SHARKSDK_KEY)
        ShareSDK.connectSinaWeiboWithAppKey(AppKeySercet.WEIBO_KEY, appSecret: AppKeySercet.WEIBO_SECRET, redirectUri: AppKeySercet.WEIBO_REDIRECT_URI)
        // shareSDK
        ShareSDK.connectDoubanWithAppKey(AppKeySercet.DOUBAN_KEY, appSecret: AppKeySercet.DOUBAN_SECRET, redirectUri: AppKeySercet.DOUBAN_REDIRECT_URI)
        
        // create the FeedModelDelegate
        self.feedDataDelegate = FeedDataDelegate()
        var feedlyClient = AFLClient.sharedClient()
        feedlyClient?.initWithApplicationId(AppKeySercet.FEEDLY_KEY, andSecret: AppKeySercet.FEEDLY_SERECT)
        var showViewController:UIViewController?
        showViewController = createMainController()
        
        // createa the windows
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = showViewController
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        // return
        return true;
    }
    
    
    // create main controller
    func createMainController() -> UIViewController{
        // the main view
        var mainController = UIViewController()
        
        var subController = SubscriptionTableViewController()
        subController.view.frame = mainController.view.bounds
        mainController.view.addSubview(subController.view)
        mainController.addChildViewController(subController)
        
        var loginController = LoginViewController()
        mainController.addChildViewController(loginController)
        
        // create navigator
        var navigationController = UINavigationController(rootViewController: subController)
        
        
        // left side
        var leftsideBarController = LeftBarController()
        var leftNnavigationController = UINavigationController(rootViewController: leftsideBarController)
        
        // cratea drawer
        var drawer = ICSDrawerController(leftViewController: leftNnavigationController, centerViewController: navigationController)
        
       
       // navigationController.navigationItem = UINavigationItem(title: "RSS")
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        leftNnavigationController.navigationBar.barStyle = UIBarStyle.Black
        leftNnavigationController.navigationBar.tintColor = UIColor.whiteColor()
        
        // return
        return drawer;
    }

}

/**
*  the all app connect key and secret
*/
struct AppKeySercet{
  static let FEEDLY_KEY          = "sandbox"
  static let FEEDLY_SERECT       = "9ZUHFZ9N2ZQ0XM5ERU1Z"
  static let SHARKSDK_KEY        = "5403815558a6"
  static let WEIBO_KEY           = "568898243"
  static let WEIBO_SECRET        = "38a4f8204cc784f81f9f0daaf31e02e3"
  static let WEIBO_REDIRECT_URI  = "http://www.sharesdk.cn"
  static let DOUBAN_KEY          = "07d08fbfc1210e931771af3f43632bb9"
  static let DOUBAN_SECRET       = "e32896161e72be91"
  static let DOUBAN_REDIRECT_URI = "http://dev.kumoway.com/braininference/infos.php"
}

