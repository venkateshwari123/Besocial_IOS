//
//  BusinessContactInfoViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 27/05/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
import Locksmith
import Alamofire
class BusinessContactInfoViewModel: NSObject {
    
    //MARK:- VariablesAndDeclarations
    var businessCategoryId :String?
    var businessCategoryName:String?
    var businessName:String?
    var businessUserName:String?
    var businessEmail:String?
    var phoneNumber:String?
    var privateAccount:Int?
    var businessWebsite = ""
    var businessBio:String?
    var countryCode:String?
    var address:String?
    var businessStreetAddress:String?
    var businessCity:String = ""
    var businessState:String = ""
    var businessCountry:String = ""
    var businessZipCode:String?
    let businessAccountApi = SocialAPI()
    var isPhoneNumberVisible:Bool?
    var isPhoneNumberVisibleInt:Double?
    var isEmailVisibleInt:Double?
    var businessLat:Float = 0.0
    var businessLang:Float = 0.0
    var profileImageURL : String?
    var coverImageURL : String?
    var BusinessContactTextViewCellDic = [Int:BusinessContactTextViewCell]()
    var BusinessContactInfoTextCellDic = [Int:BusinessContactInfoTextCell]()
    
    /// Checking All Requirement Fields and after verifying all checkings setting complitation as true
    ///
    /// - Parameter complitation: complitation handler after compliting service call
    func checkingAllRequiredFields(complitation: @escaping(Bool)->Void){
        
        /*
         Bug Name:- business profile not submitted
         Fix Date:- 14/05/21
         Fixed By:- Nikunj C
         Description of Fix:- enter required validation
         */
        
        if businessUserName == nil || businessUserName == "" {
            self.BusinessContactTextViewCellDic[0]?.errorLabel.text = Strings.pleaseEnterBusinessUserName.localized
            self.BusinessContactTextViewCellDic[0]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactTextViewCellDic[0]?.errorLabel.isHidden = false
            self.BusinessContactTextViewCellDic[0]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessName == nil || businessName == "" {
            self.BusinessContactTextViewCellDic[1]?.errorLabel.text = Strings.pleaseEnterBusinessName.localized
            self.BusinessContactTextViewCellDic[1]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactTextViewCellDic[1]?.errorLabel.isHidden = false
            self.BusinessContactTextViewCellDic[1]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if !Helper.isValidEmail(emailText: businessEmail ?? "") {
            if businessEmail == nil || businessEmail == "" {
                self.BusinessContactInfoTextCellDic[2]?.errorLabel.text = "Please enter business email"
            }else{
                self.BusinessContactInfoTextCellDic[2]?.errorLabel.text = Strings.pleaseEnterValidEmail.localized
            }
            self.BusinessContactInfoTextCellDic[2]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[2]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[2]?.heightConstraint?.constant = 92
            complitation(false)
       
        }else if !Helper.isValidNumber("\(countryCode ?? "")\(phoneNumber ?? "")") {
            if phoneNumber == nil || phoneNumber == ""{
                self.BusinessContactInfoTextCellDic[3]?.errorLabel.text = "Please enter business phone number"
            }else{
                self.BusinessContactInfoTextCellDic[3]?.errorLabel.text = Strings.pleaseEnterValidEmail.localized
            }
            self.BusinessContactInfoTextCellDic[3]?.errorLabel.text = Strings.pleaseEnterValidPhoneNumber.localized
            self.BusinessContactInfoTextCellDic[3]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[3]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[3]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if countryCode == nil || countryCode == ""{
            self.BusinessContactInfoTextCellDic[3]?.errorLabel.text = Strings.pleaseSelectCountryCode.localized
            self.BusinessContactInfoTextCellDic[3]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[3]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[3]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessCategoryId == nil || businessCategoryId == "" {
            self.BusinessContactInfoTextCellDic[4]?.errorLabel.text = Strings.pleaseSelectBusinessCategory.localized
            self.BusinessContactInfoTextCellDic[4]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[4]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[4]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessStreetAddress == nil || businessStreetAddress == ""{
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.text = Strings.pleaseChooseStreet.localized
            self.BusinessContactInfoTextCellDic[5]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[5]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessCity == nil || businessCity == ""{
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.text = Strings.pleaseChooseCity.localized
            self.BusinessContactInfoTextCellDic[5]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[5]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessZipCode == nil || businessZipCode == ""{
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.text = Strings.pleaseChooseZipCode.localized
            self.BusinessContactInfoTextCellDic[5]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[5]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[5]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if businessCategoryId == nil || businessCategoryId == ""{
            self.BusinessContactInfoTextCellDic[4]?.errorLabel.text = Strings.pleaseSelectBusinessCategory.localized
            self.BusinessContactInfoTextCellDic[4]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[4]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[4]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if self.privateAccount == 1{
            Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.profileNeedsToBePublic.localized)
        }
        else if  !Helper.isValidWebsite(websiteText: businessWebsite ){
            self.BusinessContactTextViewCellDic[6]?.errorLabel.text = Strings.PleaseEnterValidWebsite.localized
            self.BusinessContactTextViewCellDic[6]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactTextViewCellDic[6]?.errorLabel.isHidden = false
            self.BusinessContactTextViewCellDic[6]?.heightConstraint?.constant = 92
            complitation(false)
        }
        else if self.businessBio == "" {
            self.BusinessContactInfoTextCellDic[7]?.errorLabel.text = Strings.pleaseEnterBusinessBio.localized
            self.BusinessContactInfoTextCellDic[7]?.errorLabelHeightConstraint.constant = 21
            self.BusinessContactInfoTextCellDic[7]?.errorLabel.isHidden = false
            self.BusinessContactInfoTextCellDic[7]?.heightConstraint?.constant = 92
            complitation(false)

        }
        else if businessUserName != nil {
            self.validateUserName(userName: businessUserName ?? "") { (success, error) in
                if success{
                    self.BusinessContactTextViewCellDic[0]?.errorLabel.text = "Entered username already exists."
                    self.BusinessContactTextViewCellDic[0]?.errorLabelHeightConstraint.constant = 21
                    self.BusinessContactTextViewCellDic[0]?.errorLabel.isHidden = false
                    self.BusinessContactTextViewCellDic[0]?.heightConstraint?.constant = 92
                    complitation(false)
                }else{
                    self.BusinessContactTextViewCellDic[0]?.errorLabelHeightConstraint.constant = 0
                    self.BusinessContactTextViewCellDic[0]?.errorLabel.isHidden = true
                    self.BusinessContactTextViewCellDic[0]?.heightConstraint?.constant = 78
                    complitation(true)
                }
                
            }
        }
        else {
            complitation(true)
        }
    }
    
    /// Requesting for business Account Api Call
    ///
    /// - Parameters:
    ///   - strUrl: businessRequest string url
    ///   - complitation: complitation handler after compliting service call
    func businessAccountApiCall(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        if profileImageURL == nil {
            profileImageURL = ""
        }
        if coverImageURL == nil {
            coverImageURL = ""
        }
        let params = ["businessUsername":self.businessUserName! as Any,
                      "businessName":self.businessName! as Any,
                      "email":self.businessEmail! as Any,
                      "phone":self.phoneNumber! as Any,
                      "businessCategoryId": self.businessCategoryId! as Any,
                      "countryCode" : countryCode! as Any,
                      "isPhoneVisable": isPhoneNumberVisible! as Any,
                      "businessStreet": "\(businessStreetAddress ?? "")," as Any,
                      "businessCity": businessCity as Any,
                      "isPhoneNumberVerified": 1,
                      "isVisibleEmail":self.isEmailVisibleInt ?? 0.0,
                      "isVisiblePhone":self.isPhoneNumberVisibleInt ?? 0.0,
                      "isEmailVerified":1,
                      "businessZipCode": businessZipCode! as Any,
                      "address": "\(businessStreetAddress ?? ""),\(businessCity ?? ""),\(self.businessState),\(self.businessCountry),\(businessZipCode ?? "")",
                      "businessLat": "\(self.businessLat)",
                      "businessLng": "\(self.businessLang)",
                      "businessBio" : self.businessBio! as Any,
                      "websiteURL" : self.businessWebsite ,
                      "businessProfilePic" : profileImageURL ?? "" as Any,
                      "businessProfileCoverImage" : coverImageURL ?? "" as Any ] as [String : Any]
        
        print(params)
        self.businessAccountApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
            if let result = response {
                complitation(true, error)
             }else if let error = error{
                print(error.localizedDescription)
//                Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                complitation(false, error)
             }
        }
    }
    
    func updatePrivatePublicAccount(){
        let params = ["private": privateAccount
            ] as [String : Any]
        UpdateProfileApi.updateUserProfile(params: params) { (dict) in
            Helper.hidePI()
         }
     }
    
    /*
     Feat Name:- check exist phone, email, username
     Feat Date:- 12/04/21
     Feat By:- Nikunj C
     Description of Feat:- call required api
     */
    
    func  validateEmailPhone(strUrl: String,params:[String:Any], complitation: @escaping(String,Bool, CustomErrorStruct?)->Void){
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        print(token)
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        print("headers : \(headers)")
        let apiCall = RxAlmofireClass()
         apiCall.newtworkRequestAPIcall(serviceName: strUrl, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
         _ = apiCall.subject_response.subscribe(onNext: {dict in
            
            print("output here \(dict)")
            complitation(dict["message"] as! String,true,nil)
            
        }, onError: {error in
            complitation("",false,error as? CustomErrorStruct)
        })
    }
    
    
    func validateUserName(userName: String,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let url = AppConstants.isExistUserName + "?userName=\(userName)"
        var basicAuth: String = "\(AppConstants.BasicAuth.userName):\(AppConstants.BasicAuth.passWord)"
        basicAuth = Helper.encodeStringTo64(basicAuth) ?? ""
        basicAuth = "Basic \(basicAuth)"
        let headers = ["Authorization": "\(basicAuth)"]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .get, parameters: nil ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        _ = apiCall.subject_response.subscribe(onNext: {dict in
            
            print("output here \(dict)")
            complitation(true,nil)
            
        }, onError: {error in
            complitation(false,error as? CustomErrorStruct)
        })
        
    }
}





