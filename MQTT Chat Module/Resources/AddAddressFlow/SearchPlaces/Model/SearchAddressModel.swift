//
//  SearchAddressModel.swift
//  Pedija
//
//  Created by Rahul Sharma on 26/05/20.
//  Copyright © 2020 3Embed. All rights reserved.
//

import Foundation

struct AddAddressData: Codable{
    var name:String
    var mobileNumber:String
    var mobileNumberCode:String
    var CountryCode:String
    var addLine1:String
    var landmark:String
    var state:String
    var city:String
    var country:String
    var placeId:String
    var pincode:String
    var latitude:Float
    var longitude:Float
    var taggedAs:String
    var AddressType:Int
    var flatNumber:String

}

struct Places {
    var name : String?
    var placeId : String?
    var latlong :String?
    var latitude:Double?
    var longitude:Double?
    var structured_formatting:[String : Any]?
    var maintext:String? {
        guard let str = structured_formatting , let str2 = str["main_text"] as? String  else { return "" }
        return str2
    }
    var secondarytext:String? {
        guard let str = structured_formatting , let str2 = str["secondary_text"] as? String  else { return "" }
        return str2
    }
}
struct structured_formatting
{
    var secondary_text:String?
    var main_text_matched_substrings:[String : Any]?
    var main_text:String?
    
}
