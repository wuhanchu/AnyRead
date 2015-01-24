//
//  FeedEntry.swift
//  AnyRead
//
//  Created by wuhanchu on 14/11/27.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData


@objc(FeedEntry)
class FeedEntry: NSManagedObject {

    @NSManaged var author: NSString?
    @NSManaged var content: NSString?
    @NSManaged var engagement: NSNumber?
    @NSManaged var id: NSString?
    @NSManaged var imageUrlString: NSString?
    @NSManaged var originId: NSString?
    @NSManaged var published: NSDate?
    @NSManaged var title: NSString?
    @NSManaged var unread: Bool
    @NSManaged var summary: NSString?
    @NSManaged var subscriptionId:NSString?
    @NSManaged var synced: Bool
    @NSManaged var saved: Bool
    @NSManaged var htmlUrl: NSString?
    @NSManaged var cached: Bool
}
