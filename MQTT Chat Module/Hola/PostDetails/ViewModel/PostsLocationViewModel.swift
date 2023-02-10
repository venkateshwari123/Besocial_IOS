//
//  PostsLocationViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 08/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class PostsLocationViewModel: NSObject {

    let PostedByApi = SocialAPI()
    let limit: Int = 20
    var offset: Int = -20
    var postedByArray = [SocialModel]()
    
    
    /// To get service response
    ///
    /// - Parameters:
    ///   - strURL: URL to call service
    ///   - complited: callback on success or fail
    func getPostedByService(place: String, complited: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = self.offset + 20
        let location = place.replace(target: " ", withString: "%20")
        let strUrl = AppConstants.postsByPlace + "?place=\(place)&offset=\(offset)&limit=\(limit)"
        //let params = ["place": place]
        Helper.showPI()
        PostedByApi.getSocialData(withURL: strUrl, params: [:]) { (modelArray, customError) in
            if let modelData = modelArray as? [Any]{
                self.createModelArray(dataArray: modelData)
                let canServiceCall: Bool = (modelData.count == self.limit) ? true : false
                complited(true, nil, canServiceCall)
            }
            if let error = customError{
                if error.code == 204{
                    complited(true, error, false)
                }else{
                    complited(true, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    func createModelArray(dataArray: [Any]){
        if offset == 0{
            postedByArray.removeAll()
        }
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let socialData = SocialModel(modelData: data)
                postedByArray.append(socialData)
            }
        }
    }
}
