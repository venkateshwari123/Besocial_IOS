//
//  RequestStarCategoryViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/8/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class RequestStarCategoryViewModel: NSObject{
    
    //MARK:- Variables&Declarations
    let requestStarCategoryApi = SocialAPI() // Used To Get the referance of the SocialAPI Object
    var requestStarCategoryModelArray = [RequestStarCategoryModel]() // Used To Store the Array Of RequestStarCategoryModel Object
    var offset: Int = -20    // Used to Set the OffSet Value in API Call  Parameter
    let limit: Int = 20      // Used to Set the limit Value in API Call  Parameter
    
    
    
    /// Requesting to Get The Category List
    ///
    /// - Parameter complitation: complitation handler after compliting service call
    func requestCategoryApiCall(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        let urlStr = AppConstants.starCategory
        requestStarCategoryApi.getSocialData(withURL: urlStr, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                guard let dict = result as? [[String : Any]] else{
                    complitation(true, nil)
                    return
                }
                //            self.setCategoryModelData(modelData: result)
                self.requestStarCategoryModelArray = dict.map{
                    RequestStarCategoryModel(modelData: $0)
                }
                //            let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
            }
            Helper.hidePI()
            
        }
    }
    
    //    func loadingDataToCell(_ Index:Int) -> [String:Any]{
    //        return requestStarCategoryModelArray[Index]
    //    }
    
    //    func setCategoryModelData(modelData: [Any]){
    //        for data in modelData{
    //            guard let dict = data as? [String : Any] else{continue}
    //            let categoryModel = RequestStarCategoryModel(modelData: dict)
    //            self.requestStarCategoryModelArray.append(categoryModel)
    //        }
    //    }
}
