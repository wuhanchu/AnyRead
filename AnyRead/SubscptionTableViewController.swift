//
//  SubscptionTableViewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/11/15.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class SubscptionTableViewController: UITableViewController, RETableViewManagerDelegate{
    // table manager
    var manager:RETableViewManager?
    
    // feedly client
    var feedlyClient:AFLClient?
    
    // sub section
    var subSection: RETableViewSection?
    
   override func viewDidLoad() {
        super.viewDidLoad()
    
        // get data
        var feedDataDelegate =  FeedDataDelegate()
        var subscripitionDatas =  feedDataDelegate.getSubscription()
    
        // create table manager
        manager = RETableViewManager(tableView: self.tableView)
        manager?.delegate = self
    
        var section2 = RETableViewSection(headerTitle: "sub")
        manager?.addSection(section2)
    
        for subscripitionData in subscripitionDatas{
            var accountItem = RETableViewItem(title: subscripitionData.title, accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler: subSelect)
            section2.addItem(accountItem)
        }
    }
    
    
    // select account
    func subSelect(item: RETableViewItem!){
        self.navigationController?.pushViewController(EntryListTableViewController(), animated: true)
    }
}
