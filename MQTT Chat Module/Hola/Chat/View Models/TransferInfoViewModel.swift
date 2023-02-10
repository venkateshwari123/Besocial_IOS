//
//  TransferInfoViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 12/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class TransferInfoViewModel: NSObject {
    
   let transferInfoApi = SocialAPI()
    var transferInfoModel: TransferInfoModel?
    
    
    /// Transfer details service call
    ///
    /// - Parameters:
    ///   - strUrl: string url of service call
    ///   - complication: complication handler after getting resposne
    func getTransactionDetailsService(strUrl: String,params: [String:Any], complication: @escaping(Bool, CustomErrorStruct?)-> Void){
        
        transferInfoApi.getSocialData(withURL: strUrl, params: params) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
                    self.transferInfoModel = TransferInfoModel(data: result)
                complication(true, nil)
            }else if let err = error{
                print(err.localizedDescription)
                complication(false, err)
            }
        }
    }

}
