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
class EntryListTableViewController: UITableViewController ,FeedRefreshViewController,UITableViewDelegate, UITableViewDataSource,ICSDrawerControllerChild{
    // feedManager
    var feedManager: FeedDataManager? =   (UIApplication.sharedApplication().delegate as AppDelegate).feedManager
    //  subscription Id
    var subscriptions = []
    // entry datas
    var entryDatas = NSArray()
    // entry dates
    var entryDates = NSArray()
    var subs = NSMutableDictionary()
    // the main navigator
    var topNavigatorController : UINavigationController?
    // the segement
    var segmentedControl:UISegmentedControl?
    //entryDetailViewController
    var entryDetailViewController = EntryDetailViewController()
    // drawer
    var drawer:ICSDrawerController!
    // cell identifier
    var cellIdentifier = "EntryListCell"
    // view load
    override func loadView() {
        // super
        super.loadView()
        
        // set the style
        super.tableView = UITableView(frame: super.tableView.frame, style: UITableViewStyle.Grouped)
        super.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        super.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 0, 15)
        
        // set right swipe gesture
        var swipeRight = UISwipeGestureRecognizer(target: self,action: "handleSwipe:");
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        // set the refresh control
        var refresh = UIRefreshControl()
        refresh.addTarget(self,action: "pullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
        
        // add to feedManager
        feedManager?.addRefreshViewController(self)
        
        // load the navigation itme
        segmentedControl = UISegmentedControl(items:[ "所有","未读","保存"])
        segmentedControl?.tintColor = UIColor.whiteColor()
        segmentedControl?.selectedSegmentIndex = 1
        segmentedControl?.addTarget(self,action: "switchSegement:", forControlEvents: UIControlEvents.ValueChanged)
        self.navigationItem.titleView = segmentedControl
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(named:"align_just"), style: UIBarButtonItemStyle.Plain, target: self,action: "leftBarButtonDown:")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
        // theme switch
        var switcher = SevenSwitch()
        switcher.knobColor = UIColor(red:0.19,green:0.23,blue:0.33, alpha:0.80);
        switcher.onColor = UIColor(red:0.07,green:0.09,blue:0.11 ,alpha:0.50);
        switcher.inactiveColor = UIColor.whiteColor()
        switcher.activeColor  =  UIColor(red:0.07 ,green:0.09 ,blue:0.11 ,alpha:1.00);
        switcher.borderColor = UIColor.clearColor()
        switcher.shadowColor = UIColor.blackColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: switcher)
        switcher.addTarget(self, action: "changeTheme:", forControlEvents: UIControlEvents.ValueChanged)
        if(Theme.currentTheme == ThemeType.nightTheme){
            switcher.on = true
        }else{
            switcher.on = false
        }
        
        // add footerView
        self.tableView.tableFooterView = UIView()
        self.tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
        
        // load the data
        loadData()
        
        // set table view theme
        setTableViewTheme()
    }
    
    
    func leftBarButtonDown(sender: UIBarButtonItem){
        self.drawer.open()
    }
    
    func changeTheme(sender: SevenSwitch){
        if(sender.on == true){
            Theme.changeTheme(ThemeType.nightTheme)
            // save the config
            NSUserDefaults.standardUserDefaults().setInteger(ThemeType.nightTheme.rawValue, forKey: UserStorKey.THEME)
        }else{
            Theme.changeTheme(ThemeType.dayTheme)
            // save the config
            NSUserDefaults.standardUserDefaults().setInteger(ThemeType.dayTheme.rawValue, forKey: UserStorKey.THEME)
        }
        
        setTableViewTheme()
        
        //reload
        self.tableView.reloadData()
    }
    
    func setTableViewTheme(){
        // change  viwe
        self.tableView.backgroundColor = Theme.backgroundColor
        self.tableView.separatorColor = Theme.sepratorColor
    }
    
    
    /**
    change  the segement
    
    :param: segmentedControl <#segmentedControl description#>
    */
    func switchSegement(segmentedControl: UISegmentedControl){
        NSLog("switchSegement")
        // refresh the data
        loadData()
        self.tableView.reloadData()
    }
    
    func loadData(){
        // get select type
        var type = segmentedControl?.selectedSegmentIndex
        
        // judge the subscription
        //  subs = NSMutableDictionary()
        var tempsubs = feedManager?.dataManager.getSubscription()
        for subscritpion in tempsubs! {
            subs.setValue(subscritpion, forKey: subscritpion.id)
        }
        
        // get data
        var queryEntrys =  NSMutableArray()
        var unread:Bool?
        var saved:Bool?
        switch(type!){
        case 1 :
            unread = true
            saved = nil
        case 2 :
            unread = false
            saved = true
        default:
            unread = nil
            saved = nil
        }
        
        if(subscriptions.count > 0){
            for susbcription in subscriptions{
                var currentSubscription =  feedManager?.dataManager.getEntrys(subscriptionId: susbcription.id,unread: unread,synced:nil, cached: nil,saved:saved)
                queryEntrys.addObjectsFromArray(currentSubscription!)
            }
        }else{
            var currentSubscription =  feedManager?.dataManager.getEntrys(subscriptionId: nil,unread: unread,synced:nil, cached: nil, saved: saved)
            queryEntrys.addObjectsFromArray(currentSubscription!)
        }
        
        // sort the data
        var lastDate = NSDate()
        var lastEntrys = NSMutableArray()
        
        var entrys = NSMutableArray()
        var dates = NSMutableArray()
        
        var calendar = NSCalendar()
        for entry in queryEntrys {
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
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        refreshView()
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
            formater.dateFormat = "yyyy-MM-dd"
            var returnStr = formater.stringFromDate(sectionDate)
            
            // return
            return returnStr
    }
    
    override  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        var view = UILabel(frame: CGRectZero)
        // get the date
        var sectionDate = entryDates[section] as NSDate
        
        // convert the date
        var formater =  NSDateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        var returnStr = formater.stringFromDate(sectionDate)
        
        view.text = returnStr
        view.textColor = Theme.annotateColor
        view.font = Theme.annotateFont
        view.backgroundColor = Theme.sectionBackgroundColor
        view.textAlignment = NSTextAlignment.Center
        
        // return
        return view
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return
        return (entryDatas[section] as NSArray).count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // create the cell
        var cell =   tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? EntryCell
        if(cell == nil){
            //get the title
            cell = EntryCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // load data
        var entry:FeedEntry! = (entryDatas[indexPath.section] as NSArray)[indexPath.item] as FeedEntry
        cell?.loadData(entry, subs: subs)
        
        // load theme
        cell?.loadTheme()
        
        //return
        return cell!
    }
    
    //select the entry
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the detail
        entryDetailViewController.entryDatas = entryDatas[indexPath.section] as [FeedEntry]
        entryDetailViewController.entryIndex = indexPath.item
        self.topNavigatorController?.pushViewController(entryDetailViewController, animated: true)
    }
    
    ///MARK tab img and title
    override func tabImageName() -> String!{
        return "image-1";
    }
    
    override func tabTitle() -> String! {
        return "消息"
    }
    
    //MARK handle event
    // handle swipe
    func handleSwipe(swipeLeft: UISwipeGestureRecognizer){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    // pull table to refresh
    func pullToRefresh(refresh: UIRefreshControl){
        refresh.beginRefreshing()
        feedManager?.syncFeedData()
        refresh.endRefreshing()
    }
    
    func refreshView() {
        loadData()
        self.tableView.reloadData()
        self.akTabBarController()
    }
    
    func setRead(sender: UIButton){
        //make read
        var entrys = self.entryDatas[sender.tag] as [FeedEntry]
        for entry in entrys{
            feedManager?.markEntryRead(entry.id!)
        }
        
        //refresh
        refreshView()
    }
}


class EntryCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var titleLabel:UILabel! = self.textLabel!
        var detailLabel:UILabel! = self.detailTextLabel!
        
        // show
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.frame           = CGRectZero
        titleLabel.font            = UIFont.systemFontOfSize(10)
        titleLabel.textColor       = UIColor.blackColor()
        titleLabel.alpha           = 0.5
        
        detailLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailLabel.frame         = CGRectZero
        detailLabel.numberOfLines = 2
        detailLabel.font            = UIFont.systemFontOfSize(13)
        detailLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        //  constraint
        var viewDict = NSDictionary(objects: [titleLabel, detailLabel], forKeys:[ "textLabel","detailTextLabel"])
        var meticDict = NSDictionary(objects: [10, 5], forKeys: ["sideBuffer","verticalBuffer"])
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-14-[textLabel]-verticalBuffer-[detailTextLabel]-(>=verticalBuffer)-|",options: nil, metrics: meticDict, views: viewDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-sideBuffer-[textLabel]-sideBuffer-|",options: nil, metrics: meticDict, views: viewDict))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-sideBuffer-[detailTextLabel]-sideBuffer-|",options: nil, metrics: meticDict, views: viewDict))
        
        detailLabel.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Vertical)
        detailLabel.setContentCompressionResistancePriority(10, forAxis: UILayoutConstraintAxis.Horizontal)
        
    }
    
    func loadData(entry: FeedEntry, subs: NSDictionary){
        // load data
        var titleLabel:UILabel! = self.textLabel!
        var detailLabel:UILabel! = self.detailTextLabel!
        
        
        // get the subscription
        if(entry.published != nil){
            // get time
            var formatter =   NSDateFormatter()
            formatter.dateFormat = "HH:mm"
            var time = formatter.stringFromDate(entry.published!)
            
            // get subscription name
            var subscription = subs.objectForKey(entry.subscriptionId!)
            var subscriptionName:NSString? = subscription?.title
            
            // get show String
            textLabel?.text =  time
            if(subscriptionName != nil){
                textLabel?.text = NSString(format: "%@|%@", subscriptionName!, time)
            }
        }
        
        if(entry.title != nil){
            
            // todo
            var attributedString = NSMutableAttributedString(string: entry.title!)
            var paragraphStyle =  NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            paragraphStyle.lineBreakMode =  NSLineBreakMode.ByCharWrapping
            
            
            attributedString.addAttribute(NSParagraphStyleAttributeName , value: paragraphStyle, range: NSMakeRange(0, entry.title!.length))
            detailLabel?.attributedText = attributedString
        }
        
        //set the img
        if(entry.imgData != nil){
            var imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
            imgView.image = UIImage(data: entry.imgData!)
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.clipsToBounds = true
            self.accessoryView = imgView
        }else{
            self.accessoryView = nil
        }
    }
    
    
    func loadTheme(){
        //set theme
        self.backgroundColor = Theme.cellGroundColor
        self.textLabel?.font = Theme.annotateFont
        self.textLabel?.textColor = Theme.annotateColor
        self.detailTextLabel?.font = Theme.titleFont
        self.detailTextLabel?.textColor = Theme.titleColor
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}