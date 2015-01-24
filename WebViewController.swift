//
//  WebViewController.swift
//  AnyRead
//
//  Created by wuhanchu on 15/1/15.
//  Copyright (c) 2015年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

class WebViewController:UIViewController{
    var webView:UIWebView?
    /**
    load the view
    */
    override func loadView() {
        // view
        super.loadView()
        webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView!)
        
        /// show
        webView?.backgroundColor = UIColor.whiteColor()
        webView?.scrollView.directionalLockEnabled = true
        webView?.scrollView.showsHorizontalScrollIndicator = false
        webView?.opaque = false
 
        // add the swift gesture
        var swiftRigthRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRight:")
        swiftRigthRecognizer.numberOfTouchesRequired = 1
        swiftRigthRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        webView?.addGestureRecognizer(swiftRigthRecognizer)
    }
    /**
    view wiell show
    
    :param: animated <#animated description#>
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var request = NSURLRequest(URL: NSURL(string: "http://www.baidu.com")!)
        webView?.loadRequest(request)
    }
    
    /**
     swipe the righe 
     return back
    
    :param: recognizer the recognizer
    */
    func swipeRight(recognizer: UISwipeGestureRecognizer){
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    
    
}