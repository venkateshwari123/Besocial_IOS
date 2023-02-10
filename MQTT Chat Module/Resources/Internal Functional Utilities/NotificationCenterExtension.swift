//
//  NotificationCenter.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 29/01/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func setObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name, object: AnyObject?) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}
