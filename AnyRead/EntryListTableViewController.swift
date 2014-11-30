//
//  StaffListTableView.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/10/24.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class EntryListTableViewController: UITableViewController, RETableViewManagerDelegate{

    var manager:RETableViewManager?
    
    // view load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get data
        var feedDataDelegate =  FeedDataDelegate()
        var entryDatas =  feedDataDelegate.getEntry()
        
        // create table manager
        manager = RETableViewManager(tableView: self.tableView)
        manager?.delegate = self
        
        var section2 = RETableViewSection(headerTitle: "entry")
        manager?.addSection(section2)
        
        for entryData in entryDatas{
            var accountItem = RETableViewItem(title: entryData.title, accessoryType: UITableViewCellAccessoryType.DisclosureIndicator, selectionHandler: selectEntry)
            section2.addItem(accountItem)
        }
    }
    
    func selectEntry(item: RETableViewItem!){
        self.navigationController?.pushViewController(EntryDetailTableViewController(), animated: true)
    }
}
