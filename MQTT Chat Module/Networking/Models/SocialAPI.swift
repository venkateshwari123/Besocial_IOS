//
//  SocialAPI.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 27/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

class SocialAPI: NSObject {
    
    //    let disposebag = DisposeBag()
    
    let limit: Int = 20
    let offset: Int = -20
    
    override init() {
        super.init()
    }
    
    //Get service call
    func getSocialData(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
       // let params = [String : Any]()
        let urlString = strURL.replace(target: " ", withString: "%20")
        var headers = [String:String]()
        guard let updatedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
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
         apiCall.newtworkRequestAPIcall(serviceName: updatedUrl, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
         apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            if let dataArray = dict["data"] {
                complitation(dataArray,nil)
            }else{
                complitation(dict,nil)
            }
            
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    //Get service call
    func getSocialDataForLan(withURL strURL: String,params: [String:Any]?, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
       // let params = [String : Any]()
        let urlString = strURL.replace(target: " ", withString: "%20")
        guard let updatedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        
        let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
         apiCall.newtworkRequestAPIcall(serviceName: updatedUrl, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
         apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    
    
    
    
    // Get Social data with basic Auth
    func getSocialDataWithBasicAuth(withURL strURL: String,params: [String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        let urlString = strURL.replace(target: " ", withString: "%20")
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
//        let headers = ["authorization":token,"lang": lang]
        let headers = ["Authorization": "\(basicAuth)"]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: urlString, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            guard let dataArray = dict["data"] else {return}
            complitation(dataArray,nil)
        }, onError: {error in
            
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    //Get service call for Distionary response
    func getSocialDataForDictionaryResponse(withURL strURL: String, complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            //            guard let data = dict else {return}
            complitation(dict,nil)
        }, onError: {error in
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    ///Put service call
    func putSocialData(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .put, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            //            DDLogDebug("output here \(response)")
            print("REsponse: \(response)")
            complitation(response,nil)
        }, onError: {error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    ///Post service call
    func postSocialData(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        var headers = [String:String]()

        if let guestUserStatus = Utility.getIsGuestUser() , guestUserStatus {
            var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
            basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
            basicAuth = "Basic \(basicAuth)"
            
            //        let headers = ["authorization":token,"lang": lang]
            headers = ["Authorization": "\(basicAuth)"]
                        print("headers : \(headers)")
        }else {
            guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {if strURL == AppConstants.logout {
                return Utility.logOut()
            }else {
                return
            }}
            
            /*
             Feat name:- send refreshToken in header
             Feat date:- 03/04/21
             Feat By  :- Nikunj C
             Description of Feat:- send refreshToken in header with purpose to remove token after log out for security purpose
             */
            
            guard  let token = keyDict["token"] as? String  else {return}
            
            if let refreshToken = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.refreshToken) as? String {
                headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"token":token,"refreshToken":refreshToken]
            }else{
                headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"token":token]
            }
            
        }
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    ///Post service call For Ian
      func postSocialDataForIan(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
          guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
          guard  let token = keyDict["token"] as? String  else {return}
          
          let headers = ["authorization":token,"lan": Utility.getSelectedLanguegeCode()]
          
          let apiCall = RxAlmofireClass()
          apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
          apiCall.subject_response.subscribe(onNext: {response in
              print(response)
              complitation(response, nil)
          }, onError: { error in
              Helper.hidePI()
              complitation(nil,error as? CustomErrorStruct)
          })
      }
    
    
    
    ///Post service call with basic auth
    func postSocialDataWithBasicAuth(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
//        let headers = ["authorization":token,"lang": lang,"token":token]
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        //        let headers = ["authorization":token,"lang": lang]
        let headers = ["Authorization": "\(basicAuth)"]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    
    /// To delete service call
    ///
    /// - Parameters:
    ///   - strURL: delete service call url
    ///   - params: params
    ///   - complitation: complitation handler to handle response and error
    func deleteSocialData(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"token":token]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .delete, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
    
    
    func createNewPost(newpostDetails:NewPostModel, complitation: @escaping(_ isUploaded: Bool,SocialModel?)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let params = self.createParametersForPost(newpostDetails: newpostDetails)
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName:"post/media", requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            if let data = response["data"] as? [String:Any], let arrayOps = data["ops"] as? [[String:Any]]{
            let postData = arrayOps[0]
            let newPost = SocialModel.init(modelData: postData)
                complitation(true,newPost)
            }
        }, onError: { error in
            Helper.hidePI()
            complitation(false,nil)
        })
    }
    
    func updatePost(newpostDetails:NewPostModel, complitation: @escaping(_ isUploaded: Bool)-> Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let params = self.createParametersForPost(newpostDetails: newpostDetails)
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName:"post", requestType: .put, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(true)
        }, onError: { error in
            Helper.hidePI()
            complitation(false)
        })
    }
    
    func createParametersForPost(newpostDetails:NewPostModel) -> [String : Any]{
        var mediaType = 0
        var thumbNailUrl = newpostDetails.mediaPath
        
        let stringArray = newpostDetails.caption.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        var arrayOfHashTags = [String]()
        var arrayOfTaggedUsers = [String]()
        
        for eachString in stringArray.enumerated() {
            if eachString.element.first == "#" {
                if eachString.element.count > 2 {
                    var hashtag = eachString.element
                    hashtag.removeFirst()
                    arrayOfHashTags.append(hashtag)
                }
            }
            
            if eachString.element.first == "@" {
                if eachString.element.count > 2 {
                    var userName = eachString.element
                    userName.removeFirst()
                    arrayOfTaggedUsers.append(userName)
                }
            }
        }
        
        if(newpostDetails.isVideo) {
            mediaType = 1
            thumbNailUrl = thumbNailUrl.replace(target:".mp4", withString:".jpg")
            thumbNailUrl = thumbNailUrl.replace(target:".mov", withString:".jpg")
        }
        
        var params = [
            //            "imageUrl1":newpostDetails.mediaPath,
            //                      "thumbnailUrl1":thumbNailUrl,
            "title":newpostDetails.caption,
            //                      "hasAudio1":0,
            //                      "mediaType1":mediaType,
            //                      "story":false,
            //                      "cloudinaryPublicId1":newpostDetails.cloudinaryPublicID,
            //                      "imageUrl1Width":"\(newpostDetails.width)",
            //            "imageUrl1Height":"\(newpostDetails.height)"
            ]as [String : Any]
        
        if let category = newpostDetails.category.categoryId , category != ""{
            params["categoryId"] = category
        }
        
        if newpostDetails.isEdit{
            params["postId"] = newpostDetails.postId
            if newpostDetails.selectedAddress == nil{
                params["latitude"] = "0"
                params["longitude"]  = "0"
                params["location"]  = ""
                params["place"]  = ""
                params["placeId"] = ""
            }
        }else{
            params["cloudinaryPublicId1"] = newpostDetails.cloudinaryPublicID
            params["imageUrl1Width"] = "\(newpostDetails.width)"
            params["imageUrl1Height"] = "\(newpostDetails.height)"
            params["imageUrl1"] = newpostDetails.mediaPath
            params["thumbnailUrl1"] = thumbNailUrl
            params["story"] = false
            params["mediaType1"] = mediaType
            params["hasAudio1"] = 0
            if let musicId = newpostDetails.selectedAudio?.id, musicId != "" {
                params["musicId"]  = newpostDetails.selectedAudio?.id
            }
        }
        
        
        params["postAmount"]  = newpostDetails.postAmount
        params["isPaid"]  = newpostDetails.isPaid
        
        
        if newpostDetails.channel != nil {
            params["channelId"]  = newpostDetails.channel?.channelId
        }
        
        if !arrayOfHashTags.isEmpty {
            let hastagsInArray = arrayOfHashTags.joined(separator: ",")
            params["hashTags"] = hastagsInArray
        }
        
        if !arrayOfTaggedUsers.isEmpty {
            params["userTags"] = arrayOfTaggedUsers
        }
        
        if newpostDetails.selectedAddress != nil {
            params["latitude"] = newpostDetails.selectedAddress?.latitude
            params["longitude"]  = newpostDetails.selectedAddress?.longitude
            params["location"]  = newpostDetails.location
            params["place"]  = newpostDetails.location
            params["placeId"] = newpostDetails.selectedAddress?.addressId
            //  params["countrySname"]  = newpostDetails.selectedAddress?.country
            //  params["city"]  = newpostDetails.selectedAddress?.city
        }
        
        
         params["businessPostTypeId"] = newpostDetails.businessPostTypeId
         params["businessPrice"] = newpostDetails.businessPrice
         params["businessUrl"] = newpostDetails.businessUrl
         params["businessCurrency"] = newpostDetails.businessCurrency
         params["businessButtonText"] = newpostDetails.businessButtonText
         params["businessButtonColor"] = newpostDetails.businessButtonColor
        
        /* Bug Name :- Allow comment not working issue
                  Fix Date :- 23/03/2021
                  Fixed By :- Vishal D
                  Description Of Fix :- Create Post: On editing the created Post comment to not allow and opening the same page again it is not being saved */
        params["allowComment"] = newpostDetails.allowComment
        params["allowDownload"] = newpostDetails.allowDownload
        
        return params
    }
    
    //Post service call for python apis
    func postSocialDataForPython(with strURL: String, params:[String:Any], complitation: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcallForPython(serviceName: strURL, requestType: .post, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            complitation(response, nil)
        }, onError: { error in
            Helper.hidePI()
            complitation(nil,error as? CustomErrorStruct)
        })
    }
}
