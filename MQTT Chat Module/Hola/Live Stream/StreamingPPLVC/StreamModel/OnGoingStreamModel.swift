//
//  StreamModel.swift
//  Live
//
//  Created by Vengababu Maparthi on 28/11/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import Foundation
//import SVProgressHUD

class ONStreamModel {
    var streamData = [StreamData]()
    
    func getTheOnLineStreamPPL(completionBlock:@escaping([StreamData]) ->()) {
        streamData = [StreamData]()
        let param: [String : Any] = ["offset" : 0,
                                     "limit" : 20
        ]
        let streamApi = StreamingAPI()
        let url = AppConstants.GetStreamData+"?offset=\(0)&limit=\(20)"
        streamApi.streamGetServiceCall(withURL: url, param: nil) { (response, error) in
            if let result = response as? [String : Any],  let streamArr = result["streams"] as? [Any]{
                if let streams = streamArr as? [[String:Any]]{
                    self.streamData  = streams.map{
                        StreamData.init(data: $0)
                    }
                    completionBlock(self.streamData)
                }
            }else{
                Helper.hidePI()
            }
        }
    }
    
    func starUserLiveStreaming(_ streamStatus : String, completionBlock:@escaping([String : Any]) ->()) {
        guard let streamId = Utility.getStreamId() else{return}
        let params : [String : Any] = [
            "streamStatus":streamStatus,
            "streamName":Utility.getUserName(),
            "streamId":streamId,
            "userId":Utility.getUserid()!,
        ]

        let streamApi = StreamingAPI()
        let url = AppConstants.stream
        streamApi.sereamPostServiceCall(withURL: url, params: params) { (response, error) in
            if let result = response as? [String : Any]{
                completionBlock(result)
            }else{
                
            }
        }
    }
    
    func getWalletBalanceService(){
        let params = [String : Any]()
        let url = AppConstants.walletBalance
        
        let streamApi = StreamingAPI()
        streamApi.walletGetServiceCall(withURL: url, param: params) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
                if let balance = result["balance"] as? Double{
                    UserDefaults.standard.set(balance, forKey: AppConstants.UserDefaults.walletBalance)
                }else{
                   UserDefaults.standard.set(0.0, forKey: AppConstants.UserDefaults.walletBalance)
                }
            }
        }
    }
    
    
    func followAndUnFollowUserService(index: Int,completionBlock: @escaping(Bool)->Void){
        var data = self.streamData[index]
        var isSelected: Bool = false
        if data.following == 0{
            isSelected = true
            data.following = 1
        }else{
            data.following = 0
        }
        self.streamData[index] = data
        let peopleId = data.userID
        ContactAPI.followAndUnfollowService(with: isSelected, followingId: peopleId, privicy: 0)
    }
    
    func followAndUnFollowUserServiceEnd(streamUser: StreamData,completionBlock: @escaping(Bool)->Void){
        var data = streamUser
        var isSelected: Bool = false
        if data.following == 0{
            isSelected = true
            data.following = 1
        }else{
            data.following = 0
        }
//        self.streamData[index] = data
        let peopleId = data.userID
        ContactAPI.followAndUnfollowService(with: isSelected, followingId: peopleId, privicy: 0)
        completionBlock(true)
    }
}

struct StreamData {
    
    
//    {
//    action = start;
//    allViewers = 0;
//    following = 1;
//    id = 5dc14d75fb82c5090e77681b;
//    name = 5da9652fe4c9a36404bbf9081572949358990;
//    started = 1572949365;
//    thumbnail = "https://s3.ap-south-1.amazonaws.com/dubly/profile_image/5da9652fe4c9a36404bbf908";
//    uniqueViewers = 0;
//    userId = 5da9652fe4c9a36404bbf908;
//    userImage = "https://s3.ap-south-1.amazonaws.com/dubly/profile_image/5da9652fe4c9a36404bbf908";
//    userName = dipen;
//    viewers = 0;
//    }
    
    var userImage = ""
    var userName = ""
    var userID = ""
    var started:Int64 = 0
    var streamName = ""
    var streamID = ""
    var viewers = "0"
    var thumbnail = ""
    var following: Int = 0
    
    init(data:[String:Any]) {
        
        if let id = data["id"] as? String{
            self.streamID = id
        }
        
        if let thumb = data["thumbnail"] as? String{
            self.thumbnail = thumb
        }
        
        if let name = data["userName"] as? String{
            self.userName = name
        }
        
        if let userImage = data["userImage"] as? String{
            self.userImage = userImage
        }
        
        if let userID = data["userId"] as? String{
            self.userID = userID
        }
        
        if let name = data["name"] as? String{
            self.streamName = name
        }
        
        if let started = data["started"] as? NSNumber{
            self.started = Int64(truncating: started)
        }
        
        if let viewers = data["viewers"] as? NSNumber
        {
            self.viewers = "\(viewers)"
        }
        if let follow = data["following"] as? Int{
            self.following = follow
        }
    }
}
