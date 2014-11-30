//
//  StaffMangerVIewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/11/6.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Fabric
import Crashlytics

class ManagerViewController: UITableViewController, RETableViewManagerDelegate{
    // table manager
    var manager:RETableViewManager?

    // data sync delegate
    var feedDataDeleaget: FeedDataDelegate?

    
    // view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create table manager
        manager = RETableViewManager(tableView: self.tableView)
        manager?.delegate = self
        
        // createa feed delegate
        feedDataDeleaget = FeedDataDelegate()
        
        
        // create section
        var section2 = RETableViewSection(headerTitle: "操作")
        manager?.addSection(section2)
        var accountItem = RETableViewItem(title: "登陆", accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler: accountSelect)
        section2.addItem(accountItem)
        var refreshItem = RETableViewItem(title: "刷新", accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler:refreshItemSelect)
        section2.addItem(refreshItem)
        var subItem = RETableViewItem(title: "Feedly", accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler:feedlySub)
        section2.addItem(subItem)
        
        var crashItem = RETableViewItem(title: "测试异常", accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler:testCrash)
        section2.addItem(crashItem)
    }
    
    // select account
    func accountSelect(item: RETableViewItem!){
        
        // create feedlyClient
        var feedlyClient = AFLClient.sharedClient()
        feedlyClient.initWithApplicationId("sandbox", andSecret: "A0SXFX54S3K0OC9GNCXG")
        
        // authen
        feedlyClient.authenticatePresentingViewControllerFrom(self, withResultBlock: authentication)
    }
    
    func testCrash(item: RETableViewItem!){
        
        // fabric
        Crashlytics.sharedInstance().crash()

    }
    
    // refresh item
    func refreshItemSelect(item: RETableViewItem!){
        // sync data
        feedDataDeleaget?.syncFeedData()
    }
    
    // select the feedly
    func feedlySub(item : RETableViewItem!){
        var subController = SubscptionTableViewController()
        self.navigationController?.pushViewController(subController, animated: true)
    }
    
    // authen result handle
    func authentication(result : Bool, error :NSError!){
        if(!result){
            NSLog("sync error :%@", error.localizedDescription)
        }
    }
}
