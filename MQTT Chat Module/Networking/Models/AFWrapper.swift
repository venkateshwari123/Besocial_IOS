//
//  AFWrapper.swift
//  Sales Paddock
//
//  Created by 3Embed on 15/09/16.
//  Copyright © 2016 3Embed. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Locksmith
import CocoaLumberjack
import Alamofire
class AFWrapper: NSObject {
    
    class func requestPOSTURL(serviceName : String, params : [String : Any]?, header : HTTPHeaders , success:@escaping (JSON) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        
        let manager = Alamofire.Session.default
        manager.request(serviceName, method:.post, parameters: params, encoding: JSONEncoding.default, headers: APIUtility.getHeaderForPost()).responseJSON(completionHandler: {
            response in
            DDLogDebug("\(response)")
            
            switch response.result{
                
            case let .success(value):
                let resJson = JSON(value)
                var statusCode = 0
                if let statsCode = resJson["code"].int {
                    statusCode = statsCode
                } else if let statsCode = resJson["statusCode"].int {
                    statusCode = statsCode
                }
                switch statusCode
                {
                case 137 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have entered same phone number 3 or more times. Please try a new number", code: statusCode)
                    failure(error)
                case 138 :
                    let resJson = JSON(value)
                    success(resJson)
                case 139 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have tried three or more failed attempts.", code: statusCode)
                    failure(error)
                case 140 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "Abuse of device", code: statusCode)
                    failure(error)
                case 200..<204:
                    let resJson = JSON(value)
                    success(resJson)
                case 204:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 205..<300:
                    let resJson = JSON(value)
                    success(resJson)
                    
                case 300..<440:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 440:
                    DDLogDebug("session Expired")
                    
                default:
                    DDLogDebug("default code \(statusCode)")
                }
                
            case let .failure(error):
                Helper.hidePI()
                let customError = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: error.localizedDescription, code: 500)
                failure(customError)
            }
            
        })
    }
    
    
    class func requestDeleteURL(serviceName : String, params : [String : Any]?, header : HTTPHeaders , success:@escaping (JSON) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
//        let strURL = AppConstants.baseUrl + ":\(AppConstants.nodePort)" + serviceName

        let strURL = AppConstants.constantURL + serviceName
        let manager = Alamofire.Session.default
        manager.request(strURL, method:.delete, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            DDLogDebug("\(response)")
            
            switch response.result{
                
            case let .success(value):
                
                let resJson = JSON(value)
                var statusCode = 0
                if let statsCode = resJson["code"].int{
                    statusCode = statsCode
                } else if let statsCode = resJson["statusCode"].int{
                    statusCode = statsCode
                }
                switch statusCode
                {
                case 137 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have entered same phone number 3 or more times. Please try a new number", code: statusCode)
                    failure(error)
                case 138 :
                    let resJson = JSON(value)
                    success(resJson)
                case 139 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have tried three or more failed attempts.", code: statusCode)
                    failure(error)
                case 140 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "Abuse of device", code: statusCode)
                    failure(error)
                case 200..<204:
                    let resJson = JSON(value)
                    success(resJson)
                case 204:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 205..<300:
                    let resJson = JSON(value)
                    success(resJson)
                    
                case 300..<440:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 440:
                    DDLogDebug("session Expired")
                    
                default:
                    DDLogDebug("default code \(statusCode)")
                }
                
            case let .failure(error):
                
                Helper.hidePI()
                let customError = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: error.localizedDescription, code: 500)
                failure(customError)
                
            }
            
            
        })
    }
    
    class func requestPatchURL(serviceName: String, withParameter params:[String:Any],header : HTTPHeaders,success: @escaping(JSON) -> Void,failure:@escaping(CustomErrorStruct) -> Void){
        
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let header = ["authorization":token,
                      "lang":"en"
                      ]
        
        let manager = Alamofire.Session.default
        manager.request(serviceName, method:.patch, parameters: params, encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseJSON(completionHandler: {
            response in
            DDLogDebug("\(response)")
            
            switch response.result{
                
            case let .success(value):
                
                let resJson = JSON(value)
                var statusCode = 0
                if let statsCode = resJson["code"].int{
                    statusCode = statsCode
                } else if let statsCode = resJson["statusCode"].int{
                    statusCode = statsCode
                }
                switch statusCode
                {
                case 137 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have entered same phone number 3 or more times. Please try a new number", code: statusCode)
                    failure(error)
                case 138 :
                    let resJson = JSON(value)
                    success(resJson)
                case 139 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "You have tried three or more failed attempts.", code: statusCode)
                    failure(error)
                case 140 :
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: "Abuse of device", code: statusCode)
                    failure(error)
                case 200..<204:
                    let resJson = JSON(value)
                    success(resJson)
                case 204:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 205..<300:
                    let resJson = JSON(value)
                    success(resJson)
                    
                case 300..<440:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 440:
                    DDLogDebug("session Expired")
                    
                default:
                    DDLogDebug("default code \(statusCode)")
                }
                
            case let .failure(error):
                
                Helper.hidePI()
                let customError = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: error.localizedDescription, code: 500)
                failure(customError)
                
            }
            
        })
    }
    
    class func requestGETURL(serviceName : String, params: [String : Any], withHeader header : HTTPHeaders, success:@escaping (JSON) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        let strURL = AppConstants.constantURL  + serviceName
        
        let manager = Alamofire.Session.default
        manager.request(strURL, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            
            switch response.result{
                
            case let .success(value):
                
                let resJson = JSON(value)
                var statusCode = 0
                if let statsCode = resJson["code"].int{
                    statusCode = statsCode
                } else if let statsCode = resJson["statusCode"].int{
                    statusCode = statsCode
                }
                switch statusCode
                {
                case 200..<204:
                    let resJson = JSON(value)
                    success(resJson)
                case 204:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 205..<300:
                    let resJson = JSON(value)
                    success(resJson)
                    
                case 300..<440:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 440:
                    DDLogDebug("session Expired")
                default:
                    DDLogDebug("default code \(statusCode)")
                }
                
            case let .failure(error):
                
                let customError = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: error.localizedDescription, code: 500)
                failure(customError)
            }
        })
    }
    
    class func updloadPhoto(withPhoto photo: UIImage, andName name : String, progress : @escaping (Progress) -> Void, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        let strURL = AppConstants.uploadChatImage
        AFWrapper.updatePhotoByUsingMultipart(serviceName: strURL, image: photo, andName:name, progress: progress, success: { (response) in
            success(response)
        }, failure: { (error) in
            failure(error)
        })
    }
    
    private class func updatePhotoByUsingMultipart(serviceName : String, image:UIImage, andName name :String, progress : @escaping (Progress) -> Void, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        let strURL = AppConstants.uploadMultimediaURL + serviceName
        let imageData = image.jpegData(compressionQuality: 0.4)
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
              //  let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]

        
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(imageData!, withName: "photo", fileName: "\(name).jpeg", mimeType: "image/*|video/*|audio/*")
        },
                  to: strURL,
                  method: .post,
                  headers: HTTPHeaders.init(headers)).uploadProgress(queue: .main, closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }).responseJSON(completionHandler: { data in
            //Do what ever you want to do with response
            switch data.result {
            case .success(let value):
                if let data = value as? [String:Any] {
                    let resJSON = JSON(data)
                    success(resJSON)
                }
                
            case .failure(let encodingError):
                print("responseError: \(encodingError)")
                failure(encodingError)
            }
        }).response { (response) in
            switch response.result {
            case .success(let resut):
                print("upload success result: \(String(describing: resut))")
            case .failure(let err):
                print("upload err: \(err)")
            }
    }
        
        
    }
    
    class func updload(withMedia mediaURL: NSURL, andName name : String, withExtension mediaExtension : String, progress : @escaping (Progress) -> Void, success:@escaping (String) -> Void, failure:@escaping (Error) -> Void) {
        let strURL = AppConstants.uploadVideos
        guard let selfID = Utility.getUserid() else { return }
        let mediaName = "\(selfID)000\(name).\(mediaExtension)"
        DispatchQueue.global(qos: .default).async {
            AFWrapper.updateMediaByUsingMultipart(serviceName: strURL, mediaURL: mediaURL, andName: mediaName, progress: progress, success: { (response) in
                success(mediaName)
            }, failure: { (error) in
                failure(error)
            })
        }
    }
    
    private class func updateMediaByUsingMultipart(serviceName : String, mediaURL:NSURL, andName name:String, progress : @escaping (Progress) -> Void, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        let strURL = AppConstants.uploadMultimediaURL + serviceName
        let mediaURL = mediaURL as URL
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
              //  let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        
        let manager = Alamofire.Session.default
        manager.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(mediaURL, withName: "photo", fileName: name, mimeType: "image/*|video/*|audio/*")
        },
                       to: strURL,
                       method: .post,
                       headers: HTTPHeaders.init(headers)).uploadProgress(queue: .main, closure: { progress in
                 print("Upload Progress: \(progress.fractionCompleted)")
             }).responseJSON(completionHandler: { data in
                 //Do what ever you want to do with response
                 switch data.result {
                 case .success(let value):
                     if let data = value as? [String:Any] {
                         let resJSON = JSON(data)
                         success(resJSON)
                     }
                     
                 case .failure(let encodingError):
                     print("responseError: \(encodingError)")
                     failure(encodingError)
                 }
             }).response { (response) in
                 switch response.result {
                 case .success(let resut):
                     print("upload success result: \(String(describing: resut))")
                 case .failure(let err):
                     print("upload err: \(err)")
                 }
         }

    }
    
    
    
    class func requestPutURL(serviceName : String,withParameters params : [String:Any], header : HTTPHeaders, success:@escaping (JSON) -> Void, failure:@escaping (CustomErrorStruct) -> Void) {
        if !Rechability.isConnectedToNetwork() {
            Helper.hidePI()
            return
        }
        
        let manager = Alamofire.Session.default
        
        manager.request(serviceName, method:.put, parameters:params, encoding: JSONEncoding.default, headers: header).responseJSON(completionHandler: {
            response in
            Helper.hidePI()
            
            switch response.result{
                
            case let .success(value):
                
                let resJson = JSON(value)
                var statusCode = 0
                if let statsCode = resJson["code"].int{
                    statusCode = statsCode
                } else if let statsCode = resJson["statusCode"].int{
                    statusCode = statsCode
                }
                switch statusCode
                {
                case 200..<204:
                    let resJson = JSON(value)
                    success(resJson)
                case 204:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 205..<300:
                    let resJson = JSON(value)
                    success(resJson)
                    
                case 300..<440:
                    let error = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: resJson["message"].stringValue, code: statusCode)
                    failure(error)
                    
                case 440:
                    DDLogDebug("session Expired")
                    
                default:
                    DDLogDebug("default code \(statusCode)")
                }

                
            case let .failure(error):
                
                Helper.hidePI()
                let customError = CustomErrorStruct(localizedTitle: Strings.error, localizedDescription: error.localizedDescription, code: 500)
                failure(customError)
                
            }
        })
    }
}
