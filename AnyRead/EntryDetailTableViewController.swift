//
//  StaffDetailTableViewController.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/10/24.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class EntryDetailTableViewController: UIViewController{
    // content
    var webView: UIWebView?
    
    // form the view
    override func loadView() {
        super.loadView()
        
        webView = UIWebView(frame: self.view.bounds)
        webView?.backgroundColor = UIColor.blackColor()
        webView?.scrollView.directionalLockEnabled = true
        webView?.scrollView.showsHorizontalScrollIndicator = false
        webView?.opaque = false
        self.view.addSubview(webView!)
    }
    
    // load the add
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // get js file content and css file content
        var jsFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("js.html")
        var cssFilePath = NSBundle.mainBundle().resourcePath?.stringByAppendingPathComponent("css.html")
        var jsText = NSString(contentsOfFile: jsFilePath!, encoding: NSUTF8StringEncoding, error: nil)!
        var cssText = NSString(contentsOfFile: cssFilePath!, encoding: NSUTF8StringEncoding, error: nil)
        
        
        // create the html
        var htmlStr = NSString( format: "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\">:%@</head><body><a class=\"title\" href=\":%@\">:%@</a><div class=\"diver\"></div><p style=\"text-align:left;font-size:9pt;margin-left: 14px;margin-top: 10px;margin-bottom: 10px;color:#CCCCCC\">:%@ 发表于 :%@</p><div class=\"content\">:%@</div>:%@</body></html>",cssText!,"","","","","",jsText);
        
        webView?.loadHTMLString(htmlStr, baseURL: nil)
    }
}
