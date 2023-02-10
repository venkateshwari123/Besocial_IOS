//
//  RepliedMessage.swift
//  MQTT Chat Module
//
//  Created by Sachin Nautiyal on 13/03/2018.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import Foundation

struct RepliedMessage {
    
    var previousPayload : String!
    var previousFrom : String!
    var previousReceiverIdentifier : String!
    var previousId : String!
    var previousType : MessageTypes?
    var replyMessageType : MessageTypes?
}
