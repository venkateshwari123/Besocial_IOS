//
//  PlacesModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 31/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
import GooglePlaces

class PlacesModel: NSObject {
    
    //MARK:- Variables&Declarations
    var primarytext: String = ""
    var secondaryText: String?
    var placeId: String?
    var types:[String]?
    
    
    /// Business Model Data
    ///
    /// - Parameter businessmodelData:  The full description of the prediction  E.g., "Sydney Opera House,* Sydney, New South Wales, Australia".
    init(businessmodelData: GMSAutocompletePrediction){
        self.primarytext = businessmodelData.attributedPrimaryText.string
        self.secondaryText = businessmodelData.attributedSecondaryText?.string
        self.placeId = businessmodelData.placeID
        self.types = businessmodelData.types
    }
    
    //    init(dataBaseData: [String : Any]){
    //        if let primary = dataBaseData["primarytext"] as? String{
    //            self.primarytext = primary
    //        }
    //        if let secondary = dataBaseData["secondaryText"] as? String{
    //            self.secondaryText = secondary
    //        }
    //        if let id = dataBaseData["placeId"] as? String{
    //            self.placeId = id
    //        }
    //    }
}






///// Address Details Model
//class PlacesModel {
//
//    var businessaddressLine1 = ""
//    var businessaddressLine2 = ""
//    var businessaddressId = ""
//    var businesslatitude = ""
//    var businesslongitude = ""
//    var businesszipcode = ""
//    var businessflatNumber = ""
//    var businesstagAddress = ""
//    var businesscity = ""
//    var businessstate = ""
//    var businesscountry = ""
//    var businessfullAddress = ""
//
//    init(businessaddressDetails:Any?) {//For Saved and Previous search addresses
//
//        if let businessaddress = businessaddressDetails as?  [String : Any]{
//
//            businessaddressLine1 = GenericUtility.strForObj(object:businessaddress[ADDRESS.AddressLine1])
//            businessaddressLine2 = GenericUtility.strForObj(object: businessaddress[ADDRESS.AddressLine2])
//            businessfullAddress = GenericUtility.strForObj(object: businessaddress[ADDRESS.AddressLine1]) + ", " + GenericUtility.strForObj(object: businessaddress[ADDRESS.AddressLine2])
//            businessaddressId = GenericUtility.strForObj(object: businessaddress[ADDRESS.AddressId])
//            businesslatitude = GenericUtility.strForObj(object: businessaddress[ADDRESS.Latitude])
//            businesslongitude = GenericUtility.strForObj(object: businessaddress[ADDRESS.Longitude])
//            businessflatNumber = GenericUtility.strForObj(object: businessaddress[ADDRESS.FlatNumber])
//            businesstagAddress = GenericUtility.strForObj(object: businessaddress[ADDRESS.TagAddress])
//            businesszipcode = GenericUtility.strForObj(object: businessaddress[ADDRESS.ZipCode])
//
//        }
//
//    }
//
//    init(manageAddressDetails:Any?) {//For manage Addresses
//
//        if let address = manageAddressDetails as?  [String : Any]{
//
//            businessaddressLine1 = GenericUtility.strForObj(object:address["addLine1"])
//            businessfullAddress = GenericUtility.strForObj(object:address["addLine1"])
//            businessaddressLine2 = GenericUtility.strForObj(object: address["addLine2"])
//            businessaddressId = GenericUtility.strForObj(object: address["_id"])
//            businesslatitude = GenericUtility.strForObj(object: address["latitude"])
//            businesslongitude = GenericUtility.strForObj(object: address["longitude"])
//
//            if businesslatitude.count == 0 {
//
//                businesslatitude = "0.0"
//            }
//            if businesslongitude.count == 0 {
//
//                businesslongitude = "0.0"
//            }
//            businesstagAddress = GenericUtility.strForObj(object:address["taggedAs"])
//            businesszipcode = GenericUtility.strForObj(object: address["pincode"])
//
//        }
//
//    }
//
//    init(socialModel: SocialModel){
//        self.businessaddressLine1 = socialModel.place!
//        self.businesslatitude = "\(socialModel.lattitude!)"
//        self.businesslongitude = "\(socialModel.longitude!)"
//    }
//
//    class func forSearchAddress(addressDetails:GMSPlace) -> [String:Any] {//For current searched addresses
//
//        let addressDict = [
//            ADDRESS.AddressLine1:GenericUtility.strForObj(object:addressDetails.name),
//            ADDRESS.AddressLine2:GenericUtility.strForObj(object:addressDetails.formattedAddress),
//            ADDRESS.AddressId:GenericUtility.strForObj(object:addressDetails.placeID),
//            ADDRESS.Latitude:GenericUtility.strForObj(object:addressDetails.coordinate.latitude.description),
//            ADDRESS.Longitude:GenericUtility.strForObj(object:addressDetails.coordinate.longitude.description),
//            ]
//
//        return addressDict
//    }
//
//}
//
////Address
//struct businessAddress {
//
//    static let businessAddressLine1 = "addressLine1"
//    static let businessAddressLine2 = "addressLine2"
//    static let businessFullAddress   = "fullAddress"
//    static let businessAddressId = "addressId"
//    static let businessLatitude = "latitude"
//    static let businessLongitude = "longitude"
//    static let businessFlatNumber   = "flatNumber"
//    static let businessTagAddress = "tagAddress"
//    static let businessZipCode   = "zipCode"
//}
