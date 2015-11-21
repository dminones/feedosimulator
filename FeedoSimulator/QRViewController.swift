//
//  ViewController.swift
//  FeedoSimulator
//
//  Created by Dario Miñones on 11/14/15.
//  Copyright © 2015 Dario Miñones. All rights reserved.
//

import UIKit
import Parse

class QRViewController: UIViewController {
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var activityIndicator : UIActivityIndicatorView?
    @IBOutlet var label : UILabel?
    
    var device  = Device()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  deviceCode = "deviceId=1"
        let query = Device.query()
        query!.whereKey("code", equalTo: deviceCode)
        query?.getFirstObjectInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                if let device = object as? Device {
                    self.setDeviceData(device)
                }
            } else {
                let device = Device()
                self.setDeviceData(device)
            }
            
        })
       
    }
    
    func setDeviceData(device: Device) {
        device.code = "deviceId=1"
        device.name = "Feedo 1"
        device.deviceCapacity = 90
        device.foodStatus = 90
        device.sensorClose = true
        device.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            self.activityIndicator?.stopAnimating()
            self.imageView?.hidden = false
            self.label?.text = "Código QR del dispositivo. Escanear para linkear"
            self.device = device
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

