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
class SubscriptionTableViewController: UITableViewController,FeedRefreshViewController,UITableViewDelegate, UITableViewDataSource,ICSDrawerControllerChild, ICSDrawerControllerPresenting,UIAlertViewDelegate{
    // cel identifier
    let CELL_IDENTIFIER  = "subCell"
    // drawer
    var drawer:ICSDrawerController!
    // feed Data
    var feedManager:FeedDataManager! = (UIApplication.sharedApplication().delegate as AppDelegate).feedManager!
    // subscription data
    var sectionDatas = NSMutableArray()
    var rowDatas  = NSMutableArray()
    var subDict = NSMutableDictionary()
    // num
    var nums:NSMutableArray! = []
    // total entry num
    var totalNum:Int  = 0
    // queue
    var queue = NSOperationQueue()
    // entry list view
    var entryListController:EntryListTableViewController?
    //topNavigatorController
    var topNavigatorController: UINavigationController?
    // confController
    var confController = ConfController()
    var loginViewController: LoginViewController?
    
    override func loadView() {
        //super
        super.loadView()
        
        // tableView
        super.tableView = UITableView(frame:  super.tableView.frame, style: UITableViewStyle.Grouped)
        super.tableView.dataSource = self
        super.tableView.delegate = self
        
        
        // add to feedManager
        feedManager.addRefreshViewController(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        //super
        super.viewWillAppear(animated)
        
        //tableview
        self.tableView.frame = CGRect(x: 0, y: 0, width: 260, height: UIScreen.mainScreen().bounds.height)
        super.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        super.tableView.sectionFooterHeight = 0
        self.tableView.separatorColor = Theme.sepratorColor
        self.tableView.backgroundColor = Theme.backgroundColor
        
        //datea
        self.loadData()
        self.tableView.reloadData()
    }
    
    override  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionDatas.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // get data
        var sectionData = sectionDatas[section] as SectionData
        if(sectionData.title == nil){
            return nil
        }
        
        //create the section
        var categorySection = CategorySection(frame: CGRectZero)
        categorySection.loadData(sectionData)
        categorySection.loadTheme()
        categorySection.index = section
        categorySection.tableView = self.tableView
        categorySection.addTarget(self, action: "categorySelect:", forControlEvents: UIControlEvents.TouchDown)
        
        // return
        return categorySection
    }
    
    func categorySelect(sender: CategorySection){
        if(sender.index == nil){
            return
        }
        
        var querySubscription = NSMutableArray()
        for cellData in rowDatas[sender.index!] as [CellData]{
            if(cellData.subscpriton != nil){
                querySubscription.addObject(cellData.subscpriton!)
            }
        }
        entryListController?.subscriptions = querySubscription
        entryListController?.refreshView()
        self.drawer.close()
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return
        var sectionData =  sectionDatas[section] as SectionData
        var status = sectionData.status
        if(status || section == 0){
            return (rowDatas[section] as NSArray).count
        }else{
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        var cellData = (rowDatas[indexPath.section] as NSArray)[indexPath.item] as CellData
        switch(indexPath.section){
        case 0:
            cell =   tableView.dequeueReusableCellWithIdentifier("setting") as? UITableViewCell
            if(cell == nil){
                cell = SubscriptionCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "setting")
            }
            cell?.textLabel?.text = cellData.title
            if(indexPath.item == 0){
                cell?.detailTextLabel?.text = cell?.detailTextLabel?.text?.stringByAppendingString("login")
            }
             cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            Theme.drawCell(cell!)
        default:
            // get cell
            cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? SubscriptionCell
            if(cell == nil){
                // create
                cell = SubscriptionCell(style: UITableViewCellStyle.Default, reuseIdentifier: CELL_IDENTIFIER)
            }
            var tempCell =  cell as SubscriptionCell
            tempCell.loadData(cellData)
            tempCell.loadTheme()
        }
        
        //return
        return cell!
    }
    
    func endSync(){
        self.tableView?.reloadData()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1){
            if(  NSUserDefaults.standardUserDefaults().objectForKey("feedly/token") != nil){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "feedly/token")
            }
            AFLClient.sharedClient().logout()
            self.loginViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // get the data
        
        switch(indexPath.section){
        case 0:
            switch(indexPath.item){
            case 0 :
                // shwo alert
                var alertView = UIAlertView(title: "是否登出？", message: "", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "确认")
                alertView.show()
                alertView.delegate = self
            case 1 :
                topNavigatorController?.pushViewController(confController, animated: true)
            default:
                NSLog("")
            }
        default:
            entryListController?.subs = self.subDict
 
                var subscription = ((self.rowDatas[indexPath.section] as NSArray)[indexPath.item] as CellData).subscpriton
                entryListController?.subscriptions = [subscription!]
                
            
            entryListController?.refreshView()
            self.drawer.close()
        }
    }
    
    
    
    func loadData(){
        // judge the param is not nil
        if(feedManager  == nil){
            return
        }
        
        //table data
        sectionDatas = NSMutableArray()
        rowDatas = NSMutableArray()
        
        //get the data
        var subscriptionDatas = self.feedManager.dataManager.getSubscription()
        var categoryDatas = NSMutableArray(array: self.feedManager.dataManager.getEntitys("FeedCategory"))
        
        // add first secion
        sectionDatas.addObject(SectionData(title: nil, num: nil, category: nil))
        var settingRow = NSMutableArray()
        settingRow.addObject(CellData(title: "Feedly", num: nil, subscpriton: nil))
        settingRow.addObject(CellData(title: "设置", num: nil, subscpriton: nil))
        rowDatas.addObject(settingRow)
        
        //section section
        var totalNum = feedManager?.dataManager.getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: nil,saved:nil).count
        sectionDatas.addObject(SectionData(title: "所有", num: totalNum, category: nil))
        rowDatas.addObject( NSMutableArray())
        
        
        // other seccton
        var subscriptionCellDatas = NSMutableArray()
        var haveNumArray = NSMutableArray()
        var zeroNumArray = NSMutableArray()
        for subscription in subscriptionDatas {
            var num = feedManager?.dataManager.getEntrys(subscriptionId: (subscription as FeedSubscription).id, unread: true, synced: nil, cached: nil,saved:nil).count
            var subscriptionData =   CellData(title: subscription.title, num: num, subscpriton: subscription as FeedSubscription)
            subDict.setValue(subscription, forKey: subscription.id)
            if(num > 0){
                haveNumArray.addObject(subscriptionData)
            }else{
                zeroNumArray.addObject(subscriptionData)
            }
        }
        subscriptionCellDatas.addObjectsFromArray(haveNumArray)
        subscriptionCellDatas.addObjectsFromArray(zeroNumArray)
        
        
        
        // load the table data
        for categoryData in categoryDatas{
            var data = NSMutableArray()
            var sectionNum = 0
            for subscriptionCellData in subscriptionCellDatas{
                var cellData =   subscriptionCellData as CellData
                var subscpriton = cellData.subscpriton
                if(subscpriton!.categories.containsObject(categoryData)){
                    data.addObject(cellData)
                    sectionNum += cellData.num!
                }
            }
            rowDatas.addObject(data)
            var sectionData =  SectionData(title: categoryData.label, num: sectionNum, category: categoryData as FeedCategory)
            sectionData.sonNum = data.count
            sectionData.status = false
            sectionDatas.addObject(sectionData)
        }
        
        // add lat section
        var sectionNum = 0
        var uncategoryArray =  NSMutableArray()
        for subscriptionCellData in subscriptionCellDatas{
            var cellData =   subscriptionCellData as CellData
            var subscpriton = cellData.subscpriton
            if(subscpriton!.categories.count == 0){
                uncategoryArray.addObject(cellData)
                sectionNum += cellData.num!
            }
        }
        if(uncategoryArray.count > 0){
            rowDatas.addObject(uncategoryArray)
            var sectionData =   SectionData(title: "未划分", num: sectionNum, category: nil)
            sectionData.status = false
            sectionData.sonNum = uncategoryArray.count
            sectionDatas.addObject(sectionData)
        }
    }
    
    func refreshView() {
        self.loadData()
        self.tableView.reloadData()
    }
    
    
}

//setcion data
class SectionData:NSObject{
    var title:NSString?
    var num:Int?
    var category:FeedCategory?
    var sonNum = 0
    var status = false
    
    init(title:NSString?,num:Int?, category:FeedCategory?){
        self.title = title
        self.num = num
        self.category = category
    }
}

// CellData
class CellData:NSObject{
    var title:NSString!
    var num:Int?
    var subscpriton:FeedSubscription?
    
    init(title:NSString!,num:Int?, subscpriton:FeedSubscription?){
        self.title = title
        self.num = num
        self.subscpriton = subscpriton
    }
}


class CategorySection: UIControl{
    var button = UIButton()
    var tagLabel = UILabel()
    var numLabel = UILabel()
    var index: Int?
    var sectionData: SectionData?
    var tableView: UITableView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        tagLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        numLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        button.addTarget(self, action: "buttonDown:", forControlEvents: UIControlEvents.TouchDown)
        
        
        
        //  button.sizeToFit()
        self.addSubview(button)
        self.addSubview(tagLabel)
        self.addSubview(numLabel)
        
        var viewDict = ["button":button , "tagLabel": tagLabel, "numLabel": numLabel ]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-5-[button(==20)]-10-[tagLabel]-(>=5)-[numLabel]-10-|", options: nil, metrics: nil, views: viewDict))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[button(==20)]", options: nil, metrics: nil, views: viewDict))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: tagLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: numLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        loadTheme()
    }
    
    
    func loadData(data:SectionData){
        sectionData = data
        tagLabel.text = data.title
        if(data.num != nil && data.num != 0){
            numLabel.text = NSString(format: "%i", data.num!)
        }else{
            numLabel.text = nil
        }
        
        if(sectionData?.sonNum != 0){
            var status = sectionData?.status
            var imgName:NSString?
            if(!status!){
                imgName = "br_next"
            }else{
                imgName = "br_down"
         
            }
            if(Theme.currentTheme ==  ThemeType.dayTheme){
                imgName = imgName?.stringByAppendingString("_black")
            }
            button.setImage(UIImage(named: imgName!), forState: UIControlState.Normal)
        }else{
            button.enabled = false
        }
    }
    
    func loadTheme(){
        tagLabel.font = Theme.titleFont
        tagLabel.textColor = Theme.titleColor
        numLabel.font = Theme.annotateFont
        numLabel.textColor = Theme.annotateColor
        self.backgroundColor = Theme.backgroundColor
    }
    
    func buttonDown(sender: UIButton){
        var status = sectionData?.status
        sectionData?.status = !status!
        tableView?.reloadSections( NSIndexSet(index: index!), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// acoutn  cell
class SubscriptionCell:UITableViewCell{
    var titleLabel = UILabel()
    var numLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        var viewDict = [ "titleLabel": titleLabel, "numLabel": numLabel ]
        
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        numLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(numLabel)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-35-[titleLabel]-(>=10)-[numLabel]-10-|", options: nil, metrics: nil, views: viewDict))
        self.contentView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        self.contentView.addConstraint(NSLayoutConstraint(item: numLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    func loadTheme(){
        titleLabel.font = Theme.titleFont
        titleLabel.textColor = Theme.titleColor
        numLabel.font = Theme.annotateFont
        numLabel.textColor = Theme.annotateColor
        self.backgroundColor = Theme.cellGroundColor
    }
    
    func loadData(data:CellData){
        //get the title
        self.titleLabel.text = data.title
        if(data.num != 0){
            self.numLabel.text = NSString(format: "%i", data.num!)
        }else{
            self.numLabel.text = nil
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
