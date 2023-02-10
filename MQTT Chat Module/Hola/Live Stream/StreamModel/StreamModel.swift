//
//  StreamModel.swift
//  Live
//
//  Created by Vengababu Maparthi on 27/11/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import Foundation

class StreamModel {
    
    func goToLiveStreaming(param:BroadCastParams!,completionBlock:@escaping([String : Any]?) ->()) {
        
        let dict:[String:Any] = [ "id": param.id,
                                  "type":param.type,
                                  "streamName":param.streamName,
                                  "thumbnail":param.thumbnail,
                                  "userImage":Utility.getUserImage() ?? param.thumbnail,
                                  "record":param.record,//true can save the video
                                  "detection": false,
                                  "duration": 0
                                    ]
//        map.put("detection", false);
//        map.put("duration", 0);
        
        let streamApi = StreamingAPI()
        let url = AppConstants.PostStartStream
        streamApi.sereamPostServiceCall(withURL: url, params: dict) { (response, error) in
            if let result = response as? [String : Any]{
                if let streamData = result["data"] as? [String:Any], param.type == "start"{
                    UserDefaults.standard.set(streamData["streamId"] as! String, forKey: AppConstants.UserDefaults.streamID)

                    UserDefaults.standard.synchronize()
                    completionBlock(streamData)
                    if let streamID = streamData["streamId"] as? String {

                        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.subscribe + streamID, withDelivering: .exactlyOnce)
                        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.chat + streamID, withDelivering: .exactlyOnce)
                        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.like + streamID, withDelivering: .exactlyOnce)
                        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.gift + streamID, withDelivering: .exactlyOnce)
                    }
                }else{
                    completionBlock(nil)
                }
            }else{
                completionBlock(nil)
            }
        }
    }
    
    func subscribeToStream(type:String,streamID:String) {
        
        let dict:[String:Any] = [ "id": streamID,
                                  "action":type]
        
        let streamApi = StreamingAPI()
        let url = AppConstants.PostSubStream
        streamApi.sereamPutServiceCall(withURL: url, params: dict) { (response, error) in
            if error == nil{
                print(response)
            }
        }
    }
    
    func getSteramStats(streamID:String,completionBlock:@escaping([String : Any]?) ->()) {
        
        let dict:[String:Any] = [ "streamId": streamID ]
        
        let streamApi = StreamingAPI()
        let url = AppConstants.GetStreamStats
        streamApi.getStreamStats(withURL: url, params: dict) { (response, error) in
            if error == nil{
                if let result = response as? [String : Any]{
                 completionBlock(result)
                }
            }
        }
    }
    
    func endStream(streamID:String,completionBlock:@escaping([String : Any]?) ->()) {
        
        let dict:[String:Any] = [ "streamId": streamID ]
        
        let streamApi = StreamingAPI()
        let url = AppConstants.EndStream
        streamApi.endStream(withURL: url) { (response, error) in
            if error == nil{
                if let result = response as? [String : Any]{
                 completionBlock(result)
                }
            }
        }
    }
}


struct BroadCastParams {
    var id = ""
    var type = ""
    var streamName = ""
    var thumbnail = ""
    var record : Bool = false
    init(streamID:String,streamType:String,streamName:String,streamThumbnail:String,record : Bool = false) {
        self.id = streamID
        self.type = streamType
        self.streamName = streamName
        self.thumbnail = streamThumbnail
        self.record = record
    }
}

struct Viewers {
    
//    "_id" = 0;
//    active = 1;
//    following = 0;
//    started = 1572863116;
//    userImage = "https://s3.ap-south-1.amazonaws.com/dubly/profile_image/5db052d0e330e978e0d0ab31";
//    userName = Shaktisinh;
    
    var action = ""
    var id = ""
    var name = ""
    var firstName = ""
    var lastName = ""
    var image = ""
    var following: Int = 0
    
    init(dict : [String : Any]) {
//        if let action = dict["action"] as? String{
//            self.action = action
//        }
        if let streamid = dict["_id"] as? String{
            self.id = streamid
        }
//        if let streamName = dict["name"] as? String{
//            self.name = streamName
//        }
//        if let streamName = dict["streamName"] as? String{
//            self.name = streamName
//        }
        if let streamName = dict["userName"] as? String{
            self.name = streamName
        }
        if let fName = dict["firstName"] as? String{
            self.firstName = fName
        }
        if let lName = dict["lastName"] as? String{
            self.lastName = lName
        }
        if let streamName = dict["userImage"] as? String{
            self.image = streamName
        }
        if let follow = dict["following"] as? Int{
            self.following = follow
        }
    }
}
