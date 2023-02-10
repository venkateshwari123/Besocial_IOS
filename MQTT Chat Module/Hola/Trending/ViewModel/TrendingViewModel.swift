//
//  TrendingViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 06/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class TrendingViewModel: NSObject {
    
    let trendingApi = TrendingAPI()
    var categoryModelArray = [CategoryModel]()
    var trendingModelArray = [TrendingPostModel]()
    
    var socialModelObj:SocialModel?
    var hashTagArray = [String]()
    var trendingOffset: Int = -20
    let limit: Int = 20
    
    var categorySetValue = 0
    
    
    ////Get category service call
    func getCategorys(complitation: @escaping(Bool, CustomErrorStruct?,Bool)->Void){
        let strUrl = AppConstants.getCategory + "?set=\(categorySetValue)&limit=40"
        trendingApi.getCategoryData(withURL: strUrl) { (response, error)  in
            if let result = response as? [Any]{
                print(result)
                var canServiceCall: Bool = false
                 self.setDataInCategoryModelArray(dataArray: result)
                 canServiceCall = (result.count == self.limit) ? true : false
                complitation(true, nil,canServiceCall)
            }
            if let error = error{
                complitation(false, error,false)
            }
        }
    }
    ///setting data in category model array
    func setDataInCategoryModelArray(dataArray: [Any]){
        self.categoryModelArray.removeAll()
        for data in dataArray{
            guard let dict = data as? [String : Any] else {continue}
            let categoryModel = CategoryModel(modelData: dict)
            if categoryModel.categoryName != "Live" {
            self.categoryModelArray.append(categoryModel)
            }
            
        }
    }
    ///post service call for trending
    func getTrending(categorymodel: CategoryModel, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        trendingOffset = trendingOffset + limit
        guard let categoryId = categorymodel.categoryId else {
            Helper.hidePI()
            return
        }
        var strUrl = AppConstants.trending + "?set=\(self.trendingOffset)&limit=\(self.limit)&categoryId=\(categoryId)"
        if let name = categorymodel.categoryName, name == "Star"{
            strUrl = AppConstants.trending + "?set=\(self.trendingOffset)&limit=\(self.limit)&categoryId=\(categoryId)&isStar=1"
        }
        
        trendingApi.postTrendingData(with: strUrl) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
//                if let  _ = result["detail"] as? String{
//                    self.trendingOffset = self.trendingOffset - 20
//                    self.getTrending(categorymodel: categorymodel, complitation: { (success, error, canServiceCall) in
//                        if let result = response as? [String : Any]{
//                            print(result)
//                            if let tagsArray = result["hashTags"] as? [String]{
//                                self.hashTagArray = tagsArray
//                            }
//                            var canServiceCall: Bool = false
//                            if let dataArray = result["data"] as? [Any]{
//                                self.setTrendingDataInModel(dataArray: dataArray)
//                                canServiceCall = (dataArray.count == self.limit) ? true : false
//                            }
//                            complitation(true, nil, canServiceCall)
//                        }else{
//                            complitation(false, error, false)
//                        }
//                        Helper.hidePI()
//                    })
//                }
                if let tagsArray = result["hashTags"] as? [String]{
                    self.hashTagArray = tagsArray
                }
                 var canServiceCall: Bool = false
                if let dataArray = result["data"] as? [Any]{
                    self.setTrendingDataInModel(dataArray: dataArray)
                    canServiceCall = (dataArray.count == self.limit) ? true : false
                }
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.trendingOffset == 0{
                        self.hashTagArray.removeAll()
                        self.trendingModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    ///post service call for trending
    func getRecomendedTrending(complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        trendingOffset = trendingOffset + limit
         let strUrl = AppConstants.trending + "?set=\(trendingOffset)&limit=\(self.limit)"
           trendingApi.postTrendingDataForExplorePage(with: strUrl) { (response, error) in
            if let result = response as? [String : Any]{
                print(result)
                if let tagsArray = result["hashTags"] as? [String]{
                    self.hashTagArray = tagsArray
                }
                var canServiceCall: Bool = false
                if let dataArray = result["data"] as? [Any]{
                    self.setTrendingDataInModel(dataArray: dataArray)
                    canServiceCall = (dataArray.count == self.limit) ? true : false
                }
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                if error.code == 204{
                    if self.trendingOffset == 0{
                        self.hashTagArray.removeAll()
                        self.trendingModelArray.removeAll()
                    }
                    complitation(true, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
            Helper.hidePI()
        }
    }
    
    
    ///set data in trending array
    func setTrendingDataInModel(dataArray: [Any]){
        if self.trendingOffset == 0{
            self.trendingModelArray.removeAll()
        }
        for data in dataArray{
            guard let dict = data as? [String : Any] else {continue}
            let trendingModel = TrendingPostModel(modelData: dict)
            self.trendingModelArray.append(trendingModel)
        }
    }
}
