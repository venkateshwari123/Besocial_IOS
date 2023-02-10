//
//  CategoryListViewModel.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 14/12/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class CategoryListViewModel: NSObject {

    let categoryListApi = SocialAPI()
    var offset: Int = -20
    let limit: Int = 20
    
    var categoryListArray = [CategoryListModel]()
    
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getCategorys(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
        Helper.showPI()
        let url = strUrl + "?skip=\(offset)&limit=\(limit)"
        categoryListApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                self.setDataInCategoryListModel(modeldataArray: result)
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                self.offset = self.offset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    /// To set data in category list model array
    ///
    /// - Parameter modeldataArray: model data array to set in model
    private func setDataInCategoryListModel(modeldataArray: [Any]){
        if offset == 0{
            self.categoryListArray.removeAll()
        }
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let categoryListModel = CategoryListModel(modelData: data)
            self.categoryListArray.append(categoryListModel)
        }
    }
}
