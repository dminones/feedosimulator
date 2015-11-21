//
//  DeviceViewController.swift
//  FeedoSimulator
//
//  Created by Dario Miñones on 11/14/15.
//  Copyright © 2015 Dario Miñones. All rights reserved.
//

import UIKit
import Parse

class DeviceViewController: UIViewController {
    var device : Device?
    var settings : [FeedSetting]?
    var nextSetting : FeedSetting?
    let  deviceCode = "deviceId=1"
    var timer : NSTimer?
    
    @IBOutlet var switchView : UISwitch?
    @IBOutlet var slider : UISlider?
    @IBOutlet var nextTimeLabel : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let query = Device.query()
        query!.whereKey("code", equalTo: deviceCode)
        query?.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if let device = object as? Device {
                    self.setDeviceData(device)
                    let feedSettingQuery = FeedSetting.query()
                    query!.whereKey("device", equalTo: device)
                    feedSettingQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error:NSError?) -> Void in
                        self.settings = objects as? [FeedSetting];
                        self.initTimers(self.settings!);
                        
                        self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "udateTimer", userInfo: nil, repeats: true)
                    })
                }
            } else {
                NSLog("Device not created yet")
            }
            
        })
    }
    
    func weekDayToFeedoWeekDay(day: Int) -> Int {
        var newDay = day-2;
        newDay = (newDay == -2) ? 6 : newDay;
        newDay = (newDay == -1) ? 0 : newDay;
        return newDay;
    }
    
    func secondOfDay(date:NSDate) -> Int {
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: date )
        let minute = NSCalendar.currentCalendar().component(.Minute, fromDate: date)
        let second = NSCalendar.currentCalendar().component(.Second, fromDate: date)
        return second + (minute*60) + (hour*60*60)
    }
    
    func initTimers(feedSettings: [FeedSetting]) {
        let date = NSDate()
        let components = NSCalendar.currentCalendar().component(.Weekday, fromDate: date)
        NSLog("Current Day %d",self.weekDayToFeedoWeekDay(components))

        for setting in feedSettings {
            
            if (setting.hasWeekDay(self.weekDayToFeedoWeekDay(components)) &&
                setting.time != nil &&
                self.secondOfDay(setting.time!) > self.secondOfDay(NSDate())) {
                    
                    
                    NSLog("time: %@ ", setting.timeToShow())
                    if ( nextSetting == nil ||
                        self.secondOfDay(nextSetting!.time!) > self.secondOfDay(setting.time!)) {
                        nextSetting = setting
                    }
            }
        }
        
    }
    
    func activateFeed() {
        let message = NSString(format: "Se dispensaron %@", (self.nextSetting?.getWeightString())!) as String
        let alert = UIAlertController(title: "Alimentador activado", message:message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
     
        self.nextSetting = nil;
        
        let push = PFPush()
        push.setMessage(message)
        push.sendPushInBackground()
    }
    
    func udateTimer() {
        if let nextSetting = self.nextSetting {
            NSLog("Next setting %@", nextSetting.timeToShow())
            NSLog("Next setting %@", nextSetting.time!)
            let interval = self.secondOfDay(nextSetting.time!) - self.secondOfDay(NSDate())
            
            if (interval <= 0) {
                self.activateFeed()
                self.initTimers(self.settings!)
                return
            }
            
            
            let sec = interval % 60
            let min = ((interval - sec)/60) % 60
            let hour = (((interval - sec)/60) - min) / 60
            
            self.nextTimeLabel!.text = NSString(format:"%d:%d:%d", hour,min,sec) as String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDeviceData(device: Device) {
        self.device = device
        self.switchView?.setOn(self.device!.sensorClose!.boolValue, animated: false)
        self.slider?.value = self.device!.foodStatus!.floatValue/100.0;
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        if let device = self.device {
            device.sensorClose = sender.on
        }
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        if let device = self.device {
            let value = sender.value*100
            device.foodStatus =  value>100 ? 100 : value;
        }
    }
    
    @IBAction func save (sender: UIButton) {
        if let device = self.device {
            device.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
                //self.activityIndicator?.stopAnimating()
                //animar
                
                if(success) {
                    //Cerrar
                    NSLog("Success %d",(device.foodStatus?.integerValue)!)
                } else {
                    //Error
                    NSLog("Error %@", (error?.description)!)
                }
                
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
