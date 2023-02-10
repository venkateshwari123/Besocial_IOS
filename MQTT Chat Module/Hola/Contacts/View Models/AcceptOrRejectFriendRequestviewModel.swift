//
//  AcceptOrRejectFriendRequestviewModel.swift
//  PicoAdda
//
//  Created by 3Embed on 02/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

class AcceptOrRejectFriendReauestViewModel {

    let acceptOrDeleteApi = SocialAPI()
    
    ///To accept or delete user request
    func acceptOrDeleteUserRequest(status: Int, targetId: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUrl = AppConstants.friendRequestResponse
        
        let params: [String : Any] = ["status":status,
                                      "targetUserId":targetId]
        acceptOrDeleteApi.postSocialData(with: strUrl, params: params) { (response, error) in
            if let result = response{
                print(result)
       NotificationCenter.default.post(name: NSNotification.Name("RefreshFriends"), object: nil)
 
                complitation(true, nil)
            }else{
                complitation(false, error)
            }
        }
    }
    
    //MARK:- Block user
    func blockUserApicall(receiverId: String,blockStatus:String,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
//        guard let reciverid = userProfileModel?.userId else {return}
//        let strBlock = (userProfileModel?.isBlocked)!  ? "unblock" : "block"
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.blockPersonAPI 
        let params = ["opponentId" : receiverId,
                      "type" : blockStatus]
        acceptOrDeleteApi.postSocialData(with: strURL, params: params) { (response, error) in
            //print("response: \(response!)")
            if error == nil{
                Helper.hidePI()
                complitation(true , error)
//                    Helper.showAlertViewOnWindow("Message", message: "User Blocked Successfully")
              //  self.userProfileModel?.isBlocked = !(self.userProfileModel?.isBlocked)!
               // self.UpdateBlockStatusInDatabase(isBlock: (self.userProfileModel?.isBlocked)!)
            }
            Helper.hidePI()
        }
    }
    
}
