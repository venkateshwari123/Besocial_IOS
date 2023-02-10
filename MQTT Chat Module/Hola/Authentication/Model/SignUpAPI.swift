//
//  SignUpAPI.swift
//  Starchat
//
//  Created by 3Embed on 21/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaLumberjack
import Locksmith
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDynamicLinks
import Alamofire 
class SignUpAPI: NSObject {
    //withemailID emailID : String, andPassword password: String, andUsername userName : String, andfirstName firstName : String, andlastName lastName : String, anduserReferralCode userReferralCode : String, andnumber number : String, andcountryCode countryCode : String, andisPrivate isPrivate : Bool
    func signUpUser(signUpData : [String : Any], withCallback callback:@escaping (_ loginData : User? , _ error : CustomErrorStruct?) -> Void) {
        Helper.showPI()
        let strURL =   AppConstants.signup

        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": lang]
        let headers = ["authorization": "\(basicAuth)","lan":Utility.getSelectedLanguegeCode()]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: signUpData, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            guard let userData = response["response"] as? [String:Any] else { return }
            guard let userID = userData["userId"] as? String, let token = userData["token"] else { return }
            
            do{try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)}catch{
                DDLogDebug("error handel it")
            }
            
            do{try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
            }catch{DDLogDebug("error handel it")}

            if let oneSignalId = userData["oneSignalId"] as? String {
                UserDefaults.standard.set(oneSignalId, forKey: AppConstants.UserDefaults.oneSignalId)
                Utility.subscribeToOneSignal(externalUserId: oneSignalId)
            }
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userID, forKeyPath: AppConstants.UserDefaults.userID)
            
            if let streamData = userData["stream"] as? [String:Any] {
                if let topic = streamData["fcmTopic"] as? String {
                    UserDefaults.standard.setValue(topic, forKeyPath: AppConstants.UserDefaults.fcmToken)
                }
            }
            if let currencyData = userData["currency"] as? [String:Any] {
                if let currencyCode = currencyData["currencyCode"] as? String {
                    UserDefaults.standard.set(currencyCode, forKey: AppConstants.UserDefaults.walletCurrency)
                }
                if let currencySymbol = currencyData["currencySymbol"] as? String {
                    UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.walletCurrecnySymbol)
                }
                if let currencyName = currencyData["countryCodeName"] as? String {
                    UserDefaults.standard.set(currencyName, forKey: AppConstants.UserDefaults.currencycountryCodeName)
                }

            }
            /*
             Bug Name:- Default intials pic not showing
             Fix Date:- 29/06/2021
             Fixed By:- Jayaram G
             Discription of Fix:- storing full name while signup
             */
            if let firstName = userData["firstName"] as? String {
                var fullName = firstName
                if let lastName = userData["lastName"] as? String{
                    fullName = fullName + lastName
                }
                UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userName)
                UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userFullName)
            }
            if let userNameToShow = userData["userName"] as? String {
                UserDefaults.standard.setValue(userNameToShow, forKeyPath: AppConstants.UserDefaults.userNameToShow)
            }
            if let isPrivate = userData["private"] as? Int{
                UserDefaults.standard.set(isPrivate, forKey: AppConstants.UserDefaults.isPrivate)
            }
            if let currency = userData["currency"] as? String{
                UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
            }
            if let currencySymbol = userData["currencySymbol"] as? String{
                UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
            }
//            if let profilePic = userData["profilePic"] as? String {
//                UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
//            }
            if let status = userData["socialStatus"] as? String{
                UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
            }else {
                UserDefaults.standard.setValue(AppConstants.defaultStatus, forKeyPath: AppConstants.UserDefaults.userStatus)
            }
            if let isbusinessActive = userData["isActiveBussinessProfile"] as? Int{
                if isbusinessActive == 1 {
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                    if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                        if let businessProfileImage = businessProfile.first?["businessProfilePic"]{
                            UserDefaults.standard.set(businessProfileImage, forKey: AppConstants.UserDefaults.userImage)
                        }
                    }else {
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        if let profilePic = userData["profilePic"] as? String {
                            UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                            UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                        }
                    }
                }
            }
            if let userNumber = userData["number"]  as? String {
                if let countryCode = userData["countryCode"] as? String {
                    UserDefaults.standard.setValue(userNumber.replace(target: countryCode, withString: ""), forKeyPath: AppConstants.UserDefaults.userNumber)
                    UserDefaults.standard.setValue(countryCode, forKeyPath: "countryCode")
                    UserDefaults.standard.setValue(countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)

                }
            }
            if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                if let businessEmail = businessProfile.first?["email"]{
                    UserDefaults.standard.set(businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
                }
                
                if let businessPhone = businessProfile.first?["phone"] as? [String:Any] {
                    UserDefaults.standard.set(businessPhone, forKey: AppConstants.UserDefaults.businessMobileNumber)
                }
            }
            
            
            let couchbase = Couchbase.sharedInstance
            
            let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
            indexDocVMObject.updateIndexDocID(isUserSignedIn: false)
            
            let usersDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
            usersDocVMObject.updateUserDoc(data: userData, withLoginType: "1")
            
            indexDocVMObject.updateIndexDocID(isUserSignedIn: true)
            guard let userToken = userData["token"] as? String else {return}
            let userObj = User.init(modelData: userData)
            usersDocVMObject.updateUserDoc(withUser: userObj.firstName, lastName: userObj.firstName, userName: userObj.firstName + " " + userObj.lastName, imageUrl: userObj.profilePic, privacy: userObj.isPrivate, loginType: "1", receiverIdentifier: "", docId: userToken, refreshToken: userObj.refreshToken)
            Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
            UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
           // self.createMQTTConnection()
            
            callback(userObj,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
//            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
            
    }
    
//    func createMQTTConnection() {
//        let mqttModel = MQTT.sharedInstance
//        mqttModel.createConnection()
//        //        self.subscribeAllMQTTTopics()
//    }
    
    func verifySignUpDetails(withemailID emailID : String, andUsername userName : String,  andnumber number : String, andcountryCode countryCode : String, withCallback callback:@escaping (_ verifyUser : [String : Any]? , _ error : CustomErrorStruct?) -> Void){
        
        let params : [String:Any] = ["email":emailID,
                                     "userName":userName,
                                    // "userReferralCode":userReferralCode,
                                     "number":number,
                                     "countryCode":countryCode]
        Helper.showPI()
        let strURL =   AppConstants.verifysignup
//        let headers = ["authorization":"KMajNKHPqGt6kXwUbFN3dU46PjThSNTtrEnPZUefdasdfghsaderf1234567890ghfghsdfghjfghjkswdefrtgyhdfghj"] as [String: String]
        
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
//            Helper.hidePI()
            callback(response,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }

    
    func checkingMobileNumberOTP(number : String, andcountryCode countryCode : String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
        let params = [String:Any]()
        let countryCodeObj = countryCode.replace(target: "+", withString: "%2B")
        let strURL =   AppConstants.isRegisteredNumber + "?" + "countryCode=\(countryCodeObj)" + "&" + "phoneNumber=\(number)"
        //guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        //guard  let token = keyDict["token"] as? String  else {return}
//        let headers = ["authorization":token] as [String: String]
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
         let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
     }
    
    
    
    
    func checkingEmailValidation(email:String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
        let params = [String:Any]()
        let strUrl = "isExists/emailId?emailId=\(email)"
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
         let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strUrl, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
     }
    
    
}
