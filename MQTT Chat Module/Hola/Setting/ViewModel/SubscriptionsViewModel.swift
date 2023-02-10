//
//  SubscriptionsViewModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
class SubscriptionsViewModel: NSObject {
    let transactionApi = SocialAPI()
    var activeSubscribersListArray = [SubscribersListModel]()
    var cancelledSubscribersListArray = [SubscribersListModel]()
    var offset1: Int = -20
    var offset2: Int = -20
    let limit: Int = 50
    
    
    //For Credit Transactions
    func getActiveSubscribersList(strUrl: String,params:[String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset1 = offset1 + 20
        let url = strUrl + "&skip=\(offset1)&limit=\(limit)"
        transactionApi.getSocialData(withURL: url, params: params) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if let result = response as? [Any]{
                print(result)
                self.setActiveSubscriberModelData(modelData: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
                
            }else if let data = response as? [String:Any]{
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
            Helper.hidePI()
            
        }
    }
    
    func setActiveSubscriberModelData(modelData: [Any]){
        if offset1 == 0 {
            self.activeSubscribersListArray.removeAll()
        }
        for data in modelData{
            guard let dict = data as? [String : Any] else{continue}
            let activeData = SubscribersListModel(modelData: dict)
            self.activeSubscribersListArray.append(activeData)
        }
    }
    
    
    //For Debit Transaction List
    func getCancelledSubscribersList(strUrl: String,params:[String:Any] ,complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        offset2 = offset2 + 20
        let url = strUrl + "&skip=\(offset2)&limit=\(limit)"
        transactionApi.getSocialData(withURL: url, params: params) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if let result = response as? [Any]{
                print(result)
                self.setCancelledModelData(modelData: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
                
            }else if let data = response as? [String:Any]{
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
            Helper.hidePI()
            
        }
    }
    
    func setCancelledModelData(modelData: [Any]){
        if offset2 == 0 {
            self.cancelledSubscribersListArray.removeAll()
        }
        for data in modelData{
            guard let dict = data as? [String : Any] else{continue}
            let cancelledData = SubscribersListModel(modelData: dict)
            self.cancelledSubscribersListArray.append(cancelledData)
        }
    }
}
