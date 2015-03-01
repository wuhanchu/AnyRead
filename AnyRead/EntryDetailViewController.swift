//
//  StaffDetailTableViewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/10/24.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class EntryDetailViewController: UIViewController, RKTabViewDelegate,UIWebViewDelegate{
    // content
    var webView: UIWebView?
    // right bar
    var rightBar: CDSideBarController?
    
    // entry idnex
    var entryIndex = 0;
    
    // show Entry
    var entryDatas: [FeedEntry]! = []
    
    //feedModelDelegate
    var feedDataManager = (UIApplication.sharedApplication().delegate as AppDelegate).feedDataManager
    
    //bottom bar
    var bottomBar: UIView?
    // toolbar
    var toolTabView:RKTabView?
    // saveItme
    var saveItem: RKTabItem?
    var webController: UIViewController?
    let TOOL_BAR_HGITH:CGFloat = 60.0
    // form the view
    override func loadView() {
        super.loadView()
        
        // web view
        self.webView = createWebView()
        self.webController =  UIViewController()
        self.webController?.view = self.webView
        self.view.addSubview(self.webView!)
        self.addChildViewController(self.webController!)
        
        // set right swipe gesture
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swipeLeft:");
        swipeLeft.numberOfTouchesRequired = 1
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }

    
    // load the add
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // webview
        loadWebview()
        self.webView?.backgroundColor = Theme.cellGroundColor
        
        // toolbar
        if(self.toolTabView != nil){
            self.toolTabView?.removeFromSuperview()
        }
        self.toolTabView = self.createToolTabView(entryDatas[entryIndex])
        self.view.addSubview(self.toolTabView!)
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
          JDStatusBarNotification.showWithStatus(error.description, dismissAfter: 1)
    }
    
    func createWebView() -> UIWebView{
        var  webView = UIWebView(frame: CGRect(origin: self.view.bounds.origin, size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - TOOL_BAR_HGITH)))
        webView.scalesPageToFit = true
        webView.scrollView.directionalLockEnabled = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.opaque = false
        return webView
    }
    
    func createToolTabView(entry: FeedEntry) -> RKTabView{
        var saveItem =     RKTabItem.createUnexcludableItemWithImageEnabled(UIImage(named: "star_fav"), imageDisabled: UIImage(named: "star_fav_empty"))
        if(entry.saved){
            saveItem.tabState = TabStateEnabled
        }else{
            saveItem.tabState = TabStateDisabled
        }
        
      //  UIImage(name
        
        var  toolTabView = RKTabView(frame: CGRect(x: 0, y: self.view.frame.height - TOOL_BAR_HGITH, width: self.view.frame.width, height: TOOL_BAR_HGITH), andTabItems: [RKTabItem.createButtonItemWithImage(UIImage(named: "arrow_left"), target: self, selector: "turnLeft"),RKTabItem.createButtonItemWithImage(UIImage(named: "arrow_top"), target: self, selector: "turnPrior"),RKTabItem.createButtonItemWithImage(UIImage(named: "arrow_bottom"),target: self, selector: "turnNext"),RKTabItem.createButtonItemWithImage(UIImage(named: "expand"),target: self, selector: "share"),saveItem])
        toolTabView?.alpha = 0.9
        toolTabView?.delegate = self
        return toolTabView
    }

    
    func turnLeft(){
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.toolbarHidden = true
    }
    
    func turnPrior(){
        if(entryIndex > 0){
            entryIndex = entryIndex - 1
        }else{
            JDStatusBarNotification.showWithStatus("没有上一页", dismissAfter: 1)
            return
        }
        self.loadWebview()
    }
    
    func turnNext(){
        if(entryIndex < entryDatas.count - 1){
            entryIndex = entryIndex + 1
        }else{
            JDStatusBarNotification.showWithStatus("没有下一页", dismissAfter: 1)
            return
        }
        
        // realoda the web
        self.loadWebview()
        
        // toolbar
        if(self.toolTabView != nil){
            self.toolTabView?.removeFromSuperview()
        }
        self.toolTabView = self.createToolTabView(entryDatas[entryIndex])
        self.view.addSubview(self.toolTabView!)
    }
    
    func share(){
        var imgData = entryDatas[entryIndex].imgData
        var publishContent = ShareSDK.content(entryDatas[entryIndex].title! + entryDatas[entryIndex].htmlUrl!, defaultContent: entryDatas[entryIndex].htmlUrl, image: ShareSDK.imageWithData(imgData, fileName: "text", mimeType: "img"), title: "imgTitle", url: entryDatas[entryIndex].htmlUrl, description: entryDatas[entryIndex].title, mediaType: SSPublishContentMediaTypeNews)
        var container = ShareSDK.container()
        ShareSDK.showShareActionSheet(container, shareList: nil, content: publishContent, statusBarTips: true, authOptions: nil, shareOptions: nil, result: nil)
    }
    
    // handle gesture
    func swipeRight(swipeRecognizer: UISwipeGestureRecognizer){
        self.navigationController?.popViewControllerAnimated(true)
        self.navigationController?.toolbarHidden = true
    }
    func swipeLeft(swipeRecognizer: UISwipeGestureRecognizer){
        var webController = WebViewController()
        webController.entryData = self.entryDatas[entryIndex]
        self.navigationController?.pushViewController(webController, animated: true)
    }
    
    func loadWebview(){
         dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)) {
        // get js file content and css file content
        var jsFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("js.html")
        var cssFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("css.html")
        if(Theme.currentTheme == ThemeType.nightTheme){
            cssFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("css_dark.html")
        }
      
        var jsText = NSString(contentsOfFile: jsFilePath!, encoding: NSUTF8StringEncoding, error: nil)!
        var cssText = NSString(contentsOfFile: cssFilePath!, encoding: NSUTF8StringEncoding, error: nil)
        
        // get entry
        var entryId = self.entryDatas[self.entryIndex].id
        var entity =  self.feedDataManager?.dataManager.getEntityById("FeedEntry", id: entryId!)
        if(entity != nil){
            var entry = entity as FeedEntry
            var title = entry.title
            var showContent:NSString? = entry.content
            if(showContent == nil){
                showContent = entry.summary
            }
            
            // create the html
            var htmlStr = NSString( format: "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\">%@</head><body><a class=\"title\" href=\"%@\">%@</a><div class=\"diver\"></div><div class=\"content\">%@</div>%@</body></html>",cssText!,"view url",title!,showContent!,jsText);
            
            var  path = NSHomeDirectory();
            NSLog("baseLog is %@", path)
            var baseURL = NSURL.fileURLWithPath(path)
            
            // load
            self.webView?.loadHTMLString(htmlStr, baseURL: baseURL)
        }
        
        
        // mark  read
        self.feedDataManager?.markEntryRead(entryId!)
     
        }
    }
    
    
    func tabView(tabView: RKTabView!, tabBecameEnabledAtIndex index: Int32, tab tabItem: RKTabItem!) {
         var entryId = self.entryDatas[entryIndex].id
         feedDataManager?.markEntrySaved(entryId!, saved: true)
            self.entryDatas[entryIndex].saved = true
    }
    
    func tabView(tabView: RKTabView!, tabBecameDisabledAtIndex index: Int32, tab tabItem: RKTabItem!) {
        var entryId = self.entryDatas[entryIndex].id
        feedDataManager?.markEntrySaved(entryId!, saved: false)
        self.entryDatas[entryIndex].saved = false
    }
}
