//
//  LoginViewModel.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 24/08/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire

enum ValidationType : Int{
    case email = 0
    case phonenumber
    case username
}


class LoginViewModel: NSObject {
    
    private let api: LoginAPI
    
    //MARK: - Events
    var didError: ((CustomErrorStruct) -> Void)?
    var didUpdate: ((LoginViewModel) -> Void)?
    var didUpdateAny : (([String : Any]) -> Void)?
    var didUpdateUser : ((User) -> Void)?
    
    var mobileNumber:String = ""
    var passWord:String = ""
    var message:String = ""
    var dataaa:String = ""

    private var login : Login!
    
    var username : String? {
        return login.name
    }
    
    var userID : String? {
        return login.iD
    }
    
    var userImageUrl : URL? {
        guard let url = login.userImageURL else { return nil }
        return URL(string:url)
    }
    
    init(api:LoginAPI) {
        self.api = api
    }
    
    /// Will interact with the controller and pass the related data to Modal
    ///
    /// - Parameters:
    ///   - emailID: current users email ID
    ///   - password: users provided password
    ///   - callback:
    ///   - loginVMObject : Will return the LoginViewModel Object
    ///   - error : Will return the error Object with error data.
    
    func fetchLoginData(withuserName userName : String, andPassword password: String, andnumber number: String,andcountryCode countryCode : String,countryName:String) {
         self.api.loginUser(withuserName: userName, andPassword: password, andnumber: number, andcountryCode: countryCode, countryName: countryName) { (objUser, error) in
            if let loginObj = objUser {
                if let didUpdate = self.didUpdateUser {
                    didUpdate(loginObj)
                  //  self.createMQTTConnection()
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                    
                }
            }
        }
    }
    
//    func createMQTTConnection() {
//        let mqttModel = MQTT.sharedInstance
//        mqttModel.createConnection()
//        //        self.subscribeAllMQTTTopics()
//    }
    
    func validateNextBtn() -> Bool{
        if self.mobileNumber.count != 0 && self.passWord.count != 0{
            return true
        }else {
            return false
        }
    }
    func validateNextBtnForMobile() -> Bool{
        if self.mobileNumber.count != 0 {
            return true
        }else {
            return false
        }
    }
    
    
    
    
    func requestOtp(withType type : Int, andnumber number : String, andcountryCode countryCode : String) {
        
        self.api.requestOTP(withType: type, andnumber: number, andcountryCode: countryCode) { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
  
    // is isValidmobileNumberOtp
    func isValidmobileNumberOtp(number : String, andcountryCode countryCode : String) {
     
        self.api.checkingMobileNumberOTP(number: number, andcountryCode: countryCode) { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    
    
    
    
    func requestOtpEmail(withType type : Int, andUserEmailId userEmailId : String){
        self.api.requestOTPinEmail(withType: type, andUserEmailId: userEmailId) { (response, error) in
            if let objResponse = response {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(objResponse)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
            
        }
    }
    
    func verifyOtp(withType type : Int, andnumber number : String, andcountryCode countryCode : String, andotp otp : String) {
        self.api.verifyOtp(withType: type, andnumber: number, andcountryCode: countryCode, andotp: otp) { (userObj, error) in
            if let loginObj = userObj {
                if let didUpdate = self.didUpdateUser {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    
    
    func getLoginViewModalObject(fromLoginObj loginObj : Login) -> LoginViewModel{
        let loginVMObject = LoginViewModel(api: self.api)
        loginVMObject.login = loginObj
        return loginVMObject
    }
    
    func verifyOTPCode(otpId:String,otpCode:String,type:ForgotPasswordOptions, handler :@escaping (Bool,String?)->()){
        
        let param = [
            "email": otpId,
            "otp": Int(otpCode)!] as [String : Any]
        
        let strURL =  "\(AppConstants.baseUrl)/verifyOTPByEmail"
        
        /*
         Bug Name:- not able to reset email password
         Fix Date:- 26th May 2021
         Fixed By:- Nikunj C
         Description of Fix:- use basicAuth token instead of bearer token
         */
        
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        let headers = ["Authorization": "\(basicAuth)"]
        APIManager.requestService(url: strURL,params: param, header: headers, method: .post, showLoader : true) { (response) in
            if let error = response.error, error == .success {
                do{
                    let verifyData = try JSONDecoder().decode(VerifyOtp.self, from: response.data)
                    handler(true,verifyData.data.accessToken)
                }catch{
                    handler(true,nil)
                }
            } else {
                handler(false,nil)
            }
        } failure: { (error) in
            print(error.localizedDescription)
        }
    }
    
    func isValidEmailOtp(mail:String,userName:String,number : String, andcountryCode countryCode : String) {
        
        self.api.checkingEmailOTP(mail: mail, userName: userName, number: number, andcountryCode: countryCode, withCallback: { (objLogin, error) in
            if let loginObj = objLogin {
                if let didUpdate = self.didUpdateAny {
                    didUpdate(loginObj)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        })
    }
    
    func validateRegisteration(type:ValidationType,emailAddress:String? = nil ,number : String? = nil,dialCode:String? = nil,userName:String? = nil, callback:@escaping (Bool,String?, _ errorCode : Int?) -> Void) {
        var strURL = ""
        var headers = [String:String]()
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        headers = ["Authorization": "\(basicAuth)"]
        
        switch type {
        case .email:
            guard let emailId = emailAddress else{
                return
            }
            strURL =  "isExists/emailId?emailId=\(emailId)"
        case .phonenumber :
            guard let phone = number , let code = dialCode else{
                return
            }
            strURL =   "isRegisteredNumber?countryCode=\(code)&phoneNumber=\(phone)"
        default:
            guard let user = userName else{
                return
            }
            strURL =   "isExists/userName?userName=\(user)"
            
            
        }
        let apicall = RxAlmofireClass()
        apicall.newtworkRequestAPIcall(serviceName: strURL, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        _ = apicall.subject_response.subscribe(onNext: {response in
            callback(true,nil, nil)
        }, onError: {error in
            if let errorCode = error as? CustomErrorStruct {
                print(errorCode.code)
                callback(false,nil, errorCode.code)
            }else{
                callback(false,nil, nil)
            }
            
        })
    }
    
    
    func checkSocialLogin(id:String,type:SocialLogin, handler :@escaping (Bool)->()){

        var param = Helper.getDeviceDetailsParams()
        switch type {
        case .Facebook:
            param["facebookId"] = id
        case .Google:
            param["googleId"] = id
        case .Apple:
            param["appleId"] = id
        }
        let strURL =   "\(AppConstants.baseUrl)/login/social"
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"

              //  let headers = ["authorization":token,"lang": "en"]
        let headers = ["Authorization": "\(basicAuth)"]
        APIManager.requestService(url: strURL,params: param, header: headers, method: .post,showLoader: true) { (data) in
            if let error = data.error, error == .NoUser{
                handler(false)
            }else if let error = data.error, error == .success {
                do{
                    let user =  try JSONDecoder().decode(UserResult.self, from: data.data)
                    Utility.setIsGuestUser(status: false)
                    Route.setRootController()
                }catch {
                    print(error)
                }
            }
        } failure: { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func forgotPassword(password:String,email:String? = nil,mobile:String? = nil, dialCode :String? = nil,type:ForgotPasswordOptions, handler :@escaping (Bool,String?)->()){
        
        var param = Helper.getDeviceDetailsParams()
        switch type {
        case .Email:
            param["email"] = email ?? ""
            param["password"] = password
        case .Phone:
            param["countryCode"] = dialCode ?? ""
            param["mobile"] = mobile ?? ""
            
            
        }
        param["verifyType"] = type.rawValue
        let strURL =  "\(AppConstants.constantURL)newPassword"
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        
        let headers = ["Authorization": "\(basicAuth)"]
        APIManager.requestService(url: strURL,params: param, header: headers, method: .post, showLoader : true) { (response) in
            if  let error = response.error, error == .success {
                do{
                    let phoneloginData = try JSONDecoder().decode(PhoneLogin.self, from: response.data)
                    handler(true,phoneloginData.data.otpId)
                }catch{
                    handler(true,"")
                }
            } else {
                handler(false,nil)
            }
        } failure: { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    func resetPassword(tokenId:String,newPassword:String,handler :@escaping (Bool,String?)->()){
        
        let param = [
            "newPassword": newPassword,
            "resetType": 1] as [String : Any] //1-forgot password 2-change password,3-check old password
        
        let strURL =  "\(AppConstants.constantURL)resetPassword"
        var headers =  Helper.getDefaultHeader()
        headers["authorization"] = tokenId
        APIManager.requestService(url: strURL,params: param, header: headers, method: .post, showLoader : true) { (data) in
            if let error = data.error, error == .success {
                handler(true,"")
            } else {
                handler(false,nil)
            }
        } failure: { (error) in
            print(error.localizedDescription)
        }
    }
    
    /*
    Bug Name : Update forgot password flow
    Fix Date : 14-May-2021
    Fixed By : Jayaram G
    Description Of Fix : Added new api call for forgot password
  */
    func sendForgotPasswordLink(email:String? = nil,mobile:String? = nil, dialCode :String? = nil,type: Int, handler :@escaping (Bool,String?)->()){
  //      var basicAuth = ""
        var param = [String:Any]()

        if type == 1 {
            param["email"] = email ?? ""
            param["verifyType"] = type
        }else {
            param["countryCode"] = dialCode ?? ""
            param["mobile"] = mobile ?? ""

        }
        let strURL =  "\(AppConstants.constantURL)forgotPassword"
//        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
//        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
//        basicAuth = "Basic \(basicAuth)"
        var basicAuth = ""
        if let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) {
            if let token = keyDict["token"] {
                basicAuth = "\(token)"
            }
        }
        let headers = ["lang":Utility.getSelectedLanguegeCode(),"authorization": "\(basicAuth)"]
        
//        APIManager.requestService(url: strURL,params: param, header: headers, method: .post, showLoader : true) { (response) in
//            if  let error = response.error, error == .success {
//                do{
//                    let phoneloginData = try JSONDecoder().decode(PhoneLogin.self, from: response.data)
//                    handler(true,phoneloginData.data.otpId)
//                }catch{
//                    handler(true,"")
//                }
//            } else {
//                handler(false,nil)
//            }
//        } failure: { (error) in
//            print(error.localizedDescription)
//        }
        
        
        
        // declare the parameter as a dictionary that contains string as key and value combination. considering inputs are valid


          // create the url with URL
          let url = URL(string: strURL)! // change server url accordingly

          // create the session object
          let session = URLSession.shared

          // now create the URLRequest object using the url object
          var request = URLRequest(url: url)
          request.httpMethod = "POST" //set http method as POST

          // add headers for the request
          request.headers = HTTPHeaders.init(headers)
          request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
          request.addValue("application/json", forHTTPHeaderField: "Accept")

          do {
            // convert parameters to Data and assign dictionary to httpBody of request
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
          } catch let error {
            print(error.localizedDescription)
            return
          }

          // create dataTask using the session object to send data to the server
          let task = session.dataTask(with: request) { data, response, error in

              if let error = error {
              print("Post Request Error: \(error.localizedDescription)")
              return
            }

            // ensure there is valid response code returned from this HTTP response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
              print("Invalid Response received from the server")
              return
            }

            // ensure there is data returned
            guard let responseData = data else {
              print("nil Data received from the server")
              return
            }

            do {
              // create json object from data or use JSONDecoder to convert to Model stuct
              if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                print(jsonResponse)
                  
                  if let message = jsonResponse["message"] as? String {
             //     self.message = message
                      handler(true,message)
                  }
                  if let dataaa = jsonResponse["data"] as? String {
                      self.dataaa = dataaa
                  }
                  
                // handle json response
              } else {
                print("data maybe corrupted or in wrong format")
                throw URLError(.badServerResponse)
              }
            } catch let error {
              print(error.localizedDescription)
            }
          }
          // perform the task
          task.resume()
    }
    
    
}




import UIKit
import Alamofire

class APIManager: NSObject {
    
    class func requestService(url:String ,params:[String:Any]? = nil,header: [String:String], method: Alamofire.HTTPMethod ,showLoader:Bool = false,success:@escaping (DataResult) -> Void, failure:@escaping (Error) -> Void){
        guard let urlName = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        if showLoader{
            Helper.showPI()
        }
        
        
        let manager = Alamofire.Session.default
        manager.request(urlName, method: method, parameters: params, headers: HTTPHeaders.init(header)).responseJSON {  (response) in
            
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                }
                print("status code => ", statuscode )
                let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: statuscode)!
                if errNum == .success {
                    success(DataResult(data: response.data!, error: errNum))
                }
                else{
                   
                    success(DataResult(data: Data(), error: errNum))
                }
                Helper.hidePI()
                
            case let .failure(error):
                
                Helper.hidePI()
                let error : Error = error
                if let statusCode = response.response?.statusCode{
                    print("ERROR STATUS CODE - \(statusCode)")
                }
                failure(error)
            }
            
        }
    }
    
    class  func networkService(url:String ,params:[String:Any]? = nil,header: [String:String], method: Alamofire.HTTPMethod ,showLoader:Bool = false,success:@escaping (DataResult) -> Void, failure:@escaping (Error) -> Void){
        guard let urlName = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        if showLoader{
            Helper.showPI()
        }
        print("url  =>  ", urlName)
        let manager = Alamofire.Session.default
        manager.request(urlName, method: method, parameters: params , encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseJSON { (response) in
            print("url  =>  ", urlName)
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                }
                let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: statuscode)
                if  statuscode != 406, statuscode != 401, errNum == .success{
                    success(DataResult(data: response.data!, error: errNum))
                }else if statuscode == 406{
                    APIManager.refreshTokenAPI(){ (success,token) in
                        if success{
                            var  header = header
                            header.updateValue(token, forKey: "authorization")
                            
                            self.requestService(url: url, params: params, header: header, method: method) { _ in
                                
                            } failure: { _ in
                                
                            }
                        }
                        else{
                            Utility.logOut()
                        }
                    }
                    
                }else if  statuscode == 401{
                    Utility.logOut()
                }
                
                /*
                 Bug Name:- Profile page>>edit profile>> We are able to change the password by entering the incorrect password.
                 Fix Date:- 31st Aug 2021
                 Fixed By:- Nikunj C
                 Description of Fix:- for same current and new password manage status code 409
                 */
                
                else if statuscode == 409{
                    let error: Error =  NSError(domain: "", code: 409, userInfo: [ NSLocalizedDescriptionKey: "Your new password cannot be the same as your current password".localized + "."])
                    failure(error)
                }
                
                else if let responseData =  response.data{
                    success(DataResult(data:responseData , error: errNum))
                }
                
            case let .failure(error):
                
                let error : Error = error
                if let statusCode = response.response?.statusCode{
                    print("ERROR STATUS CODE - \(statusCode)")
                }
                failure(error)
            }
            
        }
    }
    
    class  func refreshTokenAPI(closure:@escaping (Bool,String)->()) {
        guard  let refreshToken = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.refreshToken) as? String else {return}
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode(),"refreshtoken": refreshToken]
        let strURL = "\(AppConstants.baseUrl)/\(AppConstants.refreshUserToken)"
        let manager = Alamofire.Session.default
        manager.request(strURL, method: .get, parameters: nil, headers: HTTPHeaders.init(headers)).responseJSON{ (response) in
            
            switch response.result{
                case let .success(value):
                
                var statuscode:Int = 200
                
                if let res = response.response{
                    statuscode = res.statusCode
                }
                if  let dict  = value as? [String:Any],statuscode == 200{
                    guard let responseDict = dict["data"] as? [String : Any] else {return}
                    do{
                        try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                    }
                    catch{
                        
                        closure(false,"")
                    }
                    
                    guard let token = responseDict["accessToken"] as? String else {return}
                    do{
                        try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
                        closure(true,token)
                    }catch{
                        
                        closure(false,"")
                    }
                }else{
                    
                    Utility.logOut()
                }
                
            case let .failure(error):
                
                let error : Error = error
                if let statusCode = response.response?.statusCode{
                    print("ERROR STATUS CODE - \(statusCode)")
                }
                closure(false,error.localizedDescription)
            }
        }
        
    }
    
    class func getErrorMessage(data : Data) -> String?{
        do{
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let errorMessage = dictionary["message"] as? String {
              return errorMessage
              }
        }catch{
            
        }
        return nil
    }
}

class LanguageChooseViewModel: NSObject{
    
    var langArr = [Languages]()
    
    func getLanguages(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let str = "https://api.besocial.app/languageAPI/?status=1"
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        let headers = ["Authorization": "\(basicAuth)"]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: str, requestType: .get, parameters: nil, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                
                guard let dataArray = dict["result"] as? [Any] else {return}
                self.createModelArray(dataArray: dataArray)
                complitation(true,nil)
            }, onError: {error in
                complitation(false, error as? CustomErrorStruct)
                Helper.hidePI()
            })

    }
    
    func createModelArray(dataArray: [Any]){
        for modelData in dataArray{
            if let data = modelData as? [String : Any]{
                let langData = Languages(modelData: data)
                langArr.append(langData)
            }
        }
    }
    
    func chooseLanguage(name:String,code:String){
        let str = AppConstants.chooseLanguage
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["name":name,"code":code]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: str, requestType: .patch, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.loginApi.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                
            }, onError: {error in
                Helper.hidePI()
            })

    }
}
