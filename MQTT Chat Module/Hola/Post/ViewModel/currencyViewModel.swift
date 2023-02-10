//
//  currencyViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 06/09/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
class  currencyViewModel {
    let currencyListApi = SocialAPI()
    var offset: Int = -20
    var limit: Int = 20

    var currencyListArray = [CurrencyModel]()
    var coinAmountsListArray = [Int]()
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getCurrencyList(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        self.offset = offset +  20
        self.limit = 20
        Helper.showPI()
        let url = strUrl + "?skip=\(offset)&limit=\(limit)"
        currencyListApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            print(response)
            if let result = response as? [Any]{
                print(result)
            self.setDataInCurrencyListModel(modeldataArray: result)
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
    private func setDataInCurrencyListModel(modeldataArray: [Any]){
        if offset == 0{
            self.currencyListArray.removeAll()
        }
        for modelData in modeldataArray{
            guard let data = modelData as? [String : Any] else{return}
            let currentListModel = CurrencyModel(modelData: data)
            self.currencyListArray.append(currentListModel)
        }
    }
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getCoinsList(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        currencyListApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            print(response)
            if let result = response as? [Int]{
                print(result)
                self.coinAmountsListArray = result
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
    
    
    
    func postSendingTipCall(params : [String:Any], complitation: @escaping(Bool, CustomErrorStruct?)-> Void) {
        Helper.showPI(string: " Updating... ")
        let url = AppConstants.tipAmount
    let api = SocialAPI()
        api.postSocialDataForIan(with: url, params: params) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            print(response)
            if response != nil {
                complitation(true,nil)
            }else{
                complitation(false,error)
            }
            
        }
    }
    
}
