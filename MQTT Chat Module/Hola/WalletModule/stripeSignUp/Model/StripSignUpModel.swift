//
//  StripSignUpModel.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import Foundation


class StripSignUpModel{
    var proofImage : imageOfProduct?
    var firstName = ""
    var lastName = ""
    var dateOfBirth: Date?
    var documentId = ""
    var ssn = ""
    var address = ""
    var city = ""
    var state = ""
    var zipCode = ""
    var country = ""
    
    func validate() -> Bool {
        var error = 0
        if proofImage == nil {error += 1}
        if firstName == "" {error += 1}
        if lastName == "" {error += 1}
        if dateOfBirth == nil {error += 1}
        if ssn == "" {error += 1}
        if documentId == "" {error += 1}
        if address == "" {error += 1}
        if city == "" {error += 1}
        if state == "" {error += 1}
        if zipCode == "" {error += 1}
        if country == "" {error += 1}
        return error == 0
    }
}



class imageOfProduct{
    var imgUrl = ""
    var img = UIImage()
    
    init(imgUrl:String,img:UIImage){
        self.imgUrl = imgUrl
        self.img = img
    }
}
