//
//  FriendRequestViewModel.swift
//  PicoAdda
//
//  Created by 3Embed on 23/10/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class FriendRequestViewModel: NSObject {
    let friendRequestListApi = SocialAPI()
    var offset: Int = -20
    let limit: Int = 1000
    var friendRequestModelObj:friendRequestModel?
    
    
    func getFriendRequestList(strUrl: String,searchText: String ,complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
//        Helper.showPI()
        var url:String = ""
        if searchText == ""  {
            url = strUrl + "?skip=\(offset)&limit=\(limit)"
        }else {
            url = strUrl + "?searchText=\(searchText)&skip=\(offset)&limit=\(limit)"
        }
       
        friendRequestListApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String:Any]{
           //     self.friendRequestModelObj = result
             self.friendRequestModelObj =  friendRequestModel(modelData: result)
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                self.offset = self.offset - 20
                if error.code == 204{
                     
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
}
