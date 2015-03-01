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
    @IBOutlet weak var loginButton: UIButton!
    var mainViewController: UIViewController?
   

    override func viewDidAppear(animated: Bool) {
        if(AFLClient.sharedClient().isAuthenticated()){
            self.presentViewController(mainViewController!, animated: true, completion: nil)
        }
        
        createButton(loginButton)
        loginButton.hidden = false
    }
    
    @IBAction func loginTouch(sender: AnyObject) {
        // create feedlyClient
        var feedlyClient = AFLClient.sharedClient()
        feedlyClient.initWithApplicationId(AppKeySercet.FEEDLY_KEY , andSecret: AppKeySercet.FEEDLY_SERECT)
        
        // authen
        feedlyClient.authenticatePresentingViewControllerFrom(self, withResultBlock: authentication)
    }
  
    
    /// creaet the button
    func createButton(button: UIButton!){
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.whiteColor().CGColor!
    }
    
    /// authen result handle
    func authentication(result : Bool, error :NSError!){
        if(!result){
            NSLog("authenticate error :%@", error.localizedDescription)
        }else{
            self.presentViewController(mainViewController!, animated: true, completion: nil)
        }
    }
}