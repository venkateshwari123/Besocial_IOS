//
//  TopStarsViewModel.swift
//  PicoAdda
//
//  Created by 3Embed on 04/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class TopStarsViewModel{
    
    let trendingApi = TrendingAPI()
    var peopleArray = [PeopleModel]()
    var offset: Int = -20
    let limit: Int = 100
    
    
    
    ////Get category service call
    func getStarsUsers(strUrl: String,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        trendingApi.getCategoryData(withURL: strUrl) { (response, error)  in
            if let result = response as? [Any]{
                print(result)
                self.setPeopleModel(dataArray: result)
                 complitation(true, nil)
            }
            if let error = error{
                complitation(false, error)
            }
            Helper.hidePI()
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
