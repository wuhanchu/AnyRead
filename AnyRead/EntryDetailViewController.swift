//
//  StaffDetailTableViewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/10/24.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class EntryDetailViewController: UIViewController, CDSideBarControllerDelegate{
    // content
    var webView: UIWebView?
    // right bar
    var rightBar: CDSideBarController?
    
    // show Entry
    var entryData: FeedEntry!
    
    // entry Id
    var entryId: NSString?
    
    //feedModelDelegate
    var feedDataDelegate:FeedDataDelegate? = (UIApplication.sharedApplication().delegate as AppDelegate).feedDataDelegate
    
    //bottom bar
    var bottomBar: UIView?
    
    
    // form the view
    override func loadView() {
        super.loadView()
        
        // web view
        webView = UIWebView(frame: self.view.bounds)
        // webView?.frame.size.height = self.view.bounds.size.height - barHigh!
        webView?.backgroundColor = UIColor.whiteColor()
        webView?.scrollView.directionalLockEnabled = true
        webView?.scrollView.showsHorizontalScrollIndicator = false
        webView?.opaque = false
        self.view.addSubview(webView!)
        
        // right operation bar
        var imgArray =  NSArray(objects: UIImage(named: "share")!, UIImage(named: "save")!, UIImage(named: "view")!)
        rightBar = CDSideBarController(images: imgArray)
        rightBar?.insertMenuButtonOnView(self.view)
        rightBar?.delegate = self
        
        // set right swipe gesture
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swipeRight:");
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    // handle gesture
    func swipeRight(swipeRecognizer: UISwipeGestureRecognizer){
        if(rightBar?.isOpen == true){
            self.rightBar?.dismissMenu()
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // load the add
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // get js file content and css file content
        var jsFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("js.html")
        var cssFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("css.html")
        var jsText = NSString(contentsOfFile: jsFilePath!, encoding: NSUTF8StringEncoding, error: nil)!
        var cssText = NSString(contentsOfFile: cssFilePath!, encoding: NSUTF8StringEncoding, error: nil)
        
        // get entry
        var entity =  feedDataDelegate?.getEntityById("FeedEntry", id: self.entryId!)
        if(entity != nil){
            var entry = entity as FeedEntry
            var title = entry.title
            var showContent:NSString? = entry.content
            if(showContent == nil){
                showContent = entry.summary
            }
            var author = entry.author
            if(author == nil){
                author = ""
            }
            
            
            // create the html
            var htmlStr = NSString( format: "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\">%@</head><body><a class=\"title\" href=\"%@\">%@</a><div class=\"diver\"></div><p style=\"text-align:left;font-size:9pt;margin-left: 14px;margin-top: 10px;margin-bottom: 10px;color:#CCCCCC\">%@ 发表于 %@</p><div class=\"content\">%@</div>%@</body></html>",cssText!,"view url",title!,author!,"2014/1/1",showContent!,jsText);
            
            var  path = NSHomeDirectory();
            NSLog("baseLog is %@", path)
            var baseURL = NSURL.fileURLWithPath(path)
            
            webView?.loadHTMLString(htmlStr, baseURL: baseURL)
        }
    }
    
    /// MARK right bar
    func menuButtonClicked(index: Int32) {
        
        switch(index){
        case 0:
            var imagPath =   NSBundle.mainBundle().pathForResource("ShareSDK", ofType: "jpg")
            var publishContent = ShareSDK.content("分享", defaultContent: "xx", image: ShareSDK.imageWithPath(imagPath), title: "分享", url: "http://baidu.com", description: "这是一条演示信息", mediaType: SSPublishContentMediaTypeNews)
            var container = ShareSDK.container()
            ShareSDK.showShareActionSheet(container, shareList: nil, content: publishContent, statusBarTips: true, authOptions: nil, shareOptions: nil, result: nil)
        case 1:
            NSLog("save")
            feedDataDelegate?.markEntryRead(entryId!)
        case 2:
            NSLog("open web")
            var webController = WebViewController()
            self.navigationController?.pushViewController(webController, animated: true)
            
        default:
            break
        }
    }
}
