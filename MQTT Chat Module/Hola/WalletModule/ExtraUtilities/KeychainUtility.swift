//
//  KeychainUtility.swift
//  Ufy_Store
//
//  Created by Raghavendra Shedole on 18/01/18.
//  Copyright © 2018 Nabeel Gulzar. All rights reserved.
//

import Foundation
import Locksmith
class KeychainHelper {
    static let sharedInstance = KeychainHelper()
    let keychain = KeychainSwift()
    private init(){
    }
    func storeData(data storeData:[String:Any] ) {
        
        if let data = storeData["data"] as? [String:Any]{
            
            /// saving userId in key chain
            if let userID = data[APIRequestParams.getInstance().userId] as? String{
                keychain.set(userID , forKey: APIRequestParams.getInstance().userId)
            }
            
            if let user = data[APIResponseParams.getInstance().user] as? [String : Any]{
                keychain.set(user[APIResponseParams.getInstance()._ld] as? String ?? "" , forKey: APIResponseParams.getInstance()._ld)
                keychain.set( String ( user[APIResponseParams.getInstance().creationTs] as? Int64 ?? 0) , forKey: APIResponseParams.getInstance().creationTs)
            }
            
            // saving token details
 
            
            if let token = data[APIResponseParams.getInstance().token] as? [String : Any]{
                keychain.set(String( token[APIResponseParams.getInstance().accessExpiry] as? Int ?? 0) , forKey: APIResponseParams.getInstance().accessExpiry)
                
                keychain.set(token[APIResponseParams.getInstance().accessToken] as? String ?? "" , forKey: APIResponseParams.getInstance().accessToken)
                
                keychain.set(token[APIResponseParams.getInstance().refreshToken] as? String ?? "" , forKey: APIResponseParams.getInstance().refreshToken)
            }
        }else{//temp fix - need to paas value proprly
            if let userID = storeData[APIRequestParams.getInstance().userId] as? String{
                keychain.set(userID , forKey: APIRequestParams.getInstance().userId)
            }
            
            if let user = storeData[APIResponseParams.getInstance().user] as? [String : Any]{
                keychain.set(user[APIResponseParams.getInstance()._ld] as? String ?? "" , forKey: APIResponseParams.getInstance()._ld)
                keychain.set( String ( user[APIResponseParams.getInstance().creationTs] as? Int64 ?? 0) , forKey: APIResponseParams.getInstance().creationTs)
            }
            
            // saving token details
            
            
            if let token = storeData[APIResponseParams.getInstance().token] as? [String : Any]{
                keychain.set(String( token[APIResponseParams.getInstance().accessExpiry] as? Int ?? 0) , forKey: APIResponseParams.getInstance().accessExpiry)
                
                keychain.set(token[APIResponseParams.getInstance().accessToken] as? String ?? "" , forKey: APIResponseParams.getInstance().accessToken)
                
                keychain.set(token[APIResponseParams.getInstance().refreshToken] as? String ?? "" , forKey: APIResponseParams.getInstance().refreshToken)
            }
        }
    }
    
    func storeGuestData(data storeData:Any ){
        
        if let data = storeData as? [String:Any]{
            
            /// saving userId in key chain
            if let userID = data[APIRequestParams.getInstance().userId] as? String{
                keychain.set(userID , forKey: APIRequestParams.getInstance().userId)
            }
            
            if let user = data[APIResponseParams.getInstance().user] as? [String : Any]{
                keychain.set(user[APIResponseParams.getInstance()._ld] as? String ?? "" , forKey: APIResponseParams.getInstance().guestID)
                keychain.set( String ( user[APIResponseParams.getInstance().creationTs] as? Int64 ?? 0) , forKey: APIResponseParams.getInstance().guestCreationTs)
            }
            
            // saving token details
            if let token = data[APIResponseParams.getInstance().token] as? [String : Any]{
                keychain.set(String( token[APIResponseParams.getInstance().accessExpiry] as? Int ?? 0) , forKey: APIResponseParams.getInstance().guestAccessExpiry)
                
                keychain.set(token[APIResponseParams.getInstance().accessToken] as? String ?? "" , forKey: APIResponseParams.getInstance().guestAccessToken)
                
                keychain.set(token[APIResponseParams.getInstance().refreshToken] as? String ?? "" , forKey: APIResponseParams.getInstance().guestRefreshToken)
            }
        }
    }
    
    func getGuestAccessToken() -> String{
        
        if let authKey = keychain.get(APIResponseParams.getInstance().guestAccessToken) {
            return authKey
        }
        return ""
    }
    
//    func getCountryCode() ->  String{
//        if let value = keychain.get(APIRequestParams.getInstance().CountryCode){
//            return value
//        }
//        return "+91"
//    }

    func getCreationTs() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().creationTs) {
            return value
        }
        return ""
    }
    
    func setWalletId(id: String){
        keychain.set(id , forKey: APIResponseParams.getInstance().walletId)
    }
    
    func getWalletId() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().walletId) {
            return value
        }
        return ""
    }
    
    
    func setEarningWalletId(id: String){
        keychain.set(id , forKey: APIResponseParams.getInstance().earningWalletId)
    }
    
    func getEarningWalletId() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().earningWalletId) {
            return value
        }
        return ""
    }
    
    
    
    func setWalletBalance(balance: String){
        keychain.set(balance , forKey: APIResponseParams.getInstance().walletBalance)
    }
    
    func getWalletBalance() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().walletBalance) {
            if value == "" {
                return "0"
            }
            return value
        }
        return "0"
    }
    
    
    func setEarningWalletBalance(balance: String){
        keychain.set(balance , forKey: APIResponseParams.getInstance().earningWalletBalance)
    }
    
    func getEarningWalletBalance() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().earningWalletId) {
            return value
        }
        return ""
    }
    
    
    //coin wallet
    func setCoinWalletId(id: String){
        keychain.set(id , forKey: "coinwalletId")
    }
    
    func getCoinWalletId() -> String{
        if let value = keychain.get("coinwalletId") {
            return value
        }
        return ""
    }
    
    func setCoinWalletBalance(balance: String){
        if AppConstants.appType == .picoadda {
            keychain.set(balance , forKey: "picoaddacoinwalletbalance")
        }else{
            keychain.set(balance , forKey: "dublycoinwalletbalance")
        }
        
    }
    
    func getCoinWalletBalance() -> String{
        if AppConstants.appType == .picoadda {
            if let value = keychain.get("picoaddacoinwalletbalance") {
                if value == "" {
                    return "0"
                }
                return value
            }
        }else{
            if let value = keychain.get("dublycoinwalletbalance") {
                if value == "" {
                    return "0"
                }
                return value
            }

        }
        return "0"
    }
   
    
    func setIsLogin(val : Bool ) {
        keychain.set(val , forKey: APIRequestParams.getInstance().isLogin)
    }
    func getIsLogin() -> Bool{
        if let val = keychain.getBool(APIRequestParams.getInstance().isLogin){
            return val
        }
        return false
    }
    
    func get_ID() -> String{
        if let value = keychain.get(APIResponseParams.getInstance()._ld) {
            return value
        }
        return ""
    }
    
    func getAppVersion() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().appVersion) {
            return value
        }
        return ""
    }
    
    func getDeviceId() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().deviceId) {
            return value
        }
        return ""
    }
    
    func getDeviceMake() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().deviceMake) {
            return value
        }
        return ""
    }

    func getDeviceModel() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().deviceModel) {
            return value
        }
        return ""
    }
    
    func getDeviceOs() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().deviceOs) {
            return value
        }
        return ""
    }
    
    func getDeviceTypeCode() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().deviceTypeCode) {
            return value
        }
        return ""
    }
    
    func getStatusCode() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().statusCode) {
            return value
        }
        return ""
    }
   
    func getStatusText() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().statusText) {
            return value
        }
        return ""
    }

    func getUserTypeCode() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().userTypeCode) {
            return value
        }
        return ""
    }

    func getPhoneNumber() -> String {
        
        if let value = keychain.get(APIRequestParams.getInstance().phoneNumber){
            return value
        }
        return ""
    }
    
    func getAccessExpiry() -> Int{
        if let value = keychain.get(APIResponseParams.getInstance().accessExpiry) {
            return Int(value) ?? 0
        }
        return 0
    }
    
    func getRefreshToken() -> String{
        if let value = keychain.get(APIResponseParams.getInstance().refreshToken) {
            return value
        }
        return ""
    }

    func getAuthorizationKey() -> String {
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return ""}
        guard  let token = keyDict["token"] as? String  else {return ""}
        return token
    }

    func getUserID() -> String {
        if let authKey = keychain.get(APIRequestParams.getInstance().userId) {
            return authKey
        }
        return get_ID()
    }
    
    func firstTimeLogin() -> Bool{
        if let val = keychain.getBool(APIResponseParams.getInstance().firstTimeLogin ){
            return val
        }
        return false
    }
    
    func clearKeychain() {
        keychain.clear()
    }

}


