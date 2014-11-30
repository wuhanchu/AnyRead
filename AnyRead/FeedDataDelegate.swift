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


//
// sync the net data and local data
//
//
class FeedDataDelegate: NSObject{
    
    // coreDate
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    var managedObjectModel: NSManagedObjectModel?
    var managedObjectContext: NSManagedObjectContext?
    var stream : AFStream?
    
    // current sync subscption
    var subinfo: FeedSubscripition?
    
    
    // feedly client
    var feedlyClient:AFLClient?
    
    // init
    override init(){
        // super
        super.init();

        
        // errror
        var error = NSErrorPointer()
        
        // coordinattor
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        
        // store
        var docs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask , true).last as String
        
        NSLog("paht :%@",docs)
        var url =  NSURL.fileURLWithPath(docs.stringByAppendingPathComponent("rss.db"))
        var store =  persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: error)
        
        // context
        managedObjectContext =  NSManagedObjectContext()
        managedObjectContext?.persistentStoreCoordinator = persistentStoreCoordinator
        
        // create feedlyClient
        feedlyClient = AFLClient.sharedClient()
        feedlyClient?.initWithApplicationId("sandbox", andSecret: "A0SXFX54S3K0OC9GNCXG")
        
        // sync
        feedlyClient?.profile(syncProfile, failure: hanelError)
    }
    
    // sync all data
    func syncFeedData(){
        // sync subscritpion
        feedlyClient?.subscriptions(syncSubscription, failure: hanelError)
        
        // sync Stream
        
        feedlyClient?.unreadStream(syncUnReadStream, failure: hanelError)
    }
    
    // sync profile
    func syncProfile(profile : AFProfile!){
        
    }
    
    
    // sync subscritpion
    func syncSubscription(subscriptions: [AnyObject]!){
        for subscription in subscriptions{
            if(subscription.isKindOfClass(AFSubscription)){
                subscription as AFSubscription
                NSLog("sync subs :%@", subscription._id)
                
                var subscriptionData = NSEntityDescription.insertNewObjectForEntityForName("FeedSubscripition", inManagedObjectContext: managedObjectContext!) as FeedSubscripition
                
                // convert
                //subscriptionData.id = subscription.id
                subscriptionData.title = subscription.title
                subscriptionData.website = subscription.website
                subscriptionData.lastUpdated = subscription.updated
                
                // save
                managedObjectContext?.save(nil)
            }
        }
    }
    
    // sync stream
    func syncUnReadStream(stream : AFStream!){
        self.stream = stream
        
        for entry in stream.items{
            NSLog("sync item :%@", entry.title)
            if(entry.isKindOfClass(AFItem)){
                entry as AFItem
                
                var entryData = NSEntityDescription.insertNewObjectForEntityForName("FeedEntry", inManagedObjectContext: managedObjectContext!) as FeedEntry
                entryData.title = entry.title
                var content = entry.getcontent()
                if(content != nil){
                    entryData.content = content
                }
                
                // save
                managedObjectContext?.save(nil)
            }
        }
        
        NSLog("sync stream over")
    }
    
    
    // get all subscription
    func getSubscription() -> [FeedSubscripition] {
        // query the data
        var query = NSFetchRequest()
        query.entity = NSEntityDescription.entityForName("FeedSubscripition", inManagedObjectContext: managedObjectContext!);
        var subscriptionDatas =  managedObjectContext?.executeFetchRequest(query, error: nil) as [FeedSubscripition]
        
        // return
        return subscriptionDatas
    }
    
    // get all entry
    func  getEntry() -> [FeedEntry] {
        
        // query the data
        var query = NSFetchRequest()
        query.entity = NSEntityDescription.entityForName("FeedEntry", inManagedObjectContext: managedObjectContext!);
        var entryDatas =  managedObjectContext?.executeFetchRequest(query, error: nil) as [FeedEntry]
        
        // return
        return entryDatas
    }
    // error handle
    func hanelError(error: NSError!){
        NSLog("sync error :%@", error.localizedDescription)
    }
    
    //
    //    //sync subscption
    //    func  syncSubScption(){
    //         qeury the net data
    //        feedlyClient?.getSubscriptions()
    //                // select
    //                var query = NSFetchRequest()
    //                query.entity = NSEntityDescription.entityForName("Subscption", inManagedObjectContext: managedObjectContext!);
    //                var array =  managedObjectContext?.executeFetchRequest(query, error: error)
    //                var i = array?.count
    //
    //    }
    //
    //    // syonc subscption
    //    func syncEntry(){
    //
    //    }
    //
    //
    //    // sync the subscription
    //    func feedlyClient(client: AFLClient!, didLoadSubscriptions subscriptions: [AnyObject]!) {
    //            subscriptions as [FeedSubscription]
    //            for subscription in subscriptions {
    //                subscription as FeedSubscription
    //
    //                // select the subinfo and delete
    //                var query = NSFetchRequest()
    //                query.entity = NSEntityDescription.entityForName("FeedSubscription", inManagedObjectContext: managedObjectContext!);
    //                //query.predicate =  NSPredicate(format: "id == '%@'", subscription.id)
    //                var subinfos = managedObjectContext?.executeFetchRequest(query, error: nil)
    //
    //                //insert
    //                var subinfo = NSEntityDescription.insertNewObjectForEntityForName("FeedSubscription", inManagedObjectContext: managedObjectContext!) as FeedSubscription
    //                subinfo.id = subscription.ID
    //                subinfo.title = subscription.title
    //
    //                // sync the unread content
    //                client?.getStream(subinfo.id)
    //
    //                // save
    //                managedObjectContext?.save(nil)
    //            }
    //
    //    }
    //
    //    // sync the stream
    //    func feedlyClient(client: AFLClient!, didLoadStream stream: AFLClientStream!) {
    //        for item in  stream.items{
    //            if(item.isKindOfClass(FeedEntity)){
    //                // get the models
    //                var entityInfo = NSEntityDescription.insertNewObjectForEntityForName("FeedEntity", inManagedObjectContext: managedObjectContext!) as FeedEntity
    //
    //                // convert
    //                entityInfo.id = item.ID
    //                entityInfo.title = item.title
    //                entityInfo.content = item.content
    //
    //                // save
    //                managedObjectContext?.save(nil)
    //            }
    //        }
    //    }
}
