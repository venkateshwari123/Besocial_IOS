//
//  BusinessButtonsListViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 10/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class BusinessButtonsListViewModel: NSObject {
    let businessButtonsListApi = SocialAPI()
    
    var busiessButtonListArray = [BusinessButtonModel]()
    
    
    func getBusinessButtonList(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        businessButtonsListApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? [[String : Any]]{
//                self.busiessButtonListArray = result
                self.setButtonListModelArrayFromResponse(response: result)
                 complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                if error.code == 204{
                    complitation(false, error)
                }else{
                    complitation(false, error)
                }
            }
            Helper.hidePI()
        }
    }
 
    
    /// To set data in busiessButtonListArray from service response data
    ///
    /// - Parameter response: service response data
    func setButtonListModelArrayFromResponse(response: [[String : Any]]){
        self.busiessButtonListArray = response.map({ (data) -> BusinessButtonModel in
            BusinessButtonModel(modelData: data)
        })
    }
}
