//
//  BusinessCategory.swift
//  Starchat
//
//  Created by Rahul Sharma on 27/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class BusinessCategoryViewModel: NSObject {
    
    //MARK:- Variables&Declarations
    let businessCategoryApi = SocialAPI()
    var businessCategoryArray = [BusinessCategoryModel]()
    var businessCategoryId :String?
    var businessCategoryName:String?
    
    
    /// To Get The Business Category lists
    ///
    /// - Parameter complitation: complitation handler after compliting service call
    func businessCategoryApiCall(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let urlStr = AppConstants.businessCategory
        businessCategoryApi.getSocialData(withURL: urlStr, params: [:]) { (response, error) in
            print(response)
            if let result = response as? [Any]{
                print(result)
                guard let dict = result as? [[String : Any]] else{
                    complitation(true, nil)
                    return
                }
                self.businessCategoryArray = dict.map{
                    BusinessCategoryModel(modelData: $0)
                }
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
            }
            Helper.hidePI()
        }
    }
}
