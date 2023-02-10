//
//  APIStatusCode.swift
//  Yelo
//
//  Created by 3Embed on 09/08/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import Foundation
// MARK: - API Status code
class APIStatusCode {
    enum ErrorCode: Int {
        case success                = 200
        case created                = 201
        case deleted                = 202 //Accepted forgotPW
        case updated                = 203
        case NoUser                 = 204
        case badRequest             = 400
        case Unauthorized           = 401
        case Required               = 402
        case Forbidden              = 403
        case NotFound               = 404
        case MethodNotAllowed       = 405
        case NotAcceptable          = 406
        case UserExisting           = 409
        
        case ExpiredOtp             = 410
        case IncorrectInfo          = 411
        case Incorrect              = 422
       
        case PreconditionFailed     = 412
        case RequestEntityTooLarge  = 413
        case TooManyAttemt          = 429
        case ExpiredToken           = 440
        case InvalidToken           = 498
        case InternalServerError    = 500
        case InternalServerError2   = 502
        case storeBanned   = 415
        case serverI65ssue           = 501
    }
    
    
    // MARK:-
    
    
    class func basicParsing(data:[String:Any],status: Int) {
//        Helper.hidePI()
        let errNum = ErrorCode(rawValue: status)!
        switch errNum {
        case .success:
            Helper.showAlert(head: "Success".localized, message: data[APIResponseParams.getInstance().Message] as! String )
            break
//        case .ExpiredToken,.InvalidToken,.NoUser:
//            Logout.logout()
//            break
            
        case .NotFound:
            
            Helper.showAlert(head: "Error".localized, message: data[APIResponseParams.getInstance().Message] as! String )
            break
//
//        case .deleted:
//            Helper.showAlert(message: data[APIResponseParams.getInstance().Message] as! String, head: StringConstants.Error(), type: 0)
//            break
//
        case .Required:
            Helper.showAlert(head: "Success".localized, message: data[APIResponseParams.getInstance().Message] as! String )
            break
        default:
            var message = ""
            if let msg = data["message"] as? String {
                message = msg
            }
            print(message)
            Helper.showAlert(head: "Error".localized, message: message )
            break
        }
    }
}
