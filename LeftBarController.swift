//
//  LeftBarController.swift
//  AnyRead
//
//  Created by wuhanchu on 15/1/9.
//  Copyright (c) 2015年 wuhanchu. All rights reserved.
//


import Foundation
import UIKit

class LeftBarController:UITableViewController,UITableViewDelegate, UITableViewDataSource, ICSDrawerControllerChild, ICSDrawerControllerPresenting{
    // drawer
    var drawer:ICSDrawerController!
    let ACCCOUNT_CELL_ID = "ACCCOUNT_CELL_ID"
    
    override func viewDidLoad() {
        super.tableView.dataSource = self
        super.tableView.delegate = self
        super.tableView.frame.size.width  = tableView.frame.size.width * 0.5
        super.title = "选项"
    }
    
    // number of section
    override  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    // section titile
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch(section){
        case 0 : title = "订阅"
        case 1 :  title = "账户"
        case 2 :  title = "配置"
        default:  break
        }
        return title
    }
    
    // number of cell
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        switch(section){
        case 0: num = 3
        case 1: num = 2
        case 2: num = 1
        default:  break
        }
        
        return num
    }
    
    // content of cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //get the title
        var cell:UITableViewCell? = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        switch(indexPath.section){
        case 0:
            switch(indexPath.row){
            case 0 : cell?.textLabel?.text = "未读"
            case 1 : cell?.textLabel?.text = "已读"
            case 2 : cell?.textLabel?.text = "收藏"
            default:  break
            }
        case 1:
            // create the cell
            cell = self.tableView.dequeueReusableCellWithIdentifier(ACCCOUNT_CELL_ID) as?
            UITableViewCell
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: ACCCOUNT_CELL_ID)
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                var switchCtrl = UISwitch(frame: CGRectZero)
                cell?.contentView.frame.size.width  = tableView.frame.size.width * 0.5
                cell?.accessoryView = switchCtrl
                cell?.accessoryView?.sizeToFit()
                switchCtrl.setTranslatesAutoresizingMaskIntoConstraints(false)
              //  cell?.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[switchCtrl]-100-|", options: nil, metrics: nil, views: ["switchCtrl": switchCtrl]))
                
                
                switchCtrl.addTarget(self, action: "authSwitchChangeHandler:", forControlEvents:UIControlEvents.ValueChanged)
                
            }
            
            // set tag
            var switchCtrl = cell?.accessoryView as UISwitch
            switchCtrl.tag = indexPath.row
            
            // set data
            var connectTypes = ShareSDK.connectedPlatformTypes()
            if(indexPath.row <  connectTypes.count){
                
                var type =  (connectTypes[indexPath.row] as NSNumber).integerValue
                //                    var imgName = NSString(format: "Icon/sns_icon_%i.png", type)
                //                    var img = UIImage(named: imgName, bundleName: "Resource")
                //                    cell?.imageView?.image = img
                switchCtrl.on = ShareSDK.hasAuthorizedWithType(ShareType(UInt32(type)))
              
            }
            
        case 2:
            switch(indexPath.item){
            case 0 :
                cell?.textLabel?.text = "Feedly"
            default:  break
            }
        default:  break
        }
        
        //return
        return cell!
    }
    
    //select the entry
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var sonControllers =     drawer.centerViewController.childViewControllers as [UIViewController]
        
        switch(indexPath.section){
        case 0:
            switch(indexPath.row){
            case 0 :
                drawer.centerViewController.transitionFromViewController(sonControllers[1] as UIViewController, toViewController: sonControllers[indexPath.row] as UIViewController, duration: 0, options: UIViewAnimationOptions.TransitionCurlUp, animations: nil, completion: nil)
                drawer.close()

            default:  break
            }
            
        case 2 :
            loginTouchDown()
        default:  break
        }
        
    }
    
    
    /// feedly login
     func loginTouchDown() {
        drawer.close()
        
        // create feedlyClient
        var feedlyClient = AFLClient.sharedClient()
        feedlyClient.initWithApplicationId(AppKeySercet.FEEDLY_KEY , andSecret: AppKeySercet.FEEDLY_SERECT)
        
        // authen
        feedlyClient.authenticatePresentingViewControllerFrom(drawer.centerViewController, withResultBlock: authentication)
    }
    
    /// authen result handle
    func authentication(result : Bool, error :NSError!){
        if(!result){
            NSLog("authenticate error :%@", error.localizedDescription)
        }
    }
    
    // handle the switch change
    func authSwitchChangeHandler(sender:UISwitch!){
        var appDeleate = UIApplication.sharedApplication().delegate as ISSViewDelegate
        var type = sender.tag
        if(sender.on){
            ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStylePopup,viewDelegate: nil, authManagerViewDelegate: appDeleate)
            ShareSDK.getUserInfoWithType(ShareType(UInt32(type)), authOptions: nil, result: {
                (result: Bool, userInfo: ISSPlatformUser!  , error: ICMErrorInfo!) in
                
                if (result)
                {
                    NSLog("登入成功")
                }else{
                    NSLog("登入失败")
                    sender.on = false
                }
            })
            
        }else
        {
            //cancel Authoaction
            ShareSDK.cancelAuthWithType(ShareType(UInt32(type)))
        }
        tableView.reloadData()
    }
}