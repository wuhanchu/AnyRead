//
//  FeedSubscription.swift
//  AnyRead
//
//  Created by wuhanchu on 14/11/26.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedSubscription)
class FeedSubscription: NSManagedObject {

    @NSManaged var categories: NSString
    @NSManaged var id: NSString
    @NSManaged var lastUpdated: NSDate?
    @NSManaged var server: NSString?
    @NSManaged var title: NSString
    @NSManaged var unreadNum: NSNumber?
    @NSManaged var website: NSString?


}
