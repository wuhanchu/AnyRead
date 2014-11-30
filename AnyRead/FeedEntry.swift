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

    @NSManaged var author: String
    @NSManaged var content: String
    @NSManaged var engagement: NSNumber
    @NSManaged var id: String
    @NSManaged var imageUrlString: String
    @NSManaged var originId: String
    @NSManaged var published: NSNumber
    @NSManaged var title: String
    @NSManaged var unread: NSNumber

}
