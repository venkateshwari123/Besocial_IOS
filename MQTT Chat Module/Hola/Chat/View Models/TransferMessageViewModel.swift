//
//  TransferMessageViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 11/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class TransferMessageViewModel: NSObject {

    let message : Message
    
    /// Initiaizing the message object with the Message object.
    ///
    /// - Parameter message: Message Object
    init(withMessage message: Message) {
        self.message = message
    }
    
}
