//
//  IndexTableViewController.swift
//  AnyRead
//
//  Created by wuhanchu on 14/12/9.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import UIKit

/// login webview controller
class LoginViewController:UIViewController{
    /// the vidw
    var loginVIew: UIView?
    
    /// login button
    var feedlyLoginButton: UIButton?
    
    /// load view
    override func loadView() {
        /// super
        super.loadView()
        //self.view.frame = UIScreen.mainScreen().bounds
        self.view.backgroundColor = UIColor.redColor()
       // self.view.backgroundColor = UIColor.clearColor()
        
       var feedlyLoginButton = UIButton()
        feedlyLoginButton.backgroundColor = UIColor.blueColor()
        feedlyLoginButton.setTitle("登录", forState: UIControlState.Normal)
        feedlyLoginButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        feedlyLoginButton.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        createButton(feedlyLoginButton)
        self.view.addSubview(feedlyLoginButton)
 
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[feedlyLoginButton]-20-|", options: nil, metrics: nil, views: ["feedlyLoginButton" : feedlyLoginButton]))
         self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[feedlyLoginButton]-30-|", options: nil, metrics: nil, views: ["feedlyLoginButton" : feedlyLoginButton]))
    }
    
    
    /// creaet the button
    func createButton(button: UIButton!){
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.whiteColor().CGColor!
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
    }
    
    
    /// event handler
    
    /// feedly login
    @IBAction func loginTouchDown(sender: AnyObject) {
        // create feedlyClient
        var feedlyClient = AFLClient.sharedClient()
        feedlyClient.initWithApplicationId(AppKeySercet.FEEDLY_KEY , andSecret: AppKeySercet.FEEDLY_SERECT)
        
        // authen
        feedlyClient.authenticatePresentingViewControllerFrom(self, withResultBlock: authentication)
    }
    
    /// authen result handle
    func authentication(result : Bool, error :NSError!){
        if(!result){
            NSLog("authenticate error :%@", error.localizedDescription)
        }
    }
}