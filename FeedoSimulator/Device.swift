//
//  Device.swift
//  ParseStarterProject
//
//  Created by Dario on 7/24/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse

let kMaxFood = 100

class Device: PFObject, PFSubclassing {
    @NSManaged  var code : String
    @NSManaged  var name : String
    @NSManaged  var foodStatus : NSNumber?
    @NSManaged  var deviceCapacity : NSNumber
    @NSManaged  var lastFeeding : NSDate?
    @NSManaged var sensorClose : NSNumber?
    
    var configLabels = ["Remaining Food", "Last Feeding", "Sensor Closed","Capacity"]
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "FeedoDevice"
    }
    
    func getPrintableValue(key: Int) -> String {
        switch key {
            case 0:
                return getFoodStatus()
            case 1:
                return getLastFeedingString()
            case 2:
                return getSensorCloseString()
            case 3:
                return self.deviceCapacity.stringValue.stringByAppendingString(" Kg")
            default:
                return ""
        }
    }
    
    
    func getFoodStatus() -> String {
        var trimedFoodStatus = (((foodStatus == nil) || (foodStatus?.integerValue < 0)) ? 0 : foodStatus!) as NSNumber
        trimedFoodStatus = trimedFoodStatus.integerValue > kMaxFood ? kMaxFood : trimedFoodStatus
        
        let remainingFood = ((trimedFoodStatus.integerValue * self.deviceCapacity.integerValue) / kMaxFood) as NSNumber
        
        return remainingFood.stringValue.stringByAppendingString(" Kg")
    }
    
    func getLastFeedingString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "d/M hh:mm"
        if let lastFeeding = self.lastFeeding {
            return dateFormatter.stringFromDate(lastFeeding)
        } else {
            return "Never"
        }
    }
    
    func getSensorCloseString () -> String {
        return ((self.sensorClose != nil) && (self.sensorClose != 0)) ? "Yes" : "No"
    }
}