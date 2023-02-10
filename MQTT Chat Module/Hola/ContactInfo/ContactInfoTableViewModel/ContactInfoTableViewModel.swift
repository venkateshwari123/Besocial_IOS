//
//  ContactInfoTableViewModel.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class ContactInfoTableViewModel: NSObject {

    let contactInfoApi = SocialAPI()
    var reportReasonArray = [String]()

    
    
    /// To get report reasons
    ///
    /// - Parameter complitation: complitation handler after getting response
    func getReportReasonsService(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let url: String = AppConstants.reportSpamUserAPI
        contactInfoApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String]{
                print(result)
                self.reportReasonArray = result
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }
    
    /// To report a post
    ///
    /// - Parameters:
    ///   - reasonIndex: reason of report
    ///   - postIndex: index of post in report reason array
    ///   - complitation: complitation handler to handle response
    func postReportReasonService(targetId: String, reasonIndex: Int, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let url: String = AppConstants.reportSpamUserAPI
        let reason = self.reportReasonArray[reasonIndex]
        
        let params = ["targetUserId" : targetId,
                      "reason": reason,
                      "message" : reason]
        
        contactInfoApi.postSocialData(with: url, params: params) { (response, error) in
            if let result = response{
                print(result)
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
        }
    }
}
