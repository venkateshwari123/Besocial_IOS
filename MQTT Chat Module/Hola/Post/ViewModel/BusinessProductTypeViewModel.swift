//
//  BusinessProductTypeViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 09/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class BusinessProductTypeViewModel {
    let productTypeListApi = SocialAPI()
    var offset: Int = -20
    let limit: Int = 20
    
    var productTypeListArray = [BusinessProductTypeListModel]()
    
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getProductTypeList(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
        Helper.showPI()
        let url = strUrl + "?skip=\(offset)&limit=\(limit)"
        productTypeListApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            print(response)
            if let result = response as? [Any]{
                print(result)
                self.setDataInProductTypeListModel(modeldataArray: result)
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
    private func setDataInProductTypeListModel(modeldataArray: [Any]){
        if offset == 0{
            self.productTypeListArray.removeAll()
        }
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let productListModel = BusinessProductTypeListModel(modelData: data)
            self.productTypeListArray.append(productListModel)
        }
    }
}
