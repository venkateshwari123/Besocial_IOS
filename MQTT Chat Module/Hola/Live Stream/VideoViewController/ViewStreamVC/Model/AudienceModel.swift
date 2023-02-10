//
//  AudienceModel.swift
//  Live
//
//  Created by Vengababu Maparthi on 18/02/19.
//  Copyright © 2019 io.ltebean. All rights reserved.
//

import Foundation

class AudienceModel {
    
    var categories = [Categories]()
    let categoryListApi = SocialAPI()
    var offset: Int = -20
    let limit: Int = 20
    var categoryListArray = [GiftCategoryModel]()
    var giftsListArray = [GiftsModel]()
    
    
    func getTheGiftsData(completionBlock:@escaping([Categories]) ->()) {
        categories = [Categories]()

        let param: [String : Any] = ["offset" : 0,
                                     "limit" : 20
        ]
        let stramApi = StreamingAPI()
        let url = AppConstants.GetGifts
        stramApi.streamGetServiceCall(withURL: url, param: nil) { (response, error) in
            if let result = response as? [[String : Any]]
            {
                self.categories  = result.map{
                    Categories.init(data: $0)
                }
                completionBlock(self.categories)
            }else{
                completionBlock(self.categories)
            }
        }
    }
    
    func giftTransferApiCall(strUrl: String, params: [String:Any],complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let api = SocialAPI()
        api.postSocialDataForIan(with: strUrl, params: params) { (response, error) in
            print("response: \(response)")
            if error == nil{
                Helper.hidePI()
                complitation(true , error)

            }
            Helper.hidePI()
        }
    }
    

    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getCategorys(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
        Helper.showPI()
        let url = strUrl + "?skip=\(offset)&limit=\(limit)"
        categoryListApi.getSocialDataForLan(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String:Any]{
                if let categories = result["data"] as? [Any] {
                    self.setDataInCategoryListModel(modeldataArray: categories)
                }
                
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
            let categoryListModel = GiftCategoryModel(modelData: data)
            self.categoryListArray.append(categoryListModel)
        }
    }
    
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getGifts(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset + 20
        let url = strUrl + "&skip=\(offset)&limit=\(limit)"
        categoryListApi.getSocialDataForLan(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [String:Any]{
                if let categories = result["data"] as? [Any] {
                    self.setDataInGiftsListModel(modeldataArray: categories)
                }
                
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
        }
    }
    
    
    
    /// To set data in category list model array
    ///
    /// - Parameter modeldataArray: model data array to set in model
    private func setDataInGiftsListModel(modeldataArray: [Any]){
        if offset == 0{
            self.giftsListArray.removeAll()
        }
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let giftListModel = GiftsModel(modelData: data)
            self.giftsListArray.append(giftListModel)
        }
    }
    
}

struct Categories {
    var giftData = [GiftsData]()
    var id = ""
    var name = ""
    
    init(data:[String:Any]) {
        if let name = data["name"] as? String{
            self.name = name
        }
        
        if let id = data["_id"] as? String{
            self.id = id
        }
        
        if let gifts = data["gifts"] as? [[String:Any]]{
            self.giftData = gifts.map {
               GiftsData.init(data: $0)
            }
        }
    }
}

struct GiftsData {
    var id = ""
    var name = ""
    var image = ""
    var coins = 0
    var gifs = ""
    
    
    init(data:[String:Any]) {
        
        if let id = data["id"] as? String{
            self.id = id
        }
        if let id = data["_id"] as? String{
            self.id = id
        }
        
        
        if let name = data["name"] as? String{
            self.name = name
        }
        
        if let image = data["image"] as? String{
            self.image = image
        }
        
        
        if let coin = data["coin"] as? String, let coinValue = Int(coin){
            self.coins = coinValue
        }
        
        if let coin = data["coin"] as? Double, let coinValue = Int(coin) as? Int{
            self.coins = coinValue
        }
        
        if let gif = data["gif"] as? String{
            self.gifs = gif
        }
    }
}
