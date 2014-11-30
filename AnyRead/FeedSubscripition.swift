//
//  FeedSubscripition.swift
//  AnyRead
//
//  Created by wuhanchu on 14/11/26.
//  Copyright (c) 2014年 wuhanchu. All rights reserved.
//

import Foundation
import CoreData

@objc(FeedSubscripition)
class FeedSubscripition: NSManagedObject {

    @NSManaged var categories: String
    @NSManaged var id: String
    @NSManaged var lastUpdated: NSDate
    @NSManaged var server: String
    @NSManaged var title: String
    @NSManaged var unreadNum: NSNumber
    @NSManaged var website: String

}
