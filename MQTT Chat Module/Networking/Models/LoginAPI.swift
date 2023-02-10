//
//  UserAPI.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 31/10/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
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
class LoginAPI : NSObject {
    
    struct constants {
        static let email = "email"
    }
    
    /// This will used for logging in and do the API call
    ///
    /// - Parameters:
    ///   - emailID: users emailID
    ///   - password: current user password
    ///   - callback: return the current value provided by the
    ///   - loginObject: return the login Object with the login data.
    ///   - error: return error if there is any error from server or in the data.
    func loginUser(withuserName userName : String, andPassword password: String, andnumber number: String,andcountryCode countryCode : String,countryName:String, withCallback callback:@escaping (_ loginData : User? , _ error : CustomErrorStruct?) -> Void) {
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
        let modelNumber = UIDevice.modelName
        var params : [String : Any] = [:]
        if userName.count > 0{
            /* Bug Name : Login via password
                     Fix Date : 26-May-2021
                     Fixed By : Jayaram G
                     Description Of Fix : replaced username key with emailId
                     */

            params = ["emailId":userName as Any,
                      "password":password,
                      "countryName": "United States", //For dynamic countryName,
                      "deviceId":deviceID,
                      "deviceName":deviceName,
                      "deviceOs":deviceOs,
                      "modelNumber": modelNumber,
                      "appVersion":appVersion,
                      "deviceType":"1"
            ]
        }else{
            params = ["password":password,
                      "number":number as Any,
                      "countryCode":countryCode,
                      "countryName": "United States", //For dynamic countryName,
                      "deviceId":deviceID,
                      "deviceName":deviceName,
                      "deviceOs":deviceOs,
                      "modelNumber": modelNumber,
                      "appVersion":appVersion,
                      "deviceType":"1"
            ]
        }
        
        Helper.showPI()
        let strURL =   AppConstants.loginAPI
       // let headers = ["authorization":"KMajNKHPqGt6kXwUbFN3dU46PjThSNTtrEnPZUefdasdfghsaderf1234567890ghfghsdfghjfghjkswdefrtgyhdfghj"] as [String: String]
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
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
            
            if let streamData = userData["stream"] as? [String:Any] {
                if let topic = streamData["fcmTopic"] as? String {
                    UserDefaults.standard.setValue(topic, forKeyPath: AppConstants.UserDefaults.fcmToken)
                }
            }
            if let currency = userData["currency"] as? String{
                UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
            }
            /*
             Bug Name:- Default intials pic not showing
             Fix Date:- 29/06/2021
             Fixed By:- Jayaram G
             Discription of Fix:- storing full name while login via email
             */
            if let firstName = userData["firstName"] as? String {
                var fullName = firstName
                if let lastName = userData["lastName"] as? String{
                    fullName = fullName + lastName
                }
                UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userFullName)
            }
            if let currencySymbol = userData["currencySymbol"] as? String{
                UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
            }
            
            let userDefault = UserDefaults.standard
            userDefault.setValue(userID, forKeyPath: AppConstants.UserDefaults.userID)
            
            let couchbase = Couchbase.sharedInstance
            
            let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
            indexDocVMObject.updateIndexDocID(isUserSignedIn: false)
            
            let usersDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
            usersDocVMObject.updateUserDoc(data: userData, withLoginType: "1")
            
            indexDocVMObject.updateIndexDocID(isUserSignedIn: true)
            
            //guard let userDocID = usersDocVMObject.getCurrentUserDocID() else {return }
            guard let usertoken = userData["token"] as? String else {return}
            let userObj = User.init(modelData: userData)
            
            UserDefaults.standard.setValue(userObj.countryCode, forKeyPath: "countryCode")
            /*
             Bug Name:- Show full name in chats instead of username
             Fix Date:- 12/05/2021
             Fixed By:- Jayaram G
             Discription of Fix:- Replaced username with fullname
             */
            usersDocVMObject.updateUserDoc(withUser: userObj.firstName, lastName: userObj.firstName, userName: userObj.firstName + " " + userObj.lastName, imageUrl: userObj.profilePic, privacy: userObj.isPrivate, loginType: "1", receiverIdentifier: "", docId: usertoken, refreshToken: userObj.refreshToken)
            Helper.hidePI()
            callback(userObj,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
        
    }
    
    func requestOTP(withType type : Int, andnumber number : String, andcountryCode countryCode : String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
        let params : [String:Any] = [
            "type":type,
            "development":true,
            "phoneNumber":number,
            "countryCode":countryCode,
            "deviceId":"test",
        ]
        Helper.showPI()
        let strURL =   AppConstants.requestOTP
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        let headers = ["Authorization": "\(basicAuth)"]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
        
    }
    
    func requestOTPinEmail(withType type : Int, andUserEmailId userEmailId : String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
        let params : [String:Any] = [
            "type":type,
            "starUserEmailId":userEmailId
        ]
        Helper.showPI()
        let strURL =   AppConstants.requestEmailVerification
//        let headers = ["authorization":"KMajNKHPqGt6kXwUbFN3dU46PjThSNTtrEnPZUefdasdfghsaderf1234567890ghfghsdfghjfghjkswdefrtgyhdfghj"] as [String: String]
        
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            callback(response,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
    }
    
    
    
    
    
    func checkingMobileNumberOTP(number : String, andcountryCode countryCode : String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
//        let params : [String:Any] = [
//             "phoneNumber":number,
//            "countryCode":countryCode,
//         ]
        let params = [String:Any]()
        Helper.showPI()
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
    
    
    
    
    
    
    
    
    func verifyOtp(withType type : Int, andnumber number : String, andcountryCode countryCode : String, andotp otp : String, withCallback callback:@escaping (_ loginData : User? , _ error : CustomErrorStruct?) -> Void) {
        let params : [String:Any] = [
            "type":type,
            "phoneNumber":number,
            "countryCode":countryCode,
            "deviceId":"test",
            "otp" : otp,
            "deviceName":"iPhone",
            "deviceOs":"iOS",
            "modelNumber":"XR",
            "deviceType":"1",
            "appVersion":"1.0"
        ]
        Helper.showPI()
        let strURL =   AppConstants.verifyOTP
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        let headers = ["Authorization": "\(basicAuth)"]
        
        
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            Helper.hidePI()
            //guard let userData = response["data"] as? [String:Any] else { return }
            let loginObj = User.init(modelData: response["response"] as! [String : Any])
            callback(loginObj,nil)
            DDLogDebug("output here \(response)")
        }, onError: {error in
            Helper.hidePI()
            callback(nil,error as? CustomErrorStruct)
        })
        
    }
    
    func checkingEmailOTP(mail:String,userName:String,number : String, andcountryCode countryCode : String, withCallback callback:@escaping (_ loginData : [String : Any]? , _ error : CustomErrorStruct?) -> Void) {
            let params = [String:Any]()
            Helper.showPI()
            var strURL =   AppConstants.isRegisteredEmail + "?emailId=\(mail)"
            let countryCodeObj = countryCode.replace(target: "+", withString: "%2B")
    
            if userName.count > 0 {
                strURL = strURL + "&userName=\(userName)"
            }
            if number.count > 0 {
                strURL = strURL + "&countryCode=\(countryCodeObj)" + "&" + "mobileNo=\(number)"
            }
    
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
    
}
