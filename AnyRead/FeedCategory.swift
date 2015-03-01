//
//  FeedCategory.swift
//  
//
//  Created by wuhanchu on 15/2/7.
//
//

import Foundation
import CoreData

@objc(FeedCategory)
class FeedCategory: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var label: String
    
//    override func isEqual(object: AnyObject?) -> Bool {
//        if(object == nil){
//            return false
//        }
//        var tempObject = object!
//        if(tempObject.isKindOfClass(FeedCategory)){
//            return false
//        }
//        
//        if(tempObject.id == self.id){
//            return true
//        }
//        return false
//    }
}
