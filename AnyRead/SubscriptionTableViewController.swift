//
//  SubscptionTableViewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/11/15.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

/**
*  subsription tableview controller
*/
class SubscriptionTableViewController: UITableViewController,UITableViewDelegate, UITableViewDataSource,ICSDrawerControllerChild, ICSDrawerControllerPresenting{
    
    // cel identifier
    let CELL_IDENTIFIER  = "subCell"
    
    // drawer
    var drawer:ICSDrawerController!
    
    // feed Data
    var feedDataDelegate:FeedDataDelegate! = (UIApplication.sharedApplication().delegate as AppDelegate).feedDataDelegate!
    
    // subscription data
    var data:NSMutableArray!  = NSMutableArray()
    var subDict:NSMutableDictionary!  = NSMutableDictionary()
    
    // num
    var nums:NSMutableArray! = []
    
    // total entry num
    var totalNum:Int  = 0
    
    // queue
    var queue = NSOperationQueue()
    
    
    override func loadView() {
        
        //super
        super.loadView()
        super.title = "订阅"
        
        super.tableView = UITableView(frame:  super.tableView.frame, style: UITableViewStyle.Grouped)
        super.tableView.dataSource = self
        super.tableView.delegate = self
        super.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLineEtched
        
        // set the refresh method
        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
        
        feedDataDelegate.curViewController = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadData()
        self.tableView.reloadData()
    }
    
    override  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title:String
        switch(section){
        case 1 :  title = "订阅"
        default:  title = ""
        }
        return title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var cellnum:Int! = 0
        if(section == 0){
            cellnum = 1
        }else{
            cellnum = self.data.count
        }
        
        // return
        return cellnum
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // get cell
        var cell: UITableViewCell? =   tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? UITableViewCell
        if(cell == nil){
            // create
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_IDENTIFIER)
            
            // number view
            cell?.accessoryView =  UILabel()
            
            // show
            cell?.textLabel?.font          = UIFont(name: "HelveticaNeue", size: 14)
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        }
        
        // get the entry number
        var num: Int?
        var name: String?
        var numLabel = cell?.accessoryView as UILabel
        
        // the first secion
        if(indexPath.section == 0){
            num = totalNum
            name = NSLocalizedString("all", comment: "")
        }
            
            // other section
        else{
            //get the title
            var feed: FeedSubscription? = data[indexPath.item] as FeedSubscription
            name = feed?.title
            
            // get the num
            num = nums[indexPath.row] as Int
        }
        
        cell?.textLabel?.text = name!
        numLabel.textColor = UIColor.grayColor()
        numLabel.text = NSString(format: "%i 》", num!)
        numLabel.sizeToFit()
        
        //return
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // create the view controller
        var entryListViewController =  EntryListTableViewController()
        
        // get the data
        entryListViewController.subs = self.subDict
        if(indexPath.section != 0){
            entryListViewController.subscription = self.data[indexPath.item] as FeedSubscription
        }
        
        // push
         self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(entryListViewController, animated: true)
    }
    
    
    // pull table to refresh
    func pullToRefresh(){
        self.refreshControl?.beginRefreshing()
        
        self.feedDataDelegate?.syncFeedData()
        
        refreshControl?.endRefreshing()
    }
    
    func endSync(){
        self.tableView?.reloadData()
    }
    
    func loadData(){
        // judge the param is not nil
        if(feedDataDelegate  == nil){
            return
        }
        
        // get the subscription data
        var  tmmpData = self.feedDataDelegate.getSubscription()
        subDict = NSMutableDictionary()
        data = NSMutableArray()
        nums = NSMutableArray()
        totalNum = 0
        
        // get the entry number
        for subscription in tmmpData {
            var num = feedDataDelegate?.getEntrys(subscriptionId: (subscription as FeedSubscription).id, unread: true, synced: nil, cached: nil).count
            if(num != 0){
                subDict.setValue(subscription, forKey: subscription.id)
                data.addObject(subscription)
                nums.addObject(num!)
                totalNum += num!
            }
        }
    }
}
