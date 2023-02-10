//
//  VoipViewModel.swift
//  Do Chat
//
//  Created by Rahul Sharma on 22/03/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
class VoipViewModel: NSObject {
    
    
    /// register device to voip onesignal
    ///
    /// - Parameters:
    ///   - strUrl: verifyOTPByEmail url String
    ///   - complitation: complitation handler after compliting service call
    func registerDeviceToVoip(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        let api = SocialAPI()
        var semaphore = DispatchSemaphore (value: 0)
        let url = "https://onesignal.com/api/v1/players"
        guard  let callpush = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.callPushToken) as? String else {return}
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
        let modelNumber = UIDevice.modelName
//        let params = ["app_id": AppConstants.oneSignalAppID,
//                      "device_type" : 0,
//                      "identifier":callpush,
//                      "test_type": 1,
//                      "language": "en",
//                      "timezone":-28800,
//                      "game_version":appVersion,
//                      "device_model": modelNumber,
//                      "device_os":deviceOs,
//                      "sdk":"onesignal"]
//            api.postSocialForVoip(with: url, params: params as [String : Any]) { (response, error) in
//                print(response as Any)
//                if let result = response{
//                    complitation(true, error)
//                }else if let error = error{
//                    print(error.localizedDescription)
//                    Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
//                    complitation(false, error)
//                }
//            }
        let parameters = "{\r\n\"device_type\": 0, \"test_type\": 1, \"language\": \"en\", \"timezone\": -28800, \"device_os\": \"13.5.1\", \"app_id\": \"5ff473ea-92b3-43a7-9a9b-a2750178ef61\", \"device_model\": \"iPhone X\", \"game_version\": \"1.0.15\", \"identifier\": \"0CE8C5F65F47195C7E989D158F3788446FA876890DA9CAD779999AD305038AC4\"\r\n\r\n}"

        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://onesignal.com/api/v1/players")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("__cfduid=d3c996552a2819e9bdb81564f56e6a3b51616420153", forHTTPHeaderField: "Cookie")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    
    

    
}


