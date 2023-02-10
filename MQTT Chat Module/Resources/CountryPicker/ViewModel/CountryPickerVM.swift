//
//  CountryPickerVM.swift
//  Shoppd
//
//  Created by Rahul Sharma on 01/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

struct CountryPicker:Codable{
    let countryCode:String?
    let countryName:String?
    let countryNameCode:String?
    
    enum CodingKeys:String,CodingKey{
        case countryName = "name"
        case countryCode = "dial_code"
        case countryNameCode = "code"
    }
    
}

class  CountryPickerVM: NSObject {
    
    private(set) static var countries: [CountryPicker] = []
    
   static func getCountry(completeion:@escaping(Bool)->Void){
        let plistDecoder = PropertyListDecoder()
        if let path = Bundle.main.path(forResource: "CallingCodes", ofType: "plist") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonData = try plistDecoder.decode([CountryPicker].self, from: data)
                countries = jsonData.filter{$0.countryCode != nil && $0.countryName != nil && $0.countryNameCode != nil}
                completeion(true)
            } catch let error as NSError{
                print(error.localizedDescription)
                completeion(false)
            }
        }
    }
}
