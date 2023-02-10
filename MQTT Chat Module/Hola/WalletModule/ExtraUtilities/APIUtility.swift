//
//  API.swift
//  Yelo
//
//  Created by 3Embed on 09/08/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import Foundation
import Alamofire
import Locksmith

class APIUtility {
    
    
    class func getHeaderForPost() -> HTTPHeaders {
        
        let keychainHelper = KeychainHelper.sharedInstance
        
        let header : HTTPHeaders = [APIRequestParams.getInstance().Language : UserDefaultConstants.getInstance().getLang(),
                      APIRequestParams.getInstance().Authorization : keychainHelper.getAuthorizationKey(),
                      APIRequestParams.getInstance().ipAddress : UserDefaultConstants.getInstance().getIpAddress(),
                      APIRequestParams.getInstance().Latitude : UserDefaultConstants.getInstance().getLat(),
                      APIRequestParams.getInstance().Longitude :UserDefaultConstants.getInstance().getlong(),
                      APIRequestParams.getInstance().city : UserDefaultConstants.getInstance().getCity(),
                      APIRequestParams.getInstance().country : UserDefaultConstants.getInstance().getCountry(),
                      APIRequestParams.getInstance().appName : UserDefaultConstants.getInstance().getAppName(),
                      APIRequestParams.getInstance().platform : UserDefaultConstants.getInstance().getPlatform()
        ]
        
        if header[APIRequestParams.getInstance().Authorization] != ""{
            return header
        }else {
            return getGuestHeaders()
        }
        
    }
    
    class func getLoginHeader()-> HTTPHeaders{
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return HTTPHeaders()}
        guard  let token = keyDict["token"] as? String  else {return HTTPHeaders()}
        
        let headerParams:HTTPHeaders = APIUtility.getLoginHeader()
        
        return headerParams
    }
    
    class func getGuestUserHeader()-> HTTPHeaders{
        
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers:HTTPHeaders = ["authorization":token,"lang": "en"]
        let headers: HTTPHeaders = ["Authorization": "\(basicAuth)"]
        
        return headers
    }
    
    
    class func getHeader_New() -> [String : String] {
        
        let keychainHelper = KeychainHelper.sharedInstance
        
        let header = [APIRequestParams.getInstance().Language : Utility.getSelectedLanguegeCode(),
                      APIRequestParams.getInstance().Authorization : keychainHelper.getAuthorizationKey() , "device":"mobile"]
//                      ,"Content-Type" : "application/json"]

        return  header
       
    }
    
    class func getLogin() -> Bool {
        if UserDefaults.standard.bool(forKey: "_storeLoginStatus") {
            return true
        }else {
            return false
        }
    }
    
    class func getIsLoginFirstTime() -> Bool{
        
        if UserDefaults.standard.bool(forKey: "isLoginFirstTime") == true {
            return true
        }else {
            return false
        }
    }
    
    class func setIsLoginFirstTime(loginStatus : Bool ){
        UserDefaults.standard.set(loginStatus, forKey: "isLoginFirstTime")
    }
    
    class func setLogin(loginStatus:Bool) {
        UserDefaults.standard.set(loginStatus, forKey: "_storeLoginStatus")
    }
    
    class func removeLogin() {
        UserDefaults.standard.removeObject(forKey: "_storeLoginStatus")
    }
    
    class func getLang() -> HTTPHeaders {
        let langCode = Utility.getSelectedLanguegeCode()
        let lang : HTTPHeaders = [APIRequestParams.getInstance().Language : langCode]
        return lang
    }
    
    class func getGuestHeaders() -> HTTPHeaders{
        let keychainHelper = KeychainHelper.sharedInstance
        
        let header : HTTPHeaders = [APIRequestParams.getInstance().Language : Utility.getSelectedLanguegeCode(),
                      APIRequestParams.getInstance().Authorization : keychainHelper.getGuestAccessToken(),
                      APIRequestParams.getInstance().ipAddress : UserDefaultConstants.getInstance().getIpAddress(),
                      APIRequestParams.getInstance().Latitude : UserDefaultConstants.getInstance().getLat(),
                      APIRequestParams.getInstance().Longitude :UserDefaultConstants.getInstance().getlong(),
                      APIRequestParams.getInstance().city : UserDefaultConstants.getInstance().getCity(),
                      APIRequestParams.getInstance().country : UserDefaultConstants.getInstance().getCountry()]
        return header
    }
}
