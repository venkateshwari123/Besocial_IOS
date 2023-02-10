//
//  APi.swift
//  Yelo
//
//  Created by 3Embed on 09/08/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

class APIRequestParams {
    
    fileprivate static var obj : APIRequestParams!
    private init(){
    }
    
    public static func getInstance()-> APIRequestParams{
        if obj == nil{
            obj = APIRequestParams()
        }
        return obj
    }
    
    
    //    API Header
    let Language                                 = "lan"
    let Authorization                            = "authorization"
    let LanguageDefault                          = "en"
    let OS                                       = "iOS"
    let normalSignUP                             = 1
    let facebookSighUP                           = 2
    let googleSignUP                             = 3
    
    let mobile_OTP_Login                         = 1
    let facebookLogin                            = 2
    let googleLogin                              = 3
    let mailPasswordLogin                        = 4
    let usernamePasswordLogin                    = 5
    let ipAddress                                   = "ipaddress"
    
    let isLogin                                  = "isLogin"
    
    //  Login Request API
    
    let newPassword                              = "newPassword"
    let Password                                 = "password"
    let DeviceID                                 = "deviceId"
    let DeviceMake                               = "deviceMake"
    let DeviceModal                              = "deviceModel"
    let DeviceType                               = "deviceTypeCode"
    let DeviceOS                                 = "deviceOs"
    let DeviceTime                               = "deviceTime"
    let Latitude                                 = "latitude"
    let Longitude                                = "longitude"
    let PushToken                                = "pushToken"
    let AppVersion                               = "appVersion"
    let VerifyType                               = "verifyType"
    let profilePic                               = "profilePic"
    let inviterReferralCode                      = "inviterReferralCode"
    let termsAndCond                             = "termsAndCond"
    let dni                                      = "din"
    let loginType                                = "loginType"
    let username                                 = "username"
    let firstName                                = "firstName"
    let lastName                                 = "lastName"
    
    let driverId                                 = "driverId"
    let Email                                    = "email"
    let statusCode                               = "statusCode"
    
    let address                                  = "address"
    let gender                                   = "gender"
    let city                                     = "city"
    let state                                    = "state"
    let pinCode                                  = "pinCode"
    let prfilePic                                = "prfilePic"
    
    let document                                 = "document"
    let personal_id_number                       = "personal_id_number"
    let date                                     = "date"
    let country                                  = "country"
    let line1                                    = "line1"
    let postalCode                               = "postalCode"
    let day                                      = "day"
    let month                                    = "month"
    let year                                     = "year"
    let ip                                       = "ip"
    let facebookId                               = "facebookId"
    let googleId                                 = "googleId"
    
    let facebookVerified                         = "facebookVerified"
    let emailVerified                            = "emailVerified"
    let gmailVerified                            = "gmailVerified"
    let phoneNumberVerified                      = "phoneNumberVerified"
    let userTypeCode                             = "userTypeCode"
    let isPrivate                                = "isPrivate"
    let loginVerifiredBy                         = "loginVerifiredBy"
    let account_number                           = "account_number"
    let routing_number                           = "routing_number"
    let account_holder_name                      = "account_holder_name"
    let currency                                 = "currency"
    let userId                                   = "userId"
    
    let countryCodeName                          = "countryCodeName"
    
    let CountryCode                              = "countryCode"
    let dateOfBirth                              = "dateOfBirth"
    let phoneNumber                              = "phoneNumber"
    
    // Change Order Status
    let ProductId                                = "productId"
    let StoreId                                  = "storeId"
    let ManagerID                                = "managerId"
    let Status                                   = "status"
    let TimeStamp                                = "timestamp"
    let OrderID                                  = "orderId"
    let cancelReason                             = "reason"
    let DueTime                                  = "dueDatetime"
    let serviceType                              = "serviceType"
    let Items                                    = "items"
    let DeliveryCharge                           = "deliveryCharge"
    let uri                                      = "uri"
    //DispatchOrderToDriver
    let code                                     = "code"
    let trigger                                  = "trigger"
    let Images                                   = "images"
    
    let emailOrPhone                             = "emailOrPhone"
    let type                                     = "type"
    
    let assetTypeId                              = "assetTypeId"
    let assetSubTypeId                           = "assetSubTypeId"
    let attributesGroupIds                       = "attributesGroupIds"
    let id                                       = "id"
    let asset                                    = "asset"
    let asset_comment                            = "asset_comment"
    let appName                                  = "appName"
    let platform                                 = "platform"    
}

class APIResponseParams {
    fileprivate static var obj : APIResponseParams!
    private init(){
    }
    
    public static func getInstance()-> APIResponseParams{
        if obj == nil{
            obj = APIResponseParams()
        }
        return obj
    }
    
    
    //Basic
    let Message                                  = "message"
    let Data                                     = "data"
    let LogoutData                               = "message"
    let user                                     = "user"
    let token                                    = "token"
    //login
    let ReferralCode                             = "referralCode"
    let SessionToken                             = "token"
    let SId                                      = "sid"
    let Phone                                    = "mobile"
    let Email                                    = "email"
    let StoreName                                = "storeName"
    let CountryCode                              = "countryCode"
    let FCMTopic                                 = "fcmTopic"
    let MQTTTopic                                = "mqttTopic"
    
    let _ld                                      = "_id"
    let creationTs                               = "creationTs"
    let deviceDetail                             = "deviceDetail"
    let appVersion                               = "appVersion"
    let deviceId                                 = "deviceId"
    let deviceMake                               = "deviceMake"
    let deviceModel                              = "deviceModel"
    let deviceOs                                 = "deviceOs"
    let deviceTypeCode                           = "deviceTypeCode"
    let deviceTypeText                           = "deviceTypeText"
    let statusCode                               = "statusCode"
    let statusText                               = "statusText"
    let userTypeCode                             = "userTypeCode"
    let userTypeText                             = "userTypeText"
    
    let accessExpiry                             = "accessExpiry"
    let accessToken                              = "accessToken"
    let refreshToken                             = "refreshToken"
    
    let guestAccessExpiry                        = "guestAccessExpiry"
    let guestAccessToken                         = "guestAccessToken"
    let guestRefreshToken                        = "guestRefreshToken"
    let guestID                                  = "guestID"
    let guestCreationTs                          = "guestCreationTs"
    let firstTimeLogin                            = "firstTimeLogin"
    let walletId                                = "walletId"
    let earningWalletId                         = "earningWalletId"
    let walletBalance                            = "walletBalance"
    let earningWalletBalance                     = "earningWalletBalance"
    
    
}
