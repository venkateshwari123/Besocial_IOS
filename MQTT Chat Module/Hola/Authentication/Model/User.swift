//
//  User.swift
//  Starchat
//
//  Created by 3Embed on 21/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//



import UIKit
import Locksmith

struct UserResult:Codable{
    let response:UserData
}

struct UserData:Codable{
    let userId : String
    let token : String
    let email : String?
    let isActiveBusinessProfile : Bool
    let userType : Int
    let isStar : Int?
    let currency : String
    let currencySymbol : String
    let refreshToken : String
        init(from decoder:Decoder) throws{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            userId = try container.decode(String.self, forKey: .userId)
            token = try container.decode(String.self, forKey: .token)
            refreshToken = try container.decode(String.self, forKey: .token)
            do{ email = try container.decode(String.self, forKey: .email)
            }
            catch{
                email = ""
            }
            currency = try container.decode(String.self, forKey: .currency)
            currencySymbol = try container.decode(String.self, forKey: .currencySymbol)
            isActiveBusinessProfile = try container.decode(Bool.self, forKey: .isActiveBusinessProfile)
            
            userType = try container.decode(Int.self, forKey: .userType)
            
            do{isStar = try container.decode(Int.self, forKey: .isStar)}catch{
                isStar = 0
            }
            
            do{try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
            }catch{}
            UserDefaults.standard.setValue(email, forKeyPath: AppConstants.UserDefaults.userEmail)
            
            if isActiveBusinessProfile{
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
            }else {
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
            }
            
            if isStar == 1 {
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
            }else {
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
            }
            UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
            
            UserDefaults.standard.set(userId, forKey: AppConstants.UserDefaults.userID)
            UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
            UserDefaults.standard.set(refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
            UserDefaults.standard.synchronize()
        }
}



class User : NSObject,  NSCoding, NSSecureCoding {
   
    static var supportsSecureCoding: Bool {
      return true
    }
    
    var userId : String = ""
    var number : String = ""
    var countryCode: String = ""
   // var token : String = ""
    var isPrivate : Int = 0
    var qrCode : String = ""
    var userName : String = ""
    var refreshToken: String = ""
    var firstName : String = ""
    var lastName: String = ""
    var profileVideo : String = ""
    var profileVideoThumbnail : String = ""
    var profilePic : String = ""
    var coverImage: String = ""
    var email: String = ""
    init(modelData: [String : Any]){
        if let userId = modelData["userId"] as? String{
            self.userId = userId
        }
        if let number = modelData["number"] as? String{
            self.number = number
        }
        if let countryCode = modelData["countryCode"] as? String{
            self.countryCode = countryCode
        }
//        if let token = modelData["token"] as? String{
//            self.token = token
//        }
        if let isPrivate = modelData["private"] as? Int{
            self.isPrivate = isPrivate
        }
        if let qrCode = modelData["qrCode"] as? String{
            self.qrCode = qrCode
        }
        if let refreshToken = modelData["refreshToken"] as? String {
            self.refreshToken = refreshToken
        }
        if let userName = modelData["userName"] as? String{
            self.userName = userName
        }
        if let firstName = modelData["firstName"] as? String{
            self.firstName = firstName
        }
        if let profileVideo = modelData["profileVideo"] as? String{
            self.profileVideo = profileVideo
        }
        if let profileVideoThumbnail = modelData["profileVideoThumbnail"] as? String{
            self.profileVideoThumbnail = profileVideoThumbnail
        }
        if let profilePic = modelData["profilePic"] as? String{
            self.profilePic = profilePic
        }
        if let coverImage = modelData["profileCoverImage"] as? String {
            self.coverImage = coverImage
        }
        if let lastName = modelData["lastName"] as? String {
            self.lastName = lastName
        }
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        userId = (aDecoder.decodeObject(forKey:"userId") as? String)!
        number = (aDecoder.decodeObject(forKey:"number") as? String)!
//        token = (aDecoder.decodeObject(forKey:"token") as? String)!
        isPrivate = aDecoder.decodeInteger(forKey: "private")
        qrCode = (aDecoder.decodeObject(forKey:"qrCode") as? String)!
        userName = (aDecoder.decodeObject(forKey:"userName") as? String)!
        firstName = (aDecoder.decodeObject(forKey:"firstName") as? String)!
        profileVideo = (aDecoder.decodeObject(forKey:"profileVideo") as? String)!
        profileVideoThumbnail = (aDecoder.decodeObject(forKey:"profileVideoThumbnail") as? String)!
        profilePic = (aDecoder.decodeObject(forKey:"profilePic") as? String)!
        coverImage = (aDecoder.decodeObject(forKey:"profileCoverImage") as? String)!

        lastName = (aDecoder.decodeObject(forKey:"lastName") as? String)!

    }
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(number, forKey: "number")
//        aCoder.encode(token, forKey: "token")
        aCoder.encode(qrCode, forKey: "qrCode")
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(profileVideo, forKey: "profileVideo")
        aCoder.encode(profileVideoThumbnail, forKey: "profileVideoThumbnail")
        aCoder.encode(profilePic, forKey: "profilePic")
        aCoder.encode(isPrivate, forKey: "private")
        aCoder.encode(coverImage, forKey: "profileCoverImage")
        aCoder.encode(lastName, forKey: "lastName")
    }
}

