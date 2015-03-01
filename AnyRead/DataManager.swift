//
//  DataManager.swift
//  AnyRead
//
//  Created by wuhanchu on 15/2/7.
//  Copyright (c) 2015年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject{
    // coreDate
    var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    var managedObjectModel: NSManagedObjectModel?
    var managedObjectContext: NSManagedObjectContext?
    
    override init(){
        super.init()
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
    }
    
    // get insert entity
    func getInsertEntity(entityStr: NSString) -> NSManagedObject{
        return NSEntityDescription.insertNewObjectForEntityForName(entityStr, inManagedObjectContext: managedObjectContext!) as NSManagedObject
    }
    
    
    // commit change
    func commit(){
        // errror
        var error = NSErrorPointer()
        
        // save
        managedObjectContext?.save(error)
    }
  
    
    
    // roolback
    func rollback(){
         managedObjectContext?.rollback()
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
    
    func deleteObject(obejct: NSManagedObject){
        managedObjectContext?.deleteObject(obejct)
    }
    
    func clearTable(tableName: NSString){
        for object in   getEntitys(tableName){
            deleteObject(object)
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
    func getEntrys(#subscriptionId: NSString?, unread:Bool?, synced:Bool?, cached:Bool?, saved: Bool?) ->[FeedEntry]{
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
                conditionStr += " AND "
            }
            conditionStr += "cached=%s"
            argumentArray.append(cached!)
        }
        if(saved != nil){
            if(!conditionStr.isEmpty){
                conditionStr += " AND "
            }
            conditionStr += "saved=%s"
            argumentArray.append(saved!)
        }
        
        // create the sort
        query.sortDescriptors =  [NSSortDescriptor(key: "published", ascending: false)]
        
        
        if(!conditionStr.isEmpty){
            query.predicate = NSPredicate(format: conditionStr, argumentArray: argumentArray)
        }
        
        
        //return
        return managedObjectContext?.executeFetchRequest(query, error: nil) as [FeedEntry]
    }
    
    /// get all subscription
    func getSubscription() -> [FeedSubscription] {
        var subscriptionDatas = getEntitys("FeedSubscription") as [FeedSubscription]
        
        // return
        return subscriptionDatas
    }

}