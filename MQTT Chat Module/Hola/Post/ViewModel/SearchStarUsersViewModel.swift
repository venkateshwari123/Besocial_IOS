//
//  SearchStarUsersViewModel.swift
//  Starchat
//
//  Created by 3Embed on 17/10/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

class SearchStarUsersViewModel {
 
    let searchStarApi = SocialAPI()
    var peopleArray = [PeopleModel]()
    var offset: Int = -20
    let limit: Int = 100

    
    func getStarUsersDataService(strUrl: String,searchText: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        Helper.showPI()
        var url:String = ""
        offset = offset + 20
        if searchText == "" {
             url = strUrl + "?skip=\(offset)&limit=\(limit)"
        }else {
            url = strUrl + "?searchText=\(searchText)&skip=\(offset)&limit=\(limit)"
        }
        
        searchStarApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.offset = self.offset + 20
                self.setPeopleModel(dataArray: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                Helper.hidePI()
                self.offset = self.offset - 20
                if error.code == 204{
                    self.peopleArray.removeAll()
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
//    func setPostModelData(response: [Any]){
//        if self.offset == 0{
////            self.postModelArray.removeAll()
//        }
//        for data in response{
//            guard let modelData = data as? [String : Any] else{continue}
//            let postModel = SocialModel(modelData: modelData)
////            self.postModelArray.append(postModel)
//        }
//    }
    
    
    /// To set data in people model array
    ///
    /// - Parameter dataArray: data array to set
    func setPeopleModel(dataArray: [Any]){
        if offset == 0{
        self.peopleArray.removeAll()
        }
        for data in dataArray{
            guard let modelData = data as? [String : Any] else {continue}
            let model = PeopleModel(modelData: modelData)
            self.peopleArray.append(model)
        }
    }
    
    
    func getFriendsUsersDataService(strUrl: String,searchText: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        Helper.showPI()
        var url:String = ""
        offset = offset + 20
        if searchText == "" {
             url = strUrl + "?skip=\(offset)&limit=\(limit)"
        }else {
            url = strUrl + "?searchText=\(searchText)&skip=\(offset)&limit=\(limit)"
        }
        
        searchStarApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            Helper.hidePI()
            if let result = response as? [Any]{
                print(result)
                self.offset = self.offset + 20
                self.setPeopleModel(dataArray: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                Helper.hidePI()
                self.offset = self.offset - 20
                if error.code == 204{
                    self.peopleArray.removeAll()
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    
    
    
    
    //MARK:- follow and unfollow update database and Service call
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
        
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
    }
}
