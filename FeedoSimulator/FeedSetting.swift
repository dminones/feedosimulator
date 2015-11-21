//
//  FeedSetting.swift
//  ParseStarterProject
//
//  Created by Dario on 7/24/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import Parse

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

class FeedSetting: PFObject, PFSubclassing {
    @NSManaged  var time : NSDate?
    @NSManaged  var weight : NSNumber?
    @NSManaged  var days : NSMutableArray?
    static let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    static let shortWeekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    static func parseClassName() -> String {
        return "FeedSetting"
    }
    
    func timeToShow() -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier:"en_US")
        formatter.dateFormat = "HH:mm"
        
        
        if let time=self.time {
            return formatter.stringFromDate(time)
        }
        return "No Date"
    }
    
    func getDays() -> NSMutableArray {
        
        if let currentDays = days {
            return currentDays
        }
        
        return [0,1,2,3,4,5,6]
    }
    
    func daysString() -> String {
        var result = ""
        let currentWeekDays = self.getDays()
        
        if currentWeekDays.count == 7 {
            return "Todos los dias"
        }
        
        for day in currentWeekDays{
            result += FeedSetting.weekDays[day.integerValue] + " "
        }
        
        return result=="" ? "Nunca" : result
    }
    
    func getWeight() -> NSNumber {
        if let weight = self.weight {
            return weight
        }
        return 500
    }
    
    func getWeightString() -> String {
        return self.getWeight().stringValue.stringByAppendingString(" gr")
    }
    
    func addWeekDay(weekDay: NSNumber) {
        if !self.hasWeekDay(weekDay){
            days!.addObject(weekDay)
        }
    }
    
    func removeWeekDay(weekDay: NSNumber) {
        if self.hasWeekDay(weekDay){
            days!.removeObject(weekDay)
        }
    }
    
    func hasWeekDay(weekDay: NSNumber) -> Bool{
        return getDays().containsObject(weekDay)
    }
    
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
}