//
//  CustomError.swift
//  Sales Paddock
//
//  Created by Rahul Sharma on 03/05/17.
//  Copyright © 2017 3Embed. All rights reserved.
//

import UIKit

class CustomError: NSObject {

}

protocol OurErrorProtocol: Error {
    
    var localizedTitle: String { get }
    var localizedDescription: String { get }
    var code: Int { get }
}


struct CustomErrorStruct: OurErrorProtocol {
    var localizedTitle: String
    var localizedDescription: String
    var code: Int
    
    init(localizedTitle: String?, localizedDescription: String, code: Int) {
        self.localizedTitle = localizedTitle ?? Strings.error.localized
        self.localizedDescription = localizedDescription
        self.code = code
    }
}
