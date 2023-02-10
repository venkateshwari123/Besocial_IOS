//
//  CommentsViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class CommentsViewModel: NSObject {

    let commentApi = SocialAPI()
    
    var commentModelArray = [FullCommentModel]()
    var peopleArray = [PeopleModel]()
    var hashTagArray = [HashTagModel]()
    var offset: Int = -20
    let limit: Int = 20
    var peopleOffset: Int = -20
    var tagOffset: Int = -20
    
    /// To get all comments
    ///
    /// - Parameters:
    ///   - strUrl: comment string url
    ///   - complitation: complitation handler after compliting service call
    func commentServiceCall(strUrl: String,params:[String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset = offset + 20
        let url = strUrl + "&offset=\(offset)&limit=\(limit)"
        commentApi.getSocialData(withURL: url, params: params) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setCommentModel(modelData: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
            Helper.hidePI()
        }
    }
    
    
    
    /// To set service response in model array
    ///
    /// - Parameter modelData: data array to set in model array
    func setCommentModel(modelData: [Any]){
        if offset == 0{
            self.commentModelArray.removeAll()
        }
        for data in modelData{
            guard let dict = data as? [String : Any] else{return}
            let commentModel = FullCommentModel(modelData: dict)
            self.commentModelArray.append(commentModel)
        }
    }
    
    
    func postCommentServiceCall(strUrl: String, params: [String : Any], complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        commentApi.postSocialData(with: strUrl, params: params) { (response, error) in
//            print("response: \(response)")
            if  let result = response as? [String : Any]{
                guard let dict = result["data"] as? [String : Any] else{return}
                if let userImage = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String, let userName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userName) as? String{
                    let commentModel = FullCommentModel(postModelData: dict, userImage: userImage, userName: userName)
//                    self.commentModelArray.append(commentModel)
                    self.commentModelArray.insert(commentModel, at: 0)
                    complitation(true, error)
                }
            }else if let error = error{
                complitation(false, error)
            }
        }
    }
    
    
    /// service call of people, channel and hastag
    ///
    /// - Parameters:
    ///   - url: url of api
    ///   - type: type of api
    ///   - finished: complitation handler
    func getSearchData(with url: String, type: TableType, finished: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        
        let strURl = getStringUrl(url: url, type: type)
        
        commentApi.getSocialData(withURL: strURl, params: [:]) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                print(modelData)
                self.setDataInModel(type: type, response: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                finished(true, nil, canServiceCall)
            }
            if let error = customError{
                if error.code == 204{
                    self.handleSearchResult(type: type)
                    finished(true, error, false)
                }else{
                    finished(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    /// To get string Url according to tableview type
    ///
    /// - Parameters:
    ///   - url: base url
    ///   - type: type of table view
    /// - Returns: string url
    func getStringUrl(url: String, type: TableType)-> String{
        switch type {
        case .people:
            peopleOffset = peopleOffset + limit
            return url + "offset=\(0)&limit=\(limit)"
        case .channel:
            return ""
        case .tag:
            tagOffset = tagOffset + limit
            return url + "skip=\(0)&limit=\(limit)"
        }
    }
    
    
    /// To set data in differnet model array
    ///
    /// - Parameters:
    ///   - type: type of api
    ///   - response: response of api
    func setDataInModel(type: TableType, response: [Any]){
        
        switch type {
        case .people:
            setPeopleModel(dataArray: response)
            break
        case .channel:
            break
        case .tag:
            setTagModel(dataArray: response)
            break
        }
    }
    
    /// To set data in people model array
    ///
    /// - Parameter dataArray: data array to set
    func setPeopleModel(dataArray: [Any]){
//        if peopleOffset == 0{
            self.peopleArray.removeAll()
//        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = PeopleModel(modelData: modelData)
            self.peopleArray.append(model)
        }
    }
    
    /// To set data in hastag array
    ///
    /// - Parameter dataArray: data array to set
    func setTagModel(dataArray: [Any]){
//        if tagOffset == 0{
            self.hashTagArray.removeAll()
//        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = HashTagModel(modelData: modelData)
            self.hashTagArray.append(model)
        }
    }
    
    
    func handleSearchResult(type: TableType){
        switch type {
        case .people:
            if peopleOffset == 0{
                peopleArray.removeAll()
            }
            break
        case .channel:
            break
        case .tag:
            if tagOffset == 0{
                hashTagArray.removeAll()
            }
        }
    }
}
