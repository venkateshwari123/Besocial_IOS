//
//  LoginModel.swift
//  Shoppd
//
//  Created by Rahul Sharma on 03/10/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit

struct LoginToken:Codable{
    let accessExpireAt:Int
    let accessToken:String
    let refreshToken:String
}

struct PhoneLogin:Codable{
    let data:OtpId
}

struct OtpId:Codable{
    let otpId:String
//    let otpExpiryTime:String
}

struct VerifyOtp:Codable{
    let data:AccessTokenID
}

struct AccessTokenID:Codable{
    let accessToken:String
}

struct LogOut:Codable{
    let data:LogOutdata
}

struct LogOutdata:Codable{
    let token:LoginToken
}

struct FaceBookModel:Codable{
    let email:String
    let id:String
    let last_name:String
    let first_name:String
    let name:String
    let picture:FaceBookProfile
}

struct FaceBookProfile:Codable{
    let data:FaceBookProfileData
}

struct FaceBookProfileData:Codable {
    let url:String
}

struct ResponseMessage:Codable{
    let message:String
}

struct RefreshTokenData:Codable{
    let data:RefreshToken
}

struct RefreshToken:Codable{
    let accessExpireAt:Double
    let accessToken:String
}



enum SocialLogin :Int {
    case Facebook = 0
    case Google
    case Apple
}

enum ForgotPasswordOptions :Int {
    case Email = 1
    case Phone = 2
}

class Languages: NSObject {
   
    var name = ""
    var code = ""
    
     init(name:String,code:String) {
        self.name = name
        self.code = code
    }
    init(modelData:[String:Any]) {
        if let name = modelData["language"] as? String{
            self.name = name
        }
        
        if let code = modelData["languageCode"] as? String{
            if code == "sw-KE"{
                self.code = "sw"
            }else{
                self.code = code
            }
            
        }
    }
}
