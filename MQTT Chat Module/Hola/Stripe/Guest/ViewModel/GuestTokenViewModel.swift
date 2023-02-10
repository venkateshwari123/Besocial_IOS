//
//  GuestTokenViewModel.swift
//  Do Chat
//
//  Created by Rahul Sharma on 04/01/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import CocoaLumberjack
class GuestTokenViewModel: NSObject {
    
    func getGuestTokenApiCall(complitation: @escaping(Bool)->Void){
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
        let modelNumber = UIDevice.modelName
        let api = SocialAPI()
        let params = ["countryName" : UserDefaultConstants.getInstance().getCountry() as Any,
                      "IpAddress" : UserDefaultConstants.getInstance().getIpAddress() as Any,
                      "deviceId" : deviceID as Any,
                      "deviceName" : deviceName as Any,
                      "deviceOs" : deviceOs as Any,
                      "modelNumber" : modelNumber as Any,
                      "deviceType" : "1" as Any,
                      "appVersion" : appVersion as Any]
        api.postSocialData(with: AppConstants.guestToken, params: params) { (response, error) in
            if let responseData = response as? [String:Any] {
                if let data = responseData["data"] as? [String:Any] {
                    guard let accessToken = data["accessToken"] as? String else {return}
                    if let refreshToken = data["refreshToken"] as? String {
                        UserDefaults.standard.set(refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
                    }
                    do{
                        try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                        do{
                            try Locksmith.saveData(data: ["token":accessToken], forUserAccount: AppConstants.keyChainAccount)
                            complitation(true)
                        }catch let error {
                            print(error)
                            complitation(false)
                            DDLogDebug("error handel it")
                        }
                    }
                    catch{
                        do{
                            try Locksmith.saveData(data: ["token":accessToken], forUserAccount: AppConstants.keyChainAccount)
                            complitation(true)
                        }catch let error {
                            print(error)
                            complitation(false)
                            DDLogDebug("error handel it")
                        }
                    }
                }
            }
            
        }
    }
}
