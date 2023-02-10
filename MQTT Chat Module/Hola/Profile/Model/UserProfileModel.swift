//
//  UserProfileModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 18/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

//    count =     {
//    follower = 27;
//    following = 21;
//    post = 0;
//    };
//struct Count {
//    var followers: Int = 0
//    var following: Int = 0
//    var post: Int = 0
//
//    init(data: [String : Any]) {
//        if let followers = data["follower"] as? Int{
//            self.followers = followers
//        }
//        if let follow = data["following"] as? Int{
//            self.following = follow
//        }
//        if let post = data["post"] as? Int{
//            self.post = post
//        }
//    }
//}

//    email =     {
//    id = "";
//    verified = 0;
//    };
struct EmailStatus{
    var emailId: String?
    var varified: Int = 0
    
    init(data: [String:Any]) {
        if let id = data["email"] as? String{
            self.emailId = id
        }
        if let status = data["verified"] as? Int{
            self.varified = status
        }
    }
}

class UserProfileModel: NSObject {
    

//    "_id" = 5b727caedbe34d52327bd138;
//    accessKey = 611227;
//    contacts =     (
//    "+919712675218",
//    );
//    count =     {
//    follower = 27;
//    following = 21;
//    post = 0;
//    };
    var userId: String?
//    var count: Count?
    
//    creationDate = "2018-08-14T06:54:38.197Z";
//    deviceInfo =     {
//    "_id" = 5ba08ec2e8bc5e00303f5318;
//    appVersion = "1.0.0";
//    creationDate = "2018-09-18T05:36:02.085Z";
//    deviceId = "600ADF2C-8AB5-45E1-BAF6-8AA1B23E77DE";
//    deviceName = "Rahul Sharma\U2019s iPhone";
//    deviceOs = "11.4";
//    deviceType = 1;
//    modelNumber = "iPhone SE";
//    timestamp = 1537248962085;
//    };
//    email =     {
//    id = "";
//    verified = 0;
//    };
    var email: EmailStatus?
//    existInUsers =     (
//    5b4dbe3d8dde25190edec674,
//    );
//    followers = 27;
//    following = 21;
//    iosAudioCallPush = BB66FEFA85806C6A32E273F0C1E675BD8DB6031ED97F714BF82D6AFDC89B3283;
//    iosMassageCallPush = 8177B8D84417D23CB1011466ABAAD43EDF08474DC302B9B7F32C4093ECEEDD8C;
//    iosVideoCallPush = 8177B8D84417D23CB1011466ABAAD43EDF08474DC302B9B7F32C4093ECEEDD8C;
//    isNewUser =     (
//    1,
//    1,
//    1
//    );
//    isdevelopment = 0;
//    lastName = "<null>";
//    firstName = alok;
//    followStatus = 0;
//    followers = 77;
//    following = 40;
//    postsCount = 0;
    var followersCount: Int = 0
    var followingCount: Int = 0
    var postsCount: Int = 0
    var isBlocked: Bool = false
    var isStar:Int = 0
    var businessProfileActive:Int?
//    countryCode = "+91";
//    number = "+917097098479";
//    postsCount = 0;
//    private = 0;
//    profilePic = "https://res.cloudinary.com/dqodmo1yc/image/upload/v1535024930/c8lschdgz7evudnmikd9.jpg";
//    registeredOn = 1534229678197;
//    status = "Hey! I am using Do Chat";
//    userName = alokalok;
//    userStatus = 1;
//    userStatusText = active;
    var firstName: String = ""
    var lastName: String = ""
    var webSite:String = "User's web site url..."
    var bioData = "Singer,Dancer,Programmer..."
    var followStatus: Int = 0
    var countryCode: String?
    var number: String?
    var privicy: Int = 0
    var profilePic: String?
    var registeredOn: Double?
    var status: String?
    var userName: String?
    var userStatus: Int = 0
    var friendStatusCode:Int = 0
    var userStatusText: String?
    var userReferralCode:String?
    var qrCode:String?
    var coverImage:String?
    var rucBalance:Double?
    var userEmail:String?
    var starRequest:StarProflie?
    var businessDetails:[businessProfile] = []
    var verified:[String:Any]?
    var subscriptionAmount:Double?
    var isSubscribe:Int?
    var subscriptionsCount:Int = 0
    var fullNameWithSpaces: String?
    var isVerifiedBusinessProfile:Int?
    var currency:UserCurrency?
    var subscriptionValidate: Double = 1624617546
    var earnCoins:Double = 0.0
    var isVerifiedEmail:Int = 0
    var isVerifiedNumber:Int = 0
    var kycStatus:Bool?
    
    override init(){
        super.init()
    }
    
    init(modelData: [String : Any]){
        if let id = modelData["_id"] as? String{
            self.userId = id
        }
//        if let countData = modelData["count"] as? [String:Any]{
//            self.count = Count(data: countData)
//        }
        if let endDate = modelData["subscribeEndDate"] as? Double {
            self.subscriptionValidate = endDate
        }
        if let wallet = modelData["wallet"] as? [String:Any] {
            if let earnedCoins = wallet["totalAmount"] as? Double{
                self.earnCoins = earnedCoins
            }
            
        }
        if let foll = modelData["followers"] as? Int{
            self.followersCount = foll
        }
        if let foll = modelData["following"] as? Int{
            self.followingCount = foll
        }
        if let count = modelData["postsCount"] as? Int{
            self.postsCount = count
        }
        if let blocked = modelData["isBlocked"] as? Int{
            self.isBlocked = (blocked != 0) ? true : false
        }
        if let kycStatus = modelData["isKYCApproved"] as? Bool {
            self.kycStatus = kycStatus
        }
        
        if let star = modelData["isStar"] as? Int {
            self.isStar = star
        }
        if let mail = modelData["email"] as? [String:Any]{
            self.email = EmailStatus(data: mail)
        }
        if let friendStatusCode = modelData["friendStatusCode"] as? Int {
            self.friendStatusCode = friendStatusCode
        }
        
        if let useremail = modelData["email"] as? String{
            self.userEmail = useremail
        }
        if let first = modelData["firstName"] as? String{
            self.firstName = first
        }
        if let last = modelData["lastName"] as? String{
            self.lastName = last
            self.fullNameWithSpaces = self.firstName + " " + last
        }
        if let status = modelData["followStatus"] as? Int{
            self.followStatus = status
        }
        if let code = modelData["countryCode"] as? String{
            self.countryCode = code
        }
        if let qrCode = modelData["qrCode"] as? String{
            self.qrCode = qrCode
        }
        if let number = modelData["number"] as? String{
            self.number = number
        }
        if let privicy = modelData["private"] as? Int{
            self.privicy = privicy
        }
        if let pic = modelData["profilePic"] as? String{
            self.profilePic = pic
        }
        if let registered = modelData["registeredOn"] as? Double{
            self.registeredOn = registered
        }
        if let status = modelData["status"] as? String{
            self.status = status
            if status == "" {
                self.status = AppConstants.defaultStatus
            }
        }
        if let name = modelData["userName"] as? String{
            self.userName = name
        }
        if let userStatus = modelData["userStatus"] as? Int{
            self.userStatus = userStatus
        }
        if let statusText = modelData["userStatusText"] as? String{
            self.userStatusText = statusText
        }
        if let referralCode = modelData["referralCode"] as? String{
            self.userReferralCode = referralCode
        }
       
        if let coverImage = modelData["profileCoverImage"] as? String{
            self.coverImage = coverImage
        }
        if let rucBalance = modelData["RUCBalance"] as? Double{
            self.rucBalance = rucBalance
        }
        if let starRequest = modelData["starRequest"] as? [String: Any]{
            self.starRequest = StarProflie.init(modelData: starRequest)
        }
        if let verified = modelData["verified"] as? [String:Any] {
            self.verified = verified
        }
        if let isVerifiedBusinessProfile = modelData["isActiveBusinessProfile"] as? Int{
            self.businessProfileActive = isVerifiedBusinessProfile
        }
        if let isApprovedBusinessProfile = modelData["isBusinessProfileApproved"] as? Int{
            self.isVerifiedBusinessProfile = isApprovedBusinessProfile
            if isApprovedBusinessProfile == 1{
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isBusinessProfileApproved)
            }else{
                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isBusinessProfileApproved)
            }
        }
        if let objbusinessDetails = modelData["businessProfile"] as? [[String:Any]] {
            for obj in objbusinessDetails{
                businessDetails.append(businessProfile.init(businessModelData: obj))
            }
        }
        if let isSubscribe = modelData["isSubscribe"] as? Int {
            self.isSubscribe = isSubscribe
        }
        if let subscribeUserCount = modelData["subscribeUserCount"] as? Int{
            self.subscriptionsCount = subscribeUserCount
        }
        if let subscriptionAmount = modelData["subscriptionAmount"] as? Double{
            self.subscriptionAmount = subscriptionAmount
        }
        if let currency = modelData["currency"] as? [String:Any] {
            self.currency = UserCurrency(data: currency)
        }
        if let verifiedNumber = modelData["isVerifiedNumber"] as? Int {
            self.isVerifiedNumber = verifiedNumber
        }
        if let VerifiedEmail = modelData["isVerifiedEmail"] as? Int {
            self.isVerifiedEmail = VerifiedEmail
        }
    }

    func makeCopy()-> UserProfileModel{
        let userProfielModel = UserProfileModel()
        userProfielModel.userId = self.userId
//        userProfielModel.count = self.count
        userProfielModel.followersCount = self.followersCount
        userProfielModel.followingCount = self.followingCount
        userProfielModel.postsCount = self.postsCount
        userProfielModel.email = self.email
        userProfielModel.firstName = self.firstName
        userProfielModel.lastName = self.lastName
        userProfielModel.followStatus = self.followStatus
        userProfielModel.countryCode = self.countryCode
        userProfielModel.number = self.number
        userProfielModel.privicy = self.privicy
        userProfielModel.profilePic = self.profilePic
        userProfielModel.registeredOn = self.registeredOn
        userProfielModel.status = self.status
        userProfielModel.userName = self.userName
        userProfielModel.userStatus = self.userStatus
        userProfielModel.userStatusText = self.userStatusText
        userProfielModel.userReferralCode = self.userReferralCode
        userProfielModel.qrCode = self.qrCode
        userProfielModel.coverImage = self.coverImage
        userProfielModel.rucBalance = self.rucBalance
        userProfielModel.starRequest = self.starRequest
        userProfielModel.userEmail = self.userEmail
        userProfielModel.businessDetails = self.businessDetails
        userProfielModel.verified = self.verified
        userProfielModel.subscriptionAmount = self.subscriptionAmount
        userProfielModel.isSubscribe = self.isSubscribe
        userProfielModel.subscriptionsCount = self.subscriptionsCount
        userProfielModel.businessProfileActive = self.businessProfileActive
        userProfielModel.isStar = self.isStar
        userProfielModel.isVerifiedBusinessProfile = self.isVerifiedBusinessProfile
        userProfielModel.isVerifiedEmail = self.isVerifiedEmail
        userProfielModel.isVerifiedNumber = self.isVerifiedNumber
        return userProfielModel
    }
    
}


class StarProflie: NSObject {
    var approvalDate:Double?
    var categoryId:String?
    var categoryName:String?
    var descriptionTxt:String?
    var starUserEmail:String?
    var starUserIdProof:String?
    var starUserKnownBy:String?
    var starUserPhoneNumber:String?
    var starCountryCode:String?
    var starUserProfileStatusCode:Int?
    var starUserProfileStatusText:String?
    var timestamp:Double?
    var userId:String?
    var isEmailVisible:Int?
    var isNumberVisible:Int?
    var isChatVisible:Int?

    init(modelData: [String:Any]){
        if let approvalDate = modelData["approvalDate"] as? Double {
            self.approvalDate = approvalDate
        }
        
        if let isChatVisible = modelData["isChatVisible"] as? Int {
            self.isChatVisible = isChatVisible
        }
        
        if let isEmailVisible = modelData["isEmailVisible"] as? Int {
            self.isEmailVisible = isEmailVisible
        }
        
        if let isNumberVisible = modelData["isNumberVisible"] as? Int {
            self.isNumberVisible = isNumberVisible
        }
        
        if let starCountryCode = modelData["countryCode"] as? String {
            self.starCountryCode = starCountryCode
        }
        
        if let categorieId = modelData["categorieId"] as? String {
            self.categoryId = categorieId
        }
        
        if let categoryName = modelData["categoryName"] as? String {
            self.categoryName = categoryName
        }
        
        if let description = modelData["description"] as? String {
            self.descriptionTxt = description
        }
        
        if let starUserEmail = modelData["starUserEmail"] as? String {
            self.starUserEmail = starUserEmail
        }
        
        if let starUserIdProof = modelData["starUserIdProof"] as? String {
            self.starUserIdProof = starUserIdProof
        }
        
        if let starUserKnownBy = modelData["starUserKnownBy"] as? String {
            self.starUserKnownBy = starUserKnownBy
        }
        
        if let starUserPhoneNumber = modelData["starUserPhoneNumber"] as? String {
            self.starUserPhoneNumber = starUserPhoneNumber
        }
        
        if let starUserProfileStatusCode = modelData["starUserProfileStatusCode"] as? Int {
            self.starUserProfileStatusCode = starUserProfileStatusCode
        }
        
        if let starUserProfileStatusText = modelData["starUserProfileStatusText"] as? String {
            self.starUserProfileStatusText = starUserProfileStatusText
        }
        
        if let timestamp = modelData["timestamp"] as? Double {
            self.timestamp = timestamp
        }
        
        if let userId = modelData["userId"] as? String {
            self.userId = userId
        }
    }
}

class UserCurrency: NSObject {
    
    var countryCodeName: String?
    var currencyCode: String?
    var currencySymbol: String?
    
    
    init(data: [String:Any]){
        if let currencyCode = data["currencyCode"] as? String {
            self.currencyCode = currencyCode
        }
        
        if let currencySymbol = data["currencySymbol"] as? String {
            self.currencySymbol = currencySymbol
        }
        
        if let currencyCodeName = data["countryCodeName"] as? String {
            self.countryCodeName = currencyCodeName
        }
        
    }
}

class businessProfile: NSObject {
    
    var businessCategoryName:String?
    var businessName:String?
  //  var businessAddress:String?
    var businessStreetAddress:String?
    var businessFullAddress:String?
    var businessCity:String?
    var businessZipCode:String?
    var businessEmail:BusinessEmail?
    var businessPhone:BusinessPhone?
    var businessBio:String?
    var businessWebsite:String?
    var businessCategoryId:String?
    var businessProfileStatus:String?
    var isChatvisible:Int?
    var businessProfileImage:String?
    var businessCoverImage:String?
    var businessLat:String?
    var businessLang:String?
    var businessUserName:String?
    
    init(businessModelData: [String:Any]){
        if let businessCategoryName = businessModelData["businessCategory"] as? String{
            self.businessCategoryName = businessCategoryName
        }
        if let businessProfileImage = businessModelData["businessProfilePic"] as? String {
            self.businessProfileImage = businessProfileImage
        }
        if let businessUsername = businessModelData["businessUsername"] as? String {
            self.businessUserName = businessUsername
        }
        
        if let businessCoverImage = businessModelData["businessProfileCoverImage"] as? String {
            self.businessCoverImage = businessCoverImage
        }
        if let businessName = businessModelData["businessName"] as? String{
            self.businessName = businessName
        }
        if let businessFullAddress = businessModelData["address"] as? String{
            self.businessFullAddress = businessFullAddress
        }
        if let businessStreetAddress = businessModelData["businessStreet"] as? String{
            self.businessStreetAddress = businessStreetAddress
        }
        if let businessCity = businessModelData["businessCity"] as? String{
            self.businessCity = businessCity
        }
        if let businessZipCode = businessModelData["businessZipCode"] as? String{
            self.businessZipCode = businessZipCode
        }
        if let businessEmail = businessModelData["email"] as? [String: Any]{
            self.businessEmail = BusinessEmail.init(modelData: businessEmail)
        }
        if let businessBio = businessModelData["businessBio"] as? String {
            self.businessBio = businessBio
        }
        if let businessWebsite = businessModelData["websiteURL"] as? String {
            self.businessWebsite = businessWebsite
        }
        if let businessCategoryId = businessModelData["businessCategoryId"] as? String{
            self.businessCategoryId = businessCategoryId
            UserDefaults.standard.setValue(businessCategoryId, forKey: AppConstants.UserDefaults.businessCategoryID)
            
        }
        if let isChatVisible = businessModelData["isChatVisible"] as? Int {
            self.isChatvisible = isChatVisible
        }
        if let businessPhone = businessModelData["phone"] as? [String: Any]{
            self.businessPhone = BusinessPhone.init(modelData: businessPhone)
        }
    
        if let businessProfileStatus = businessModelData["statusText"] as? String{
            self.businessProfileStatus  = businessProfileStatus
        }
        if let businessLat = businessModelData["businessLat"] as? String {
            self.businessLat = businessLat
        }
        if let businessLang = businessModelData["businessLng"] as? String {
            self.businessLang = businessLang
        }
    }
}

class BusinessEmail: NSObject {
    var emailid:String?
    var isVisible:Int?
    var isVerified:Int?
    
    init(modelData: [String : Any]){
        if let email = modelData["id"] as? String {
            self.emailid = email
        }
        if let isVisible = modelData["isVisible"] as? Int {
            self.isVisible = isVisible
        }
        if let isVerified = modelData["verified"] as? Int {
            self.isVerified = isVerified
        }
    }
}

class BusinessPhone: NSObject {
    var countryCode:String?
    var mobileNumber:String?
    var isVisible:Int?
    var isVerified:Int?
    
    init(modelData: [String : Any]){
        if let number = modelData["number"] as? String {
            self.mobileNumber = number
        }
        if let number = modelData["mobile"] as? String {
            self.mobileNumber = number
        }
        if let isVisible = modelData["isVisible"] as? Int {
            self.isVisible = isVisible
        }
        if let isVerified = modelData["verified"] as? Int {
            self.isVerified = isVerified
        }
        if let countryCode = modelData["countryCode"] as? String {
            self.countryCode = countryCode
        }
        
    }
}
