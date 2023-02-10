//
//  FollowViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowViewModel: NSObject {
    
    
    /// Variables obj Declarations
    let followApi = SocialAPI()
    var followModelArray = [FollowModel]()
    var offset: Int = -40
    let limit: Int = 40
    
    func followServiceCall(strUrl: String,params:[String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset = offset + limit
        let url = strUrl + "&skip=\(offset)&limit=\(limit)"
        
        
        followApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setDataInModel(modelArray: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                Helper.hidePI()
                if error.code == 204{
                    if self.offset == 0 {
                        self.followModelArray.removeAll()
                    }
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    func setDataInModel(modelArray: [Any]){
        if offset == 0{
            self.followModelArray.removeAll()
        }
        for data in modelArray{
            guard let dict = data as? [String : Any] else{continue}
            let followModel = FollowModel(modelData: dict)
            self.followModelArray.append(followModel)
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
