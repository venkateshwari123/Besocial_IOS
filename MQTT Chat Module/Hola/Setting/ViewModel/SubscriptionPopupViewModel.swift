//
//  SubscriptionPopupViewModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
class SubscriptionPopupViewModel: NSObject {
    
    
    func postSubscriptionDetailsCall(params : [String:Any], complitation: @escaping(Bool, CustomErrorStruct?)-> Void) {
        Helper.showPI(string: " Updating... ")
        let url = AppConstants.subscription
    let api = SocialAPI()
        api.postSocialData(with: url, params: params) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            print(response)
            if response != nil {
                complitation(true,nil)
            }else{
                complitation(true,error)
            }
            
        }
    }
}
