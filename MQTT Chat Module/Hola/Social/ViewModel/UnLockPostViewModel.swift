//
//  UnLockPostViewModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 05/11/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
class UnLockPostViewModel: NSObject {
    
    let api = SocialAPI()
    
    
    /// Verifying Email Otp
    ///
    /// - Parameters:
    ///   - strUrl: bussinessEmailOptVerify string url
    ///   - complitation: complitation handler after compliting service call
    func buyPost(strUrl: String,postId:String,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let params = ["postId": postId]
        self.api.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                print(response as Any)
                if let result = response{
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.trendingUpdate)
                    complitation(true, error)
                }else if let error = error{
                    print(error.localizedDescription)
                    complitation(false, error)
                }
            }
    }
}
