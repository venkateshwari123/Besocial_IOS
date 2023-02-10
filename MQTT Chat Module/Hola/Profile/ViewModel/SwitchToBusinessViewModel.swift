//
//  SwitchToBusinessViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 28/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class SwitchToBusinessViewModel {
    
    
    let businessProfileDetails = SocialAPI()
    var switchToBusinessViewModelArray = [SwitchToBusinessModel]()
    
    func getBusinessDeatails(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        businessProfileDetails.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                 self.setBusinessListModel(modeldataArray: result)
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
        }
    }
    
    /// To set data  model array
    ///
    /// - Parameter modeldataArray: model data array to set in model
    private func setBusinessListModel(modeldataArray: [Any]){
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let businessModel = SwitchToBusinessModel(modelData: data)
            self.switchToBusinessViewModelArray.append(businessModel)
        }
    }
}
