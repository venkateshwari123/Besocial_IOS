//
//  SavedCollectionAPI.swift
//  Starchat
//
//  Created by 3Embed on 30/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

class SavedCollectionAPI: NSObject {
    
    override init() {
        super.init()
    }
    
    func getSavedCollections(_ offset : Int, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.collections + "?offset=\(offset)&limit=\(20)", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            guard dict["data"] != nil || dict["posts"] != nil else {return}
            print(dict)
            completion(dict,nil)
        }, onError: {error in
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func addPostToBookmarks(_ postId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = ["postId" : postId]
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.bookmark, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func removePostFromBookmarks(_ postId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.bookmark+"?postId=\(postId)", requestType: .delete, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func createNewCollection(_ coverImage : String, collectionName : String, postIds : [String], completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        var params = [String : Any]()
        if coverImage.count == 0{
            params = ["postId" : postIds,
                      "collectionName": collectionName,
                ] as [String : Any]
        }else{
            params = ["postId" : postIds,
                      "collectionName": collectionName,
                      "coverImage":coverImage
                ] as [String : Any]
        }
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.createCollection, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func addPostsToCollection(_ collectionId : String, postIds : [String], completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = ["postIds" : postIds,
                      "collectionId": collectionId,
            ] as [String : Any]
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.addToCollection, requestType: .put, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func deleteCollection(_ collectionId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.deleteCollection+"?collectionId=\(collectionId)", requestType: .delete, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func editCollection(_ coverImage : String, collectionName : String, collectionId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        var params = [String : Any]()
        if coverImage.count == 0{
            params = ["collectionId" : collectionId,
                      "collectionName": collectionName,
                ] as [String : Any]
        }else{
            params = ["collectionId" : collectionId,
                      "collectionName": collectionName,
                      "coverImage":coverImage
                ] as [String : Any]
        }
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.editCollection, requestType: .put, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            Helper.hidePI()
            completion(dict,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func getBookmarkedPosts(completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.bookmark + "?offset=\(0)&limit=\(1500)", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            guard let dataArray = dict["data"] else {return}
            Helper.hidePI()
            completion(dataArray,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func getBookmarkedPostsToAdd(_ collectionId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.bookmarkById+"?collectionId=\(collectionId)", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            guard let dataArray = dict["data"] else {return}
            Helper.hidePI()
            completion(dataArray,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
    
    func getCollectionDetails(_ collectionId : String, completion: @escaping(_ socialModel: Any?, _ error : CustomErrorStruct?)-> Void){
        
        let params = [String : Any]()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        Helper.showPI()
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: AppConstants.collection + "?offset=\(0)&limit=\(1500)&collectionId=\(collectionId)", requestType: .get, parameters: nil  ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getTrendingResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            guard let dataArray = dict["data"] else {return}
            Helper.hidePI()
            completion(dataArray,nil)
        }, onError: {error in
            Helper.hidePI()
            completion(nil,error as? CustomErrorStruct)
        })
    }
}
