//
//  FeedDataManager.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/11/16.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData


/**
*  sync the net data and local data
*/
class FeedDataManager: NSObject{
    // current sync subscption
    var subinfo: FeedSubscription?
    // feedly client
    var feedlyClient:AFLClient?
    // operation queue
    var queue = NSOperationQueue()
    //need fresh view
    var refreshViewControllers = NSMutableArray()
    // dataManager
    var dataManager = DataManager()
    // 定时器
    var timer: NSTimer?
    // 同步状态
    var syncStatus = false;
    
    
    func loadFeedlyClient(){
        // create feedlyClient
        feedlyClient = AFLClient.sharedClient()
        feedlyClient?.initWithApplicationId(AppKeySercet.FEEDLY_KEY, andSecret:AppKeySercet.FEEDLY_SERECT )
        
        // sync
        feedlyClient?.profile({ (profile: AFProfile!)  in }, failure: handleError)
    }
    
    
    
    // sync all data
    func syncFeedData(){
        if(syncStatus){
            return
        }
        
        // shwo sync start
        syncStatus  = true
        JDStatusBarNotification.showWithStatus("同步数据")
        
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
            // sync the profile
            if(self.feedlyClient?.profile == nil){
                self.feedlyClient?.profile({(profile : AFProfile!) in
                    NSLog("sync profile")
                    }, failure: self.handleError)
            }
            
            // sync category
            self.feedlyClient?.categories({(categorys: [AnyObject]?) in
                if(categorys == nil){
                    return
                }
                self.dataManager.clearTable("FeedCategory")
                for category in categorys! {
                    var tempCategory =  category as AFCategory
                    var obj =  self.dataManager.getInsertEntity("FeedCategory") as FeedCategory
                    obj.label =  tempCategory.label
                    obj.id = tempCategory._id
                }
                
                self.dataManager.commit()
                }, failure: self.handleError)
            
            // sync subscritpion
            self.feedlyClient?.subscriptions( self.syncSubscription, failure:  self.handleError)
            
            // sync entry status
            self.syncEntryStatus()
        }
        
        var entryDatas =  self.dataManager.getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: nil,saved: nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber = entryDatas.count
    }
    
    func startSyncTask(){
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "syncFeedData", userInfo: nil, repeats: true)
    }
    
    func stopSyncTask(){
        timer?.fire()
    }
    
    
    // mark the entry to read
    func markEntryRead(id : NSString){
        var entryData:FeedEntry? = dataManager.getEntityById("FeedEntry", id: id) as? FeedEntry
        //entryData.unread
        if(entryData != nil && entryData?.unread == true){
            entryData?.unread = false
            entryData?.synced = false
            
            // save
            dataManager.commit();
        }
        
    }
    
    // change the entry saved
    func markEntrySaved(id : NSString , saved: Bool){
        var entryData:FeedEntry? = dataManager.getEntityById("FeedEntry", id: id) as? FeedEntry
        //entryData.unread
        if(entryData != nil && entryData?.saved != saved){
            entryData?.saved = saved
            entryData?.synced = false
            
            // save
            dataManager.commit();
        }
    }
    
    /**
    <#Description#>
    */
    func markAllEntryRead(){
        var entryDatas:[FeedEntry] = dataManager.getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: nil,saved: nil)
        //entryData.unread
        for entryData in entryDatas{
            entryData.unread = false
            entryData.synced = false
            
            // save
            dataManager.commit();
        }
    }
    
    
    // sync subscritpion
    func syncSubscription(subscriptions: [AnyObject]!){
        // query existed
        dataManager.clearTable("FeedSubscription")
        
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
            for subscription in subscriptions{
                if(subscription.isKindOfClass(AFSubscription)){
                    var  tempsubscription = subscription as AFSubscription
                    NSLog("sync subs :%@", subscription._id)
                    
                    // get the entity
                    var subscriptionData = self.dataManager.getInsertEntity("FeedSubscription") as FeedSubscription
                    
                    // convert
                    //subscriptionData.id = subscription.id
                    subscriptionData.id          = subscription._id
                    subscriptionData.title       = subscription.title
                    subscriptionData.website     = subscription.website
                    subscriptionData.lastUpdated = subscription.updated
                    subscriptionData.visualUrl   = subscription.visualUrl
                    var categories = NSMutableArray()
                    for tempCategory in tempsubscription.categories {
                        var category = self.dataManager.getEntityById("FeedCategory", id: tempCategory._id)
                        categories.addObject(category!)
                    }
                    
                    subscriptionData.categories = NSSet(array: categories)
                    subscriptionData.cached = false
                }
            }
            
            // saves
            self.dataManager.commit();
            
            
            // sync Stream
            self.feedlyClient?.unreadStream(self.syncUnReadStream, failure: self.handleError)
        }
    }
    
    // sync stream
    func syncUnReadStream(stream : AFStream!){
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)) {
            for entry in stream.items {
                NSLog("sync item :%@", entry.title)
                if(entry.isKindOfClass(AFItem)){
                    // var entry = entry as AFItem
                    //query the data is existed
                    var searchEntry =  self.dataManager.getEntityById("FeedEntry", id: entry._id)
                    if(searchEntry == nil){
                        
                        var tempEntry = entry as AFItem
                        // insert
                        var entryData: FeedEntry = self.dataManager.getInsertEntity("FeedEntry")  as FeedEntry
                        entryData.id             = tempEntry._id
                        entryData.title          = tempEntry.title
                        entryData.unread         = tempEntry.unread
                        entryData.summary        = tempEntry.summary?.content
                        entryData.content        = tempEntry.getFeedContent()
                        entryData.author         = tempEntry.author
                        entryData.subscriptionId = tempEntry.origin?.streamId
                        var alternate            = tempEntry.alternate![0] as AFAlternate
                        entryData.htmlUrl        = alternate.href
                        entryData.published      = tempEntry.published
                        entryData.saved          = tempEntry.saved
                        entryData.synced         = true
                        entryData.cached         = false
                        
                        // save
                        self.dataManager.commit();
                    }
                }
            }
            
            // cache opertiaon
            var operation = CacheOperation()
            operation.feedManager = self
            self.queue.addOperation(operation)
        }
        NSLog("cache opertiaon")
    }
    
    // sync the entry status to read or unread
    func syncEntryStatus(){
        //sync unread
        var syncEntrys:[FeedEntry] =  dataManager.getEntrys(subscriptionId: nil, unread: true, synced: false, cached: false,saved: nil)
        var ids:[NSString] = []
        for entry in syncEntrys {
            ids.append(entry.id!)
        }
        if(ids.count > 0){
            feedlyClient?.markAs(true, forIds: ids, withType: AFContentTypeEntry, lastEntryId: ids.last, success: handleSuccess, failure: handleError)
        }
        
        // entryData
        for entryData in syncEntrys{
            entryData.synced = true;
            dataManager.commit()
        }
        
        // sync read
        syncEntrys =  dataManager.getEntrys(subscriptionId: nil, unread: false, synced: false, cached: false,saved: nil)
        ids.removeAll(keepCapacity: false)
        for entry in syncEntrys {
            ids.append(entry.id!)
        }
        if(ids.count > 0){
            feedlyClient?.markAs(false, forIds: ids, withType: AFContentTypeEntry, lastEntryId: ids.last, success: handleSuccess, failure: handleError)
        }
        
        // entryData
        for entryData in syncEntrys{
            entryData.synced = true;
            dataManager.commit()
        }
    }
    
    
    
    // add the fresh view
    func addRefreshViewController(viewController: UIViewController){
        if(!refreshViewControllers.containsObject(viewController)){
            refreshViewControllers.addObject(viewController)
        }
    }
    
    /// success handle
    func handleSuccess(result:Bool){
        NSLog("handle success")
    }
    
    /// error handle
    func handleError(error: NSError!){
        self.dataManager.rollback()
        dispatch_async(dispatch_get_main_queue()) {
            var errorMsg = NSString(format: "同步失败：错误信息为[%@]", error.localizedDescription)
            JDStatusBarNotification.showWithStatus(errorMsg, dismissAfter: 1)
            self.syncStatus = false
            NSLog("sync error :%@", error.localizedDescription)
        }
    }
    
    
    // 清除数据
    func cleardata(){
        // begin
        JDStatusBarNotification.showWithStatus("清除缓存数据")
        
        dispatch_sync(dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.value), 0)){
            // 清除数据库数据
            var path =  NSHomeDirectory() + "/tmp"
            var fileManager = NSFileManager()
            var enumerator =  fileManager.enumeratorAtPath(path)
            var fileNames =   fileManager.subpathsAtPath(path) as? [NSString]
            var entrys = self.dataManager.getEntrys(subscriptionId: nil, unread: false, synced: nil, cached: nil, saved: false)
            for entry in entrys {
                self.dataManager.deleteObject(entry)
                for fileName in fileNames! {
                    if(fileName.hasPrefix(entry.id!.stringByReplacingOccurrencesOfString("/",withString: "_") )){
                        var filePath = path.stringByAppendingString("/").stringByAppendingString(fileName as NSString)
                        fileManager.removeItemAtPath( filePath, error: nil)
                    }
                }
            }
            
            self.dataManager.commit()
        }
        
        // end
        JDStatusBarNotification.dismiss()
    }
}


/**
*  cache opertiaon
*/
class CacheOperation:NSOperation{
    // FeedDataManager
    var feedManager : FeedDataManager?
    // img dir
    let documentPath = "tmp"
    
    func showStatus(content:NSString){
        JDStatusBarNotification.dismiss()
        JDStatusBarNotification.showWithStatus(content)
        
    }
    
    override func main() {
        if(NSUserDefaults.standardUserDefaults().boolForKey(ConfKeys.IF_CACHE_IMG)){
            
            JDStatusBarNotification.performSelectorOnMainThread("showWithStatus:", withObject: "图片下载", waitUntilDone: true);
            var entryDatas =  feedManager?.dataManager.getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: false,saved: nil)
            
            for entryData in entryDatas! {
                //download the img and modify url
                if(entryData.summary != nil){
                    entryData.summary         = downloadImg(entryData,html: entryData.summary)
                }
                if(entryData.content != nil){
                    entryData.content         = downloadImg(entryData,html: entryData.content)
                }
                NSLog("downLog")
                // update the status
                entryData.cached = true
                feedManager?.dataManager.commit()
            }
            dispatch_async(dispatch_get_main_queue()) {
                // refresh the view
                var refrshController = self.feedManager?.refreshViewControllers
                for viewController in refrshController!{
                    var controller = viewController as UIViewController
                    if(controller.view.hidden == false && controller.conformsToProtocol(FeedRefreshViewController)){
                        (controller as FeedRefreshViewController).refreshView()
                    }
                }
            }
        }
        
        
        //stop show the status
        dispatch_async(dispatch_get_main_queue()) {
            self.feedManager?.syncStatus = false
            JDStatusBarNotification.dismiss()
        }
    }
    
    // download the img and replace the img url
    func downloadImg(var entry: FeedEntry!, var html:NSString!) -> NSString{
        var entryId = entry.id
        var returnHtml:NSString = html
        if(html != nil){
            // get the url
            var currentStr:NSString?
            
            var beginRange = NSMakeRange(0,html.length)
            
            while(true){
                // get the img url
                if(beginRange.location > html.length){
                    break
                }
                var imgRange  = html?.rangeOfString("<img ", options: nil,range: beginRange)
                var imgLocation = imgRange?.location
                imgRange?.length = html.length - imgLocation!
                if(imgRange != nil && imgRange?.location > html.length){
                    break
                }
                var srcRange  = html?.rangeOfString("src=\"", options: nil,range: imgRange!)
                var beginLocation = srcRange?.location
                currentStr = html?.substringFromIndex(beginLocation! + 5)
                var endLocation = currentStr?.rangeOfString("\"").location
                currentStr = currentStr?.substringToIndex(endLocation!)
                
                beginRange.location = beginLocation! + 5
                beginRange.length = html.length - beginRange.location
                
                // judge the url is empty
                if(currentStr?.length < 1){
                    continue
                }
                
                
                // download the img
                currentStr =   currentStr?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                var imsgURL = NSURL(string: currentStr!)
                var data = NSData(contentsOfURL: imsgURL!)
                if(data?.length > 20000){
                    // save the file
                    var fileNameIndex = currentStr?.rangeOfString("/", options:NSStringCompareOptions.BackwardsSearch).location
                    var filename = currentStr?.substringFromIndex(fileNameIndex!+1)
                    
                    
                    var fileName = entry.id!.stringByReplacingOccurrencesOfString("/",withString: "_") + "_" + currentStr!.stringByReplacingOccurrencesOfString("/",withString: "_").stringByReplacingOccurrencesOfString("?", withString: "_")
                    var filepath = documentPath.stringByAppendingPathComponent(fileName)
                    
                    // filepath = NSString(format: "file://%@",filepath)
                    var fileWholePath = NSHomeDirectory().stringByAppendingPathComponent(filepath)
                    NSLog("img url : %@, currnetdir: %@", currentStr!, filepath)
                    var fileManager = NSFileManager()
                    if(!fileManager.fileExistsAtPath(fileWholePath)){
                        data?.writeToFile(fileWholePath, options: nil, error: nil)
                    }
                    
                    // update the imag path
                    if(entry.imgData == nil){
                        entry.imgData = data
                    }
                    
                    // replace the img url
                    returnHtml = returnHtml.stringByReplacingOccurrencesOfString(currentStr!, withString: filepath)
                }else{
                    returnHtml = returnHtml.stringByReplacingOccurrencesOfString(currentStr!, withString: "")
                }
            }
        }
        
        //return
        return returnHtml
    }
    
    
    
}


/**
*  when the feed datea
*/
@objc protocol FeedRefreshViewController{
    func refreshView()
}
