//
//  TrendingAPI.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

class TrendingAPI: NSObject {
    
    override init() {
        super.init()
    }
 
    //Get service call
    func getCategoryData(withURL strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        var headers = [String:String]()
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            
            headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        print("headers : \(headers)")
        let apiCall = RxAlmofireClass()
         apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .get, parameters: nil , headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
         _ = apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
              guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    //Post service call for python apis
        func postTrendingDataForExplorePage(with strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
            
            var headers = [String:String]()
                guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
                guard  let token = keyDict["token"] as? String  else {return}
                
                headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]

            print("headers : \(headers)")
            let apiCall = RxAlmofireClass()
            apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.postTrendingResponse.rawValue)
            apiCall.subject_response.subscribe(onNext: {response in
    //            print(response)
                complitation(response, nil)
            }, onError: { error in
                Helper.hidePI()
                complitation(nil,error as? CustomErrorStruct)
            })
        }
    
    
    //Post service call for python apis
    func postTrendingData(with strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        var headers = [String:String]()
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
            basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
            basicAuth = "Basic \(basicAuth)"
            
                  //  let headers = ["authorization":token,"lang": lang]
            headers = ["Authorization": "\(basicAuth)"]
        }else {
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            print(token)
            
            headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
            print("headers : \(headers)")
        }
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.postTrendingResponse.rawValue)
      _ = apiCall.subject_response.subscribe(onNext: {response in
            complitation(response["data"], nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    

        //Post service call for python apis
    func hashTagTrendingPostsData(with strURL: String,hashTag: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        /*
        Bug Name : clicking on 2 nd post in hash tag faise , opens the correct post but on scroll up the order does not match what is shown on hash tags list page
        Fix Date : 24-May-2021
        Fixed By : Jayaram G
        Description Of Fix : Changed Api from node to python and passing hashtag in header
      */
        
        
        var headers = [String:String]()
        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
            basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
            basicAuth = "Basic \(basicAuth)"
            
                  //  let headers = ["authorization":token,"lang": lang]
            headers = ["Authorization": "\(basicAuth)","HashTag": hashTag]
        }else {
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            print(token)
            
            headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"HashTag": hashTag]
            print("headers : \(headers)")
        }
            let apiCall = RxAlmofireClass()
            apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.postTrendingResponse.rawValue)
           _ = apiCall.subject_response.subscribe(onNext: {response in
                complitation(response["data"], nil)
            }, onError: { error in
                Helper.hidePI()
                complitation(nil,error as? CustomErrorStruct)
            })
        }
    
    
    //Get service call
    func uploadViewersData(withURL strURL: String,params: [String:Any]?, complitation: @escaping( _ error : CustomErrorStruct?)-> Void){
        guard let updatedUrl = strURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        var headers = [String:String]()
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
            guard  let token = keyDict["token"] as? String  else {return}
            print(token)
            
            headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
            print("headers : \(headers)")
        let apiCall = RxAlmofireClass()
         apiCall.newtworkRequestAPIcallForPython(serviceName: updatedUrl, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
         _ = apiCall.subject_response.subscribe(onNext: {dict in
            if dict["data"] != nil{
               complitation(nil)
            }
            else{
                complitation(nil)
            }
        }, onError: {error in
            complitation(error as? CustomErrorStruct)
        })
    }
}
