//
//  File.swift
//  Yelo
//
//  Created by Rahul Sharma on 04/05/20.
//  Copyright © 2020 rahulSharma. All rights reserved.
//

import UIKit

/*
 {
   "business_type": "individual",
   "day": "01",
   "month": "09",
   "year": "2000",
   "url": "www.appscrip.com",
   "email": "rinkesh@mobifyi.com",
   "first_name": "rinkesh",
   "last_name": "kalathiya",
   "gender": "male",
   "id_number": "110000000",
   "phone": "7090350604",
   "ssn_last_4": "0000",
   "ip": "0.0.0.0",
   "document": "https://superadmin.shoppd.net/theme/icon/delivxlogoflexy.png"
 }*/

class StripeSignUpViewModel {
    
    var stripeSignUpModel = StripSignUpModel()
    
    func stripeSignUp(success: @escaping ()->Void){
        var params = [String: Any]()
        params["line1"] = stripeSignUpModel.address
        params["city"] = stripeSignUpModel.city
        params["state"] = stripeSignUpModel.state
        params["country"] = stripeSignUpModel.country
        params["postal_code"] = stripeSignUpModel.zipCode
        params["first_name"] = stripeSignUpModel.firstName
        params["last_name"] = stripeSignUpModel.lastName
        params["document"] = stripeSignUpModel.proofImage?.imgUrl ?? ""
        /*
         Bug Name:- Document id is missing in UI
         Fix Date:- 14/06/21
         Fix By  :- Jayaram G
         Description of Fix:- added document id field
         */
        params["id_number"] = stripeSignUpModel.documentId
        
        if let components = stripeSignUpModel.dateOfBirth?.get(.day, .month, .year), let day = components.day, let month = components.month, let year = components.year {
            print("day: \(day), month: \(month), year: \(year)")
             params["day"] = day
            params["month"] = month
            params["year"] = year
        }
        if let email = Utility.getUserEmail() as? String, email != ""{
            params["email"] = email
        }else{
            Helper.showAlert(head: "Email", message: "EmailId is missing , please update your email.")
            return
        }
        
        params["phone"] = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String
        params["ssn_last_4"] = stripeSignUpModel.ssn
        params["ip"] = UserDefaultConstants.getInstance().getIpAddress()
        
        params["url"] = "www.appscrip.com"
        params["business_type"] = "individual"
        params["gender"] = "male"
        Helper.showPI(string: "")
        ApiHelper.shared.stripeSignUp(params: params) { _ in
            Helper.hidePI()
            success()
        }
    }
    
}
