//
//  CoinWalletViewModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 19/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
import StoreKit
class CoinWalletViewModel: NSObject {
    var limit:Int = 20
    var offSet:Int = -20
    var coinPlanModelArray = [CoinPlanModel]()
    
    func getCoinPlans(strUrl: String,complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        let api = SocialAPI()
        offSet = offSet + 20
        let url = strUrl + "?skip=\(offSet)&limit=\(limit)"
        api.getSocialDataForLan(withURL: url, params: nil) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if let result = response as? [String:Any]{
                print(result)
                if let data = result["data"] as? [[String:Any]] {
                    self.setCoinPlanModelData(response: data)
                    let canServiceCall: Bool = (result.count == self.limit) ? true : false
                    complitation(true, nil, canServiceCall)
                }
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
            Helper.hidePI()
        }
    }
    
    
    /// To set data in tagModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setCoinPlanModelData(response: [Any]){
        if self.offSet == 0{
            self.coinPlanModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let postModel = CoinPlanModel(modelData: modelData)
            self.coinPlanModelArray.append(postModel)
        }
    }
    
    
}
