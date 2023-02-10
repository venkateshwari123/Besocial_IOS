//
//  UserDefaultConstants.swift
//  Yelo
//
//  Created by 3Embed on 8/31/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import UIKit

class UserDefaultConstants {

    fileprivate static var obj : UserDefaultConstants!
    private init(){
    }
    public static func getInstance()-> UserDefaultConstants{
        if obj == nil{
            obj = UserDefaultConstants()
        }
        return obj
    }

    let isLoggedIn                                   = "isLoggedIn"
    let referralCode                                 = "referralCode"
    let currency                                     = "currency"
    let currentLatitude                              = "currentLatitude"
    let currentLongitude                             = "currentLongitude"
    let userprofile                                  = "userprofile"
    let AssetTypeId                                  = "assetTypeId"
    let AssetSubtypeId                               = "assetSubtypeId"
    let AssetSubSubTypeId                            = "assetSubSubTypeId"
    let RememberMe                                   = "rememberMe"
    let lat                                          = "lat"
    let long                                         = "long"
    let address                                      = "address"
    let AssetTypeName                                = "AssetTypeName"
    let AssetSubtypeName                             = "AssetSubtypeName"
    let AssetSubSubTypeName                          = "AssetSubSubTypeName"
    let LanguageCode                                 = "LanguageCode"
    let country                                         = "country"
    let city                                            = "city"
    let ipAddress                                       = "ipAddress"
    let otpTimer                                        = "OTP_timer"
    let otpLastTime                                     = "OTP_Last_Time"
    let currentCountryCode                              = "currentCountryCode"
    let currentDialCode                                 = "currentDialCode"
    let isOpenFromAppDelegate                           = "isOpenFromAppDelegate"
    let PicoAdda                                         = "PicoAdda"
    let platform                                        = "2"
    func saveLatAndLong(lat: Double, long: Double,address: String){
    
        UserDefaults.standard.setValue(lat, forKey: self.lat)
        UserDefaults.standard.setValue(long, forKey: self.long)
        UserDefaults.standard.setValue(address, forKey: self.address)
        
    }
    
    func getLatLong() -> (lat : Double , long : Double){
        var lat : Double = 0.0  , long : Double = 0.0
        if let _lat = UserDefaults.standard.object(forKey: self.lat) as? Double {
            lat = _lat
        }
        
        if let _long = UserDefaults.standard.object(forKey: self.long) as? Double {
            long = _long
        }
        
        return  (lat : lat , long : long)
    }
    
    func getLang() -> String{
        if let lang = UserDefaults.standard.object(forKey: self.LanguageCode) as? String {
            return lang
        }
        return "en"
    }
    
    func setLang(lang : String ){
        
        UserDefaults.standard.set(lang, forKey: self.LanguageCode)
    }
  
    
    func getIpAddress() -> String{
        if let ip =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().ipAddress) as? String{
            return ip
        }
        return ""
    }
    
    func getCity() -> String{
        if let city =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().city) as? String{
            return city
        }
        return ""
    }
    
    func getLat() -> String{
        if let lat =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().lat) as? String{
            return lat
        }
        
        if let lat =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().lat) as? Double{
            return String(lat)
        }

        return ""
    }
    
    func getlong() -> String{
        if let long =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().long) as? String{
            return long
        }
        
        if let long =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().long) as? Double{
            return String(long)
        }
        return ""
    }
    
    func getCountry() -> String{
        if let country =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().country) as? String{
            return country
        }
        return ""
    }
    
    func getCurrentCountryCode() -> String{
        if let countryCode =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().currentCountryCode) as? String{
            return countryCode
        }
        return ""
    }
    
    func getCurrentDialCode() -> String{
        if let dialCode =  UserDefaults.standard.object(forKey:  UserDefaultConstants.getInstance().currentDialCode) as? String{
            return dialCode
        }
        return ""
    }
    
    func getAppName() -> String{
        return PicoAdda
    }
    
    func getPlatform() -> String{
        return platform
    }
    
 
    
    func setRememberMe(value : Bool){
         UserDefaults.standard.set(value, forKey: self.RememberMe)
    }
    
    func getRememberMe() -> Bool{
        if let value = UserDefaults.standard.object(forKey: self.RememberMe ) as? Bool{
            return value
        }
        return false
    }
 
    
    func saveCountryCode(countryCode : String ){
        UserDefaults.standard.set(countryCode, forKey: APIRequestParams.getInstance().CountryCode)
    }
    
    func getCountryCode() -> String{
        if let countryCode = UserDefaults.standard.string(forKey: APIRequestParams.getInstance().CountryCode){
            return countryCode
        }
        return ""
    }
    
    func getCountryCodeName() -> String{
        if let countryCode = UserDefaults.standard.string(forKey: APIRequestParams.getInstance().countryCodeName){
            return countryCode
        }
        return ""
    }
    
    func saveCountryCodeName(countryCode : String ){
        UserDefaults.standard.set(countryCode, forKey: APIRequestParams.getInstance().countryCodeName)
    }
    
    
    func saveCountryName(countryName: String){
         UserDefaults.standard.set(countryName, forKey: APIRequestParams.getInstance().country)
    }
    
    func getCountryName() -> String{
        if let countryName = UserDefaults.standard.string(forKey: APIRequestParams.getInstance().country){
            return countryName
        }
        return ""
    }
    
    
//    func saveFCMPushToken( FCMPushToken : String){
//         UserDefaults.standard.set(FCMPushToken, forKey: self.FCMPushToken)
//    }
//
//    func getFCMPushToken() -> String {
//        if let countryCode = UserDefaults.standard.string(forKey: self.FCMPushToken){
//            return countryCode
//        }
//        return ""
//    }
}

extension UserDefaults {
    func decode<T : Codable>(for type : T.Type, using key : String) -> T? {
        let defaults = UserDefaults.standard
        guard let data = defaults.object(forKey: key) as? Data else {return nil}
        let decodedObject = try? PropertyListDecoder().decode(type, from: data)
        return decodedObject
    }
    
    func encode<T : Codable>(for type : T, using key : String) {
        let defaults = UserDefaults.standard
        let encodedData = try? PropertyListEncoder().encode(type)
        defaults.set(encodedData, forKey: key)
        defaults.synchronize()
    }
}
