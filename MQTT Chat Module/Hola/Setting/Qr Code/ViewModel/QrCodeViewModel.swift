
//
//  QrCodeViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 21/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
class QrCodeViewModel: NSObject {
    
    //MARK:- Variables&Declarations
    let qrCodeApi = SocialAPI()
    var qrCodeString:String?
    //  var qrCodeModel:QrCodeModel?
    
    /// Get The QrCode
    ///
    /// - Parameters:
    ///   - strUrl: qrCode string url
    ///   - complitation: complitation handler after compliting service call
    func getQrCode(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        qrCodeApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? String{
                self.qrCodeString = result
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
}
