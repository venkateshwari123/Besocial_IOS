//
//  IntegerExtension.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 21/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation

// This extension is used for random numbers
public extension ExpressibleByIntegerLiteral {
    public static func arc4random() -> Self {
        var r: Self = 0
        arc4random_buf(&r, MemoryLayout<Self>.size)
        return r
    }
}
