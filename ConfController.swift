//
//  LeftBarController.swift
//  AnyRead
//
//  Created by wuhanchu on 15/1/9.
//  Copyright (c) 2015年 wuhanchu. All rights reserved.
//


import Foundation
import UIKit

class ConfController:UITableViewController,UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, ICSDrawerControllerChild, ICSDrawerControllerPresenting,ISSViewDelegate{
    // drawer
    var drawer:ICSDrawerController!
    //conntect types
    var connectTypes = ShareSDK.connectedPlatformTypes()
    // conf title
    var titles = ["自动刷新","是否通知","缓存图片"]//,"是否自动清楚缓存","缓存保留时间"
    // feedManager
    var feedManager = (UIApplication.sharedApplication().delegate as AppDelegate).feedManager
    var dataManager = DataManager()
    var alertView:UIAlertView?
    
    // cell
    let ACCCOUNT_CELL_ID = "ACCCOUNT_CELL_ID"
    let SWITCH_CELL_ID = "SWITCH_CELL_ID"
    let BUTTON_CELL_ID = "BUTTON_CELL_ID"
    
    override func loadView() {
        super.loadView()
        
        // table view
        self.tableView = UITableView(frame:  super.tableView.frame, style: UITableViewStyle.Grouped)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // alert view
        alertView = UIAlertView(title: "", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "确认")
        
        // set right swipe gesture
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        Theme.drawTableView(tableView)
        self.tableView.reloadData()
        
        // navigateor bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        // navigateor bar
       self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // number of section
    override  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    
    // section titile
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch(section){
        case 0 : title = "通用"
        case 1 : title = "账户"
        case 2 : title = "高级"
        default:  break
        }
        return title
    }
    
    // number of cell
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        switch(section){
        case 0: num = titles.count
        case 1: num = connectTypes.count
        case 2: num = 1
        default:  break
        }
        
        return num
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    // content of cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //get the title
        var cell:UITableViewCell?
        switch(indexPath.section){
        case 0:
            switch(indexPath.item){
            default:
                cell = self.tableView.dequeueReusableCellWithIdentifier(SWITCH_CELL_ID) as? UITableViewCell
                if(cell == nil){
                    cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: SWITCH_CELL_ID)
                    cell?.selectionStyle = UITableViewCellSelectionStyle.None
                }
                cell?.textLabel?.text = self.titles[indexPath.item]
               
                var switcher = UISwitch()
                var value = NSUserDefaults.standardUserDefaults().boolForKey(ConfKeys.keys[indexPath.item])
                switcher.on = value
                switcher.tag = indexPath.item
                switcher.addTarget(self, action: "switchChange:", forControlEvents: UIControlEvents.ValueChanged)
                cell?.accessoryView = switcher
            }

        case 1:
            cell = self.tableView.dequeueReusableCellWithIdentifier(ACCCOUNT_CELL_ID) as? UITableViewCell
            if(cell == nil){
                cell = AccountConfCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: ACCCOUNT_CELL_ID)
                 cell?.selectionStyle = UITableViewCellSelectionStyle.None
            }
            var tempcell = cell as AccountConfCell
            
            // set data
            if(indexPath.item <  connectTypes.count){
                // get the type
                var type =  (connectTypes[indexPath.item] as NSNumber).integerValue
                tempcell.nameLabel.text = ShareSDK.getClientNameWithType(ShareType(UInt32(type)))
                
                // set the switch
                var switchCtrl = tempcell.switchAcc
                switchCtrl.tag = type
                switchCtrl.addTarget(self, action: "authSwitchChangeHandler:", forControlEvents: UIControlEvents.ValueChanged)
                
                // set the img
                tempcell.imgView.image = UIImage(named: NSString(format: "Icon/sns_icon_%i.png", type), bundleName: "Resource")
                if(ShareSDK.hasAuthorizedWithType(ShareType(UInt32(type)))){
                    switchCtrl.on =  true
                    
                    // get the name
                    var option = ShareSDK.authOptionsWithAutoAuth(true, allowCallback: true, authViewStyle: SSAuthViewStyleFullScreenPopup, viewDelegate: nil, authManagerViewDelegate: self)
                    ShareSDK.getUserInfoWithType(ShareType(UInt32(type)), authOptions: option, result: {
                        (result: Bool, userInfo:ISSPlatformUser!, error: ICMErrorInfo!) in
                        if(result){
                            tempcell.detailTextLabel?.text = userInfo.nickname()
                        }
                    })
                }else{
                    switchCtrl.on =  false
                }
            }
        case 2:    
            cell = self.tableView.dequeueReusableCellWithIdentifier(BUTTON_CELL_ID) as? UITableViewCell
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: BUTTON_CELL_ID)
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                cell?.textLabel?.textAlignment = NSTextAlignment.Center
            }
            cell?.textLabel?.text = "清除缓存"
            
        default:
            break;
        }
        
        // cell them
        Theme.drawCell(cell!)
 
        
        //return
        return cell!
    }
    
    func switchChange(sender: UISwitch){
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: ConfKeys.keys[sender.tag])
        switch(sender.tag){
        
        default:
            NSLog("conf change")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       switch indexPath.section {
       case 2:
            alertView?.title = "是否清除缓存?"
            alertView?.show()
       default:
            NSLog("dafalust")
       }
    }
    
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 1){
          feedManager?.cleardata()
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
                    sender.on = true
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
    
    override func tabImageName() -> String!{
        return "image-3";
    }
    
    override func tabTitle() -> String! {
        return "配置"
    }
    // handle gesture
    func swipeRight(swipeRecognizer: UISwipeGestureRecognizer){
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.toolbarHidden = true
    }
}

// acoutn  cell
class AccountConfCell:UITableViewCell{
    var switchAcc: UISwitch =  UISwitch()
    var imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    var nameLabel: UILabel = UILabel()
    
    let IMAGE_SIZE = 35.0
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        super.accessoryView = switchAcc
        imgView = super.imageView!
        nameLabel = super.textLabel!
        super.contentView.addSubview(switchAcc)
        super.contentView.addSubview(imgView)
        super.contentView.addSubview(nameLabel)
        var views = NSDictionary(dictionary: ["switchAcc": switchAcc, "nameLabel": nameLabel,  "imageView":imgView])
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override  func layoutSubviews() {
        super.layoutSubviews()
        imgView.frame = CGRect(x: imgView.frame.origin.x, y: (self.frame.size.height-30)/2, width: 30, height: 30)
        NSLog("sdf")
        var originX = detailTextLabel?.frame.origin.x
        if(originX != nil){
            nameLabel.frame.origin.x = originX!
        }else{
           nameLabel.frame.origin.x = 70
        }
    }
}
