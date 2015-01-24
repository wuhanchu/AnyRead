//
//  FeedDataDelegate.swift
//  ExpiredWarn
//
//  Created by wuhanchu on 14/11/16.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData
import Fabric
import Crashlytics


/**
*  sync the net data and local data
*/
class FeedDataDelegate: NSObject{
    // current sync subscption
    var subinfo: FeedSubscription?
    
    // feedly client
    var feedlyClient:AFLClient?
    
    // operation queue
    var queue = NSOperationQueue()
    
    // coreDate
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    var managedObjectModel: NSManagedObjectModel?
    var managedObjectContext: NSManagedObjectContext?
    
    // updateVIew
    weak var  curViewController: SubscriptionTableViewController?
    
    
    
    //MARK init
    override init() {
        // coordinattor
        managedObjectModel         = NSManagedObjectModel.mergedModelFromBundles(nil)
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        // errror
        var error = NSErrorPointer()
        
        // store
        var docs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask , true).last as String
        
        NSLog("paht :%@",docs)
        var url =  NSURL.fileURLWithPath(docs.stringByAppendingPathComponent("rss.db"))
        var store =  persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: error)
        
        // context
        managedObjectContext =  NSManagedObjectContext()
        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
        
        // super
        super.init();
        
        // create feedlyClient
        feedlyClient = AFLClient.sharedClient()
        feedlyClient?.initWithApplicationId("sandbox", andSecret: "9ZUHFZ9N2ZQ0XM5ERU1Z")
        
        // sync
        feedlyClient?.profile({ (profile: AFProfile!)  in }, failure: handleError)
    }
    
    // get insert entity
    func getInsertEntity(entityStr: NSString) -> NSManagedObject{
        return NSEntityDescription.insertNewObjectForEntityForName(entityStr, inManagedObjectContext: managedObjectContext!) as NSManagedObject
    }
    
    
    // save the enttiy
    func saveUpdate(){
        // errror
        var error = NSErrorPointer()
        
        // save
        managedObjectContext?.save(error)
    }
    
    // find the entity by id
    func getEntityById(entityStr: NSString, id:NSString ) -> NSManagedObject?{
        // query the data
        var query = NSFetchRequest()
        query.entity = NSEntityDescription.entityForName(entityStr, inManagedObjectContext: managedObjectContext!);
        query.predicate = NSPredicate(format: "id=%@", id)
        var result = managedObjectContext?.executeFetchRequest(query, error: nil) as [NSManagedObject]
        if(result.count > 0){
            return result[0]
        }else{
            return nil
        }
    }
    
    // get all entry
    func  getEntry() -> [FeedEntry] {
        var entryDatas = getEntitys("FeedEntry") as [FeedEntry]
        
        // return
        return entryDatas
    }
    
    // find the all data
    func getEntitys(entityStr: NSString) -> [NSManagedObject]{
        // query the data
        var query = NSFetchRequest()
        query.entity = NSEntityDescription.entityForName(entityStr, inManagedObjectContext: managedObjectContext!);
        return managedObjectContext?.executeFetchRequest(query, error: nil) as [NSManagedObject]
    }
    
    // get entry by condition
    func getEntrys(#subscriptionId: NSString?, unread:Bool?, synced:Bool?, cached:Bool?) ->[FeedEntry]{
        // query the data
        var query = NSFetchRequest()
        query.entity = NSEntityDescription.entityForName("FeedEntry", inManagedObjectContext: managedObjectContext!);
        
        // format the condition
        var conditionStr = ""
        var argumentArray:[AnyObject] = []
        if(subscriptionId != nil){
            if(!conditionStr.isEmpty){
                conditionStr  += " AND "
            }
            conditionStr += "subscriptionId=%@"
            argumentArray.append(subscriptionId!)
        }
        if(unread != nil){
            if(!conditionStr.isEmpty){
                conditionStr  += " AND "
            }
            conditionStr += "unread=%s"
            argumentArray.append(unread!)
        }
        if(synced != nil){
            if(!conditionStr.isEmpty){
                conditionStr  += " AND "
            }
            conditionStr += "synced=%s"
            argumentArray.append(synced!)
        }
        if(cached != nil){
            if(!conditionStr.isEmpty){
                conditionStr  += " AND "
            }
            conditionStr += "cached=%s"
            argumentArray.append(cached!)
        }
        
        // create the sort
        query.sortDescriptors =  [NSSortDescriptor(key: "published", ascending: false)]
        
        
        if(!conditionStr.isEmpty){
            query.predicate = NSPredicate(format: conditionStr, argumentArray: argumentArray)
        }
        
        
        //return
        return managedObjectContext?.executeFetchRequest(query, error: nil) as [FeedEntry]
    }
    
    
    // sync all data
    func syncFeedData(){
        // sync the profile
        if(feedlyClient?.profile == nil){
            feedlyClient?.profile({(profile : AFProfile!) in
                NSLog("sync profile")
                }, failure: handleError)
        }
        
        // sync subscritpion
        feedlyClient?.subscriptions(syncSubscription, failure: handleError)
        
        // sync entry status
        syncEntryStatus()
        
    }
    
    
    // mark the entry to read
    func markEntryRead(id : NSString){
        var entryData:FeedEntry? = getEntityById("FeedEntry", id: id) as? FeedEntry
        //entryData.unread
        if(entryData != nil){
            entryData?.unread = false
            entryData?.synced = false
            
            // save
            saveUpdate();
        }
    }
    
    /**
    <#Description#>
    */
    func markAllEntryRead(){
        var entryDatas:[FeedEntry] = getEntrys(subscriptionId: nil, unread: true, synced: nil, cached: nil)
        //entryData.unread
        for entryData in entryDatas{
            entryData.unread = false
            entryData.synced = false
            
            // save
            saveUpdate();
        }
    }
    
    
    // sync subscritpion
    func syncSubscription(subscriptions: [AnyObject]!){
        for subscription in subscriptions{
            if(subscription.isKindOfClass(AFSubscription)){
                subscription as AFSubscription
                NSLog("sync subs :%@", subscription._id)
                
                // query existed
                var searchSubscription =  getEntityById("FeedSubscription", id: subscription._id)
                if(searchSubscription == nil){
                    
                    // get the entity
                    var subscriptionData = getInsertEntity("FeedSubscription") as FeedSubscription
                    
                    // convert
                    //subscriptionData.id = subscription.id
                    subscriptionData.id          = subscription._id
                    subscriptionData.title       = subscription.title
                    subscriptionData.website     = subscription.website
                    subscriptionData.lastUpdated = subscription.updated
                    
                    // save
                    saveUpdate();
                }
            }
        }
        
        
        // sync Stream
        feedlyClient?.unreadStream(syncUnReadStream, failure: handleError)
    }
    
    // sync stream
    func syncUnReadStream(stream : AFStream!){
        for entry in stream.items {
            NSLog("sync item :%@", entry.title)
            if(entry.isKindOfClass(AFItem)){
                entry as AFItem
                //query the data is existed
                var searchEntry =  getEntityById("FeedEntry", id: entry._id)
                if(searchEntry == nil){
                    
                    // insert
                    var entryData: FeedEntry = getInsertEntity("FeedEntry")  as FeedEntry
                    entryData.id             = entry._id
                    entryData.title          = entry.title
                    entryData.unread         = entry.unread
                    entryData.summary        = entry.summary?.content
                    entryData.content        = entry.getFeedContent()
                    entryData.author         = entry.author
                    entryData.subscriptionId = entry.origin?.streamId
                    entryData.htmlUrl        = entry.origin?.htmlUrl
                    entryData.published      = entry.published
                    entryData.saved          = entry.saved
                    entryData.synced         = true
                    entryData.cached         = false
                    
                    // save
                    saveUpdate();
                }
            }
        }
        
        // cache opertiaon
        var operation = CacheOperation()
        operation.feedDataDelegate = self
        queue.addOperation(operation)
        NSLog("cache opertiaon")
        
        // table reload data
        curViewController?.loadData()
        curViewController?.tableView?.reloadData()
        NSLog("rtable reload data")
    }
    
    // sync the entry status to read or unread
    func syncEntryStatus(){
        //sync unread
        var syncEntrys:[FeedEntry] =  getEntrys(subscriptionId: nil, unread: true, synced: false, cached: false)
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
            saveUpdate()
        }
        
        // sync read
        syncEntrys =  getEntrys(subscriptionId: nil, unread: false, synced: false, cached: false)
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
            saveUpdate()
        }
    }
    
    /// get all subscription
    func getSubscription() -> [FeedSubscription] {
        var subscriptionDatas = getEntitys("FeedSubscription") as [FeedSubscription]
        
        // return
        return subscriptionDatas
    }
    
    
    /// success handle
    func handleSuccess(result:Bool){
        NSLog("handle success")
    }
    
    /// error handle
    func handleError(error: NSError!){
        NSLog("sync error :%@", error.localizedDescription)
    }
}

/**
*  cache opertiaon
*/
class CacheOperation:NSOperation{
    // feedDataDelegate
    var feedDataDelegate: FeedDataDelegate?
    
    override func main() {
        // get the all unCached data
        var entryDatas =  feedDataDelegate?.getEntrys(subscriptionId: nil, unread: nil, synced: nil, cached: false)
        
        for entryData in entryDatas! {
            //download the img and modify url
            if(entryData.summary != nil){
                entryData.summary         = downloadImg(entryData.id!,html: entryData.summary)
            }
            if(entryData.content != nil){
                entryData.content         = downloadImg(entryData.id!,html: entryData.content)
            }
            
            // update the status
            entryData.cached = true
            feedDataDelegate?.saveUpdate()
        }
    }
    
    // download the img and replace the img url
    func downloadImg(var entryId: NSString!, var html:NSString!) -> NSString{
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
                if(imgRange?.location > html.length){
                    break
                }
                var srcRange  = html?.rangeOfString("src=\"", options: nil,range: imgRange!)
                var beginLocation = srcRange?.location
                currentStr = html?.substringFromIndex(beginLocation! + 5)
                var endLocation = currentStr?.rangeOfString("\"").location
                currentStr = currentStr?.substringToIndex(endLocation!)
                
                beginRange.location = beginLocation! + 5
                beginRange.length = html.length - beginRange.location
                
                // download the img
                currentStr =   currentStr?.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
                var imsgURL = NSURL(string: currentStr!)
                var data = NSData(contentsOfURL: imsgURL!)
                
                // save the file
                var fileNameIndex = currentStr?.rangeOfString("/", options:NSStringCompareOptions.BackwardsSearch).location
                var filename = currentStr?.substringFromIndex(fileNameIndex!+1)
                
                var documentPath = "tmp"
                var filepath = documentPath.stringByAppendingPathComponent( currentStr!.stringByReplacingOccurrencesOfString("/",withString: "_").stringByReplacingOccurrencesOfString("?", withString: "_"))
                // filepath = NSString(format: "file://%@",filepath)
                NSLog("img url : %@, currnetdir: %@", currentStr!, filepath)
                data?.writeToFile(NSHomeDirectory().stringByAppendingPathComponent(filepath), options: nil, error: nil)
                
                // replace the img url
                returnHtml = returnHtml.stringByReplacingOccurrencesOfString(currentStr!, withString: filepath)
            }
        }
        
        //return
        return returnHtml
    }
}
