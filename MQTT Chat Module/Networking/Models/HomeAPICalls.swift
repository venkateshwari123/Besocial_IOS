

//
// HomeAPICalls.swift
// UFly
//
// Created by 3Embed on 16/11/17.
// Copyright © 2017 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire

struct DataResult {
    let data:Data
    let error:APICalls.ErrorCode?
}

enum Response{
    case success
    case error(APICalls.ErrorCode)
    case errorInDataParsing
}

class HomeAPICalls: NSObject{
    let subject_response_ecom = PublishSubject<DataResult>()
    func requestData(url:String ,params:[String:Any]? = nil,header: [String:String], method: Alamofire.HTTPMethod  ,deletePatch:Bool = false){
        guard let urlName = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return
        }
        
        
        let manager = Alamofire.Session.default
        manager.request(urlName, method: method, parameters: params , encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseJSON { (response) in
            
            switch response.result{
                
            case let .success(value):
                
                var statuscode:Int = 200
                if let res = response.response{
                    statuscode = res.statusCode
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: .fragmentsAllowed) as? [String : Any]
                    print("json == > ", json)
                } catch {
                    print(error.localizedDescription)
                }
                guard let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: statuscode) as? APICalls.ErrorCode else {
                    return
                }
                if errNum == .success {
                    self.subject_response_ecom.onNext(DataResult(data: response.data!, error: nil))
                }
                else{
                    Helper.hidePI()
                   self.subject_response_ecom.onNext(DataResult(data: Data(), error: nil))
                }
                
            case let .failure(error):
                
                self.subject_response_ecom.onError(error)
                if error.localizedDescription != AppConstants.noInternetMsg {
                    //  Helper.showAlertViewOnWindow(serviceName, message: error.localizedDescription)
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    static let disposeBag = DisposeBag()
    
    class func requestData(url:String,params:[String:Any] = [:],header:[String:String] = [:],method:HTTPMethod,deletePatch:Bool = false)-> Observable<DataResult>{
        /*let pinEvaluator = PinnedCertificatesTrustEvaluator(certificates: Bundle.main.af.certificates,
         acceptSelfSignedCertificates: true,
         performDefaultValidation: true,
         validateHost: true)
         let disableEvaluator = DisabledEvaluator()
         
         let trustManager = ServerTrustManager.init(evaluators:
         [
         "api.shoppd.net": disableEvaluator
         ])
         
         let sessionManager = Session.init(configuration: .default, serverTrustManager: trustManager)*/
        
     
        
//        let header = HTTPHeaders.init(from: header)
//
//        let disableEvaluator =  ServerTrustPolicy.disableEvaluation
//
//        let serverTrustPolicies = ServerTrustPolicyManager.init(policies:
//            [
//                "api.tistsocial.com": disableEvaluator,
//                "ghost.dubly.xyz":disableEvaluator
//        ])
        //        ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [
        //            "api.shoppd.net":disableEvaluator,
        //            "ghost.shoppd.net":disableEvaluator
        //        ])
        //"api.shoppd.net": disableEvaluator
        
//        let delegate = SessionDelegate.init()
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 30
        // configuration.httpAdditionalHeaders = Session.default
//        let sessionManager = SessionManager.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicies)
        
        //        if !AppConstants.Reachable {
        //            Helper.hidePI()
        //            Helper.showNoInternet()
        //            return Observable.create{ observer in
        //                observer.onError(APICalls.ErrorCode(rawValue: 403)!)
        //                return Disposables.create()
        //            }.share(replay: 1)
        //        }
        //        let configuration = URLSessionConfiguration.default
        //        configuration.timeoutIntervalForResource = 5
        switch method {
        case .post,.patch:
            return Observable.create { observer in
              
                let manager = Alamofire.Session.default
                
                manager.rx.request(method, url, parameters: params, encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseData().debug().subscribe(onNext: { (head, data) in
                    let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
                    if errNum == .success {
                        // print(data)
                        observer.onNext(DataResult(data: data, error: nil))
                        // observer.onCompleted()
                    }else{
                        observer.onNext(DataResult(data: data, error: APICalls.ErrorCode(rawValue: head.statusCode)!))
                    }
                    observer.onCompleted()
                }, onError: { (Error) in
                    Helper.hidePI()
                    observer.onError(Error)
                }).disposed(by: self.disposeBag)
                return Disposables.create()
                
            }.share(replay:1)
        default:
            if deletePatch{
                return Observable.create { observer in
                    let manager = Alamofire.Session.default
                    manager.rx.request(method, url, parameters: params.isEmpty ? nil : params, encoding: JSONEncoding.default, headers: HTTPHeaders.init(header)).responseData().debug().subscribe(onNext: { (head, data) in
                        let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
                        if errNum == .success {
                            // print(data)
                            observer.onNext(DataResult(data: data, error: nil))
                            // observer.onCompleted()
                        }else{
                            // APICalls.basicParsing(data:body as! [String : Any],status:head.statusCode)
                            observer.onNext(DataResult(data: data, error: APICalls.ErrorCode(rawValue: head.statusCode)!))
                        }
                        observer.onCompleted()
                    }, onError: { (Error) in
                        Helper.hidePI()
                        observer.onError(Error)
                    }).disposed(by: self.disposeBag)
                    return Disposables.create()
                    
                }.share(replay:1)
            }else{
                return Observable.create { observer in
                    let manager = Alamofire.Session.default
                    manager.rx.request(method, url, parameters: params.isEmpty ? nil : params, headers: HTTPHeaders.init(header)).responseData().debug().subscribe(onNext: { (head, data) in
                        let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
                        if errNum == .success {
                            // print(data)
                            observer.onNext(DataResult(data: data, error: nil))
                            observer.onCompleted()
                        }else{
                            // APICalls.basicParsing(data:body as! [String : Any],status:head.statusCode)
                            observer.onNext(DataResult(data: data, error: APICalls.ErrorCode(rawValue: head.statusCode)!))
                        }
                    }, onError: { (Error) in
                        Helper.hidePI()
                        observer.onError(Error)
                    }).disposed(by: self.disposeBag)
                    return Disposables.create()
                    
                }.share(replay:1)
            }
        }
        
        
        
    }
}

class APICalls: NSObject {
    static let disposesBag = DisposeBag()
    enum ErrorCode: Int,Error {
        case success                = 200
        case created                = 201
        case deleted                = 202 //Accepted forgotPW //Accepted for delete item in Laundry
        case updated                = 203
        case NoUser                 = 204
        case badRequest             = 400
        case Unauthorized           = 401
        case Required               = 402
        case Forbidden              = 403
        case NotFound               = 404
        case MethodNotAllowed       = 405
        case NotAcceptable          = 406
        case Banned1                = 408
        case alreadyVerified        = 411
        case Banned                 = 415
        case ExpiredOtp             = 410
        case PreconditionFailed     = 412
        case RequestEntityTooLarge  = 413
        case TooManyAttemt          = 429
        case ExpiredToken           = 440
        case accountDeleted         = 416
        case InvalidToken           = 498
        case InternalServerError    = 500
        case InternalServerError2   = 502
        case InternalServerError3   = 420
        case InvalidParameters      = 422
        case InternalServerError4   = 504
    }
    static let LogoutInfoTo = PublishSubject<Bool>()
    //Refresh Token
    //    class func refreshToken() {
    //        if !AppConstants.Reachable {
    //            Helper.showNoInternet()
    //            return
    //        }
    //        let header = Utility.getHeader()
    //        RxAlamofire.requestJSON(.get, APIEndTails.RefreshToken, parameters: [:], headers: HTTPHeaders.init(header)).debug().subscribe(onNext: { (head, body) in
    //            Helper.hidePI()
    //            let bodyIn = body as! [String:Any]
    //            let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
    //            if errNum == .success {
    //                let newToken = bodyIn[APIResponceParams.Data] as! String
    //                Utility.saveSession(token: newToken)
    //            }else{
    //                APICalls.basicParsing(data:bodyIn,status:head.statusCode)
    //            }
    //        }, onError: { (Error) in
    //            Helper.hidePI()
    //        }).disposed(by: self.disposesBag)
    //    }
    //
    
    
    //    class func configure() ->Observable<Bool> {
    //        let header = Utility.getHeaderWithoutAuth()
    //        return Observable.create { observer in
    //            RxAlamofire.requestJSON(.get, APIEndTails.Configure, parameters: [:], headers: HTTPHeaders.init(header)).debug().subscribe(onNext: { (head, body) in
    //                let bodyIn = body as! [String:Any]
    //                let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
    //                if errNum == .success {
    //                    let data = bodyIn[APIResponceParams.Data] as! [String:Any]
    //                    Utility.setAppConfig(data: data)
    //                }
    //                observer.onNext(true)
    //                observer.onCompleted()
    //            }, onError: { (Error) in
    //                Helper.hidePI()
    //                observer.onNext(false)
    //                observer.onCompleted()
    //            }).disposed(by: self.disposesBag)
    //            return Disposables.create()
    //            }.share(replay: 1)
    //    }
    
    
    
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    
    class func basicParsing(data:[String:Any],status: Int) {
        let dataIn = Helper.nullKeyRemoval(data: data)
        Helper.hidePI()
        let errNum = ErrorCode(rawValue: status)!
        var message = ""
        if let msg = dataIn["message"] as? String {
            message = msg
        }
        switch errNum {
        case .success,.created,.deleted,.updated:
            Helper.showAlert(head: "Success", message: message)
            break
        case .ExpiredToken:
            
            if let temp = dataIn["data"] as? String {
                //  Utility.saveSession(token: temp)
                // APICalls.refreshToken()
            }else {
                //   Utility.logout(type:1,message: message)
            }
            break
        case .InvalidToken,.NoUser,.Banned,.Banned1:
            //  Utility.logout(type:1,message: message)
            break
        case .NotFound:
            break
        default:
            Helper.showAlert(head: "Error", message: message)
            break
        }
    }
    
    
    //    //1 - place , 2 - direction , 3 - distance , 4 - others
    //    class func keyRotationImpression(type:keyRotationType) {
    //        let header = Utility.getHeaderWithoutAuth()
    //
    //        let params = ["count":1,
    //                      "currentKey":GoogleKeys.GoogleMapKey,
    //                      "type" :type.rawValue ] as [String:Any]
    //         RxAlamofire.requestJSON(.post, APIEndTails.KeyRotation, parameters: params, headers: HTTPHeaders.init(header)).debug().subscribe(onNext: { (head, body) in
    //                let errNum:APICalls.ErrorCode? = APICalls.ErrorCode(rawValue: head.statusCode)!
    //                if errNum == .success {
    //                 print("Success")
    //                }
    //
    //            }, onError: { (Error) in
    //
    //            }).disposed(by: self.disposesBag)
    //    }
    
    
    
    enum keyRotationType:Int {
        case place  = 1
        case direction = 2
        case distance  = 3
        case others = 4
    }
    
    
}
