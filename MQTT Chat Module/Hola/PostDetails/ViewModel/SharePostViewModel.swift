//
//  SharePostViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 26/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class SharePostViewModel: NSObject {

    let sharePostApi = SocialAPI()
    var followersFolloweeModelArray = [FollowersFolloweeModel]()
    var searchFolloweeModelArray = [FollowersFolloweeModel]()
    let couchbase = Couchbase.sharedInstance
    var isSearchActive: Bool = false
    var searchString: String = ""
    var offset: Int = -20
    let limit: Int = 100
    
    /// To get follow user list stored in database
    ///
    /// - Returns: list of following user
    func getFollowUserListFromDatabase() -> Bool{
        let followUserList = Utility.getFollowListFromDatabase(couchbase: couchbase)
        self.followersFolloweeModelArray = followUserList.map({
            FollowersFolloweeModel(modelData: $0 as! [String : Any])
        })
        return self.followersFolloweeModelArray.count >= 20 ? true : false
    }
    
    func getFollowAndFollowesService(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = self.offset + 20
        let url = strUrl + "skip=\(offset)&limit=\(limit)"
        sharePostApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setDataInModel(modelArray: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.offset == 0{
                        self.followersFolloweeModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
                    //                    print(error.localizedDescription)
                    complitation(false, error, true)
                }
            }
         }
    }
    
    func setDataInModel(modelArray: [Any]){
        if self.offset == 0{
            self.followersFolloweeModelArray.removeAll()
        }
        for data in modelArray{
            guard let dict = data as? [String : Any] else{continue}
            let followModel = FollowersFolloweeModel(modelData: dict)
            self.followersFolloweeModelArray.append(followModel)
        }
//        if self.isSearchActive{
//            self.getArrayForSearchedString()
//        }
    }
    
    func getArrayForSearchedString(searchText: String){
        searchFolloweeModelArray =  self.followersFolloweeModelArray.filter{ String(describing: $0.userName).contains(searchText, options: .caseInsensitive) || String(describing: $0.firstName).contains(searchText, options: .caseInsensitive)}
        
    }
}
