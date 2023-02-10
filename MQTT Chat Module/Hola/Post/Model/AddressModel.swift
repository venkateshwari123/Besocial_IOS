//
//  SelectedAddressModel.swift
//  LiveM
//
//  Created by Apple on 01/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
import GooglePlaces


/// Address Details Model
class AddressModel {
    
    var addressLine1 = ""
    var addressLine2 = ""
    var addressId = ""
    var latitude = ""
    var longitude = ""
    var zipcode = ""
    var flatNumber = ""
    var tagAddress = ""
    var city = ""
    var state = ""
    var country = ""
    var fullAddress = ""

    init(addressDetails:Any?) {//For Saved and Previous search addresses
        
        if let address = addressDetails as?  [String : Any]{
        
            addressLine1 = GenericUtility.strForObj(object:address[ADDRESS.AddressLine1])
            addressLine2 = GenericUtility.strForObj(object: address[ADDRESS.AddressLine2])
            fullAddress = GenericUtility.strForObj(object: address[ADDRESS.AddressLine1]) + ", " + GenericUtility.strForObj(object: address[ADDRESS.AddressLine2])
            addressId = GenericUtility.strForObj(object: address[ADDRESS.AddressId])
            latitude = GenericUtility.strForObj(object: address[ADDRESS.Latitude])
            longitude = GenericUtility.strForObj(object: address[ADDRESS.Longitude])
            flatNumber = GenericUtility.strForObj(object: address[ADDRESS.FlatNumber])
            tagAddress = GenericUtility.strForObj(object: address[ADDRESS.TagAddress])
            zipcode = GenericUtility.strForObj(object: address[ADDRESS.ZipCode])
        
        }
        
    }
    
    init(manageAddressDetails:Any?) {//For manage Addresses
        
        if let address = manageAddressDetails as?  [String : Any]{
            
            addressLine1 = GenericUtility.strForObj(object:address["addLine1"])
            fullAddress = GenericUtility.strForObj(object:address["addLine1"])
            addressLine2 = GenericUtility.strForObj(object: address["addLine2"])
            addressId = GenericUtility.strForObj(object: address["_id"])
            latitude = GenericUtility.strForObj(object: address["latitude"])
            longitude = GenericUtility.strForObj(object: address["longitude"])
            
            if latitude.count == 0 {
                
                latitude = "0.0"
            }
            if longitude.count == 0 {
                
                longitude = "0.0"
            }
            tagAddress = GenericUtility.strForObj(object: address["taggedAs"])
            zipcode = GenericUtility.strForObj(object: address["pincode"])
            
        }

    }
    
    init(socialModel: SocialModel){
        self.addressLine1 = socialModel.place ?? ""
        self.latitude = "\(socialModel.lattitude ?? 0.0)"
        self.longitude = "\(socialModel.longitude ?? 0.0)"
    }
    
    class func forSearchAddress(addressDetails:GMSPlace) -> [String:Any] {//For current searched addresses
        
        let addressDict = [
                    ADDRESS.AddressLine1:GenericUtility.strForObj(object:addressDetails.name),
                    ADDRESS.AddressLine2:GenericUtility.strForObj(object:addressDetails.formattedAddress),
                    ADDRESS.AddressId:GenericUtility.strForObj(object:addressDetails.placeID),
                    ADDRESS.Latitude:GenericUtility.strForObj(object:addressDetails.coordinate.latitude.description),
                    ADDRESS.Longitude:GenericUtility.strForObj(object:addressDetails.coordinate.longitude.description),
                   ]
        
        return addressDict
    }
    
}

//Address
struct ADDRESS {
    
    static let AddressLine1 = "addressLine1"
    static let AddressLine2 = "addressLine2"
    static let FullAddress   = "fullAddress"
    static let AddressId = "addressId"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let FlatNumber   = "flatNumber"
    static let TagAddress = "tagAddress"
    static let ZipCode   = "zipCode"
}
