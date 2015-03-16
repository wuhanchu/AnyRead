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
    var feedManager: FeedDataManager?
    // feedlyClient
    var feedlyClient:AFLClient?
    // dataManager
    var dataManager = DataManager()
    // loginViewController
    var loginViewController: LoginViewController?

    // applicaiton init
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // fabric
        Fabric.with([Crashlytics(),MoPub()])
       
        // create the fedd
        self.feedManager = FeedDataManager()
        initFeedlyClient()
        self.feedManager?.feedlyClient = self.feedlyClient
        
        // regitster the notification
        if(UIApplication.sharedApplication().currentUserNotificationSettings().types != UIUserNotificationType.Badge){
            var settings = UIUserNotificationSettings(forTypes: UIUserNotificationType.Badge, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    
        // init share sdk
        initShareSDK()

        // shareSDK
        var showViewController:UIViewController?
        var result =  feedlyClient?.isAuthenticated()
        
        //show view controller
        loginViewController =  LoginViewController(nibName: "LoginView", bundle: nil)
        var mainController = createMainController()
        loginViewController?.mainViewController = mainController
        showViewController = loginViewController
        
        //set the theme
        var theme = NSUserDefaults.standardUserDefaults().integerForKey(UserStorKey.THEME)
        if(theme != 0){
            var setTheme =  ThemeType(rawValue: theme)
            if(setTheme != nil){
                Theme.changeTheme(setTheme!)
            }
        }
        
        // createa the windows
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = showViewController
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        
        
        // return
        return true;
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        var entryDatas =  dataManager.getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: nil,saved: nil)
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = entryDatas.count
        if(NSUserDefaults.standardUserDefaults().boolForKey(ConfKeys.IF_AUTO_REFRE)){
            feedManager?.startSyncTask()
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        feedManager?.stopSyncTask()
    }
    
    /**
     * init the feedly client
     */
    func initFeedlyClient(){
        feedlyClient = AFLClient.sharedClient()
        feedlyClient?.initWithApplicationId(AppKeySercet.FEEDLY_KEY, andSecret:AppKeySercet.FEEDLY_SERECT )
    }

    /**
     * init the shark sdk
     */
    func initShareSDK(){
        ShareSDK.registerApp(AppKeySercet.SHARKSDK_KEY)
        ShareSDK.connectSinaWeiboWithAppKey(AppKeySercet.WEIBO_KEY, appSecret: AppKeySercet.WEIBO_SECRET, redirectUri: AppKeySercet.WEIBO_REDIRECT_URI)
        ShareSDK.connectDoubanWithAppKey(AppKeySercet.DOUBAN_KEY, appSecret: AppKeySercet.DOUBAN_SECRET, redirectUri: AppKeySercet.DOUBAN_REDIRECT_URI)
        
    }

    /**
     * create main controller
     */
    func createMainController() -> UIViewController{
        var entryListController = EntryListTableViewController()
        var entryNavigator = UINavigationController(rootViewController: entryListController)
        entryNavigator.navigationBar.barStyle = UIBarStyle.Black
        var confController  = ConfController()
        
        var subController = SubscriptionTableViewController()
        subController.loginViewController = self.loginViewController
        var subNavigator = UINavigationController(rootViewController: subController)
        subNavigator.navigationBar.barStyle = UIBarStyle.Black
        subController.entryListController = entryListController
        
        
        var icsDrawer =   ICSDrawerController(leftViewController: subController, centerViewController: entryNavigator)
        // create navigator
        var navigationController = UINavigationController(rootViewController: icsDrawer)
        
        // style
        navigationController.navigationBarHidden = true
        navigationController.navigationBar.barStyle = UIBarStyle.Black
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        entryListController.topNavigatorController = navigationController
        subController.topNavigatorController = navigationController
        entryListController.drawer = icsDrawer
        
        // return
        return navigationController;
    }
}

/**
*  the all app connect key and secret
*/
struct AppKeySercet{
    static let FEEDLY_KEY          = "sandbox"
    static let FEEDLY_SERECT       = "8LDQOW8KPYFPCQV2UL6J"
    static let SHARKSDK_KEY        = "5403815558a6"
    static let WEIBO_KEY           = "879456065"
    static let WEIBO_SECRET        = "9d41612c12f271393ab0eb4204d4dd15"
    static let WEIBO_REDIRECT_URI  = "http://www.sharesdk.cn"
    static let DOUBAN_KEY          = "07d08fbfc1210e931771af3f43632bb9"
    static let DOUBAN_SECRET       = "e32896161e72be91"
    static let DOUBAN_REDIRECT_URI = "http://dev.kumoway.com/braininference/infos.php"
    
}

struct ConfKeys{
    static var keys = [IF_AUTO_REFRE,IF_INFORM,IF_CACHE_IMG,IF_AUTO_CLEAR_IMG,CACHE_SAVE_INTERVAL]
    static let IF_AUTO_REFRE          = "IF_AUTO_REFRE"
    static let IF_INFORM       = "IF_INFORM"
    static let IF_CACHE_IMG        = "IF_CACHE_IMG"
    static let IF_AUTO_CLEAR_IMG           = "IF_AUTO_CLEAR_IMG"
    static let CACHE_SAVE_INTERVAL        = "CACHE_SAVE_INTERVAL"
}


/**
*  user store key name
*/
struct UserStorKey{
    static let THEME = "theme"
}

