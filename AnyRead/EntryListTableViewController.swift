//
//  StaffListTableView.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/10/24.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

/**
*  entry table view
*/
class EntryListTableViewController: UITableViewController ,UITableViewDelegate, UITableViewDataSource{
    // feedDataDelegate
    var feedDataDelegate: FeedDataDelegate? =  FeedDataDelegate()// (UIApplication.sharedApplication().delegate as AppDelegate).feedDataDelegate
    
    //  subscription Id
    var subscription: FeedSubscription?
    
    // subscriptin data
    var subs:NSMutableDictionary?
    
    // entry datas
    var entryDatas = NSArray()
    
    // entry dates
    var entryDates = NSArray()
    
    // view load
    override func loadView() {
        // super
        super.loadView()
        
        // set the style 
        super.tableView = UITableView(frame: super.tableView.frame, style: UITableViewStyle.Plain)
        super.title = "消息"
        
        // get data
        var queryEntrys:[FeedEntry]?
        if(subscription != nil){
            queryEntrys =  feedDataDelegate?.getEntrys(subscriptionId: subscription?.id,unread: true,synced:nil, cached: nil)
        }else{
            queryEntrys =  feedDataDelegate?.getEntrys(subscriptionId: nil,unread: true,synced:nil, cached: nil)
        }
        
        // sort the data
        var lastDate = NSDate()
        var lastEntrys = NSMutableArray()
        
        var entrys = NSMutableArray()
        var dates = NSMutableArray()
        
        var calendar = NSCalendar()
        for entry in queryEntrys! {
            //check the param
            if(entry.published == nil){
                continue
            }
            
            // create the data
            var component1 =   calendar.components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitYear, fromDate: entry.published!)
            var component2 =   calendar.components(NSCalendarUnit.CalendarUnitDay|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitYear, fromDate: lastDate)
            if(component1.year == component2.year &&  component1.month == component2.month &&  component1.day == component2.day ){
                lastEntrys.addObject(entry)
            }else{
                // add current entry
                if(lastEntrys.count > 0){
                    dates.addObject(lastDate)
                    entrys.addObject(lastEntrys)
                }
                
                // create another array,
                lastDate = entry.published!
                lastEntrys = NSMutableArray()
                lastEntrys.addObject(entry)
                
            }
        }
        
        // add current entry
        if(lastEntrys.count > 0){
            dates.addObject(lastDate)
            entrys.addObject(lastEntrys)
        }
        
        self.entryDatas = entrys
        self.entryDates = dates
        
        // set right swipe gesture
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "handleSwipe:");
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    
    //MARK table view
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.entryDates.count
    }
    
    
    override  func tableView(tableView: UITableView,
        titleForHeaderInSection section: Int) -> String?{
            // get the date
            var sectionDate = entryDates[section] as NSDate
            
            // convert the date
            var formater =  NSDateFormatter()
            formater.dateFormat = "yyyy.MM.dd"
            var returnStr = formater.stringFromDate(sectionDate)
            
            // return
            return returnStr
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        // return
        return (entryDatas[section] as NSArray).count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = createCell()
        cellLoadData(cell, cellForRowAtIndexPath: indexPath)
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize)
        return size.height
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = createCell()
        cellLoadData(cell, cellForRowAtIndexPath: indexPath)
        
        //return
        return cell
    }
    
    //select the entry
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the entry
        var entry = (entryDatas[indexPath.section] as NSArray)[indexPath.item] as FeedEntry
        var entryId = entry.id
        
        // mark  read
        feedDataDelegate?.markEntryRead(entryId!)
        
        // get the detail
        var entryDetailViewController = EntryDetailViewController()
        entryDetailViewController.entryId = entryId
        self.navigationController?.pushViewController(entryDetailViewController, animated: true)
    }
    
    
    
    
    func createCell() -> UITableViewCell{
        // create the cell
        var cellIdentifier = "EntryListCell"
        var cell: UITableViewCell? =   tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if(cell == nil){
            //get the title
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
            var curCell     = cell as UITableViewCell!
            var textLabel   = curCell.textLabel!
            var detailLabel = curCell.detailTextLabel!
            
            // show
            textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            textLabel.frame           = CGRectZero
            textLabel.font            = UIFont(name: "HelveticaNeue", size: 8)
            textLabel.textColor       = UIColor.blackColor()
            textLabel.alpha           = 0.5

            detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            detailLabel.frame         = CGRectZero
            detailLabel.numberOfLines = 0
            detailLabel.font          = UIFont(name : "Heiti SC", size: 12)
            detailLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
   
           //  constraint
            var viewDict = NSDictionary(objects: [textLabel, detailLabel], forKeys:[ "textLabel","detailTextLabel"])
            var meticDict = NSDictionary(objects: [20, 5], forKeys: ["sideBuffer","verticalBuffer"])
            curCell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-verticalBuffer-[textLabel]-verticalBuffer-[detailTextLabel]-verticalBuffer-|",options: nil, metrics: meticDict, views: viewDict))
            curCell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[textLabel]-sideBuffer-|",options: nil, metrics: meticDict, views: viewDict))
            curCell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-sideBuffer-[detailTextLabel]-sideBuffer-|",options: nil, metrics: meticDict, views: viewDict))
            
            detailLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
            detailLabel.setContentCompressionResistancePriority(10, forAxis: UILayoutConstraintAxis.Horizontal)
            
            // size[p
            detailLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - (meticDict["sideBuffer"] as CGFloat)*2;
        }
        
        // return
        return cell!
    }
    
    func cellLoadData(cell: UITableViewCell , cellForRowAtIndexPath indexPath: NSIndexPath){
        // get data
        var entry:FeedEntry! = (entryDatas[indexPath.section] as NSArray)[indexPath.item] as FeedEntry
        
        // load data
        var textLabel = cell.textLabel
        var detailLabel = cell.detailTextLabel
        
        // get the subscription
        if(entry.published != nil){
            // get time
            var formatter =   NSDateFormatter()
            formatter.dateFormat = "HH:mm"
            var time = formatter.stringFromDate(entry.published!)
            
            // get subscription name
            var subName = (subs?.valueForKey(entry.subscriptionId!) as FeedSubscription).title
            
            // get show String
            textLabel?.text =  time + " | " + subName
        }
        if(entry.title != nil){
            
            // todo
            var attributedString1 = NSMutableAttributedString(string: entry.title!)
            var paragraphStyle1 =  NSMutableParagraphStyle()
            paragraphStyle1.lineSpacing = 6
            paragraphStyle1.lineBreakMode =  NSLineBreakMode.ByCharWrapping
           
            
            attributedString1.addAttribute(NSParagraphStyleAttributeName , value: paragraphStyle1, range: NSMakeRange(0, entry.title!.length))
            detailLabel?.attributedText = attributedString1
            
          //  detailLabel?.text = entry?.title
        }
        
        // set unred color
        if(entry?.unread == false){
            textLabel?.textColor = UIColor.grayColor()
            detailLabel?.textColor = UIColor.grayColor()
        }
    }
    
    
    
    //MARK handle event
    // handle swipe
    func handleSwipe(swipeLeft: UISwipeGestureRecognizer){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
