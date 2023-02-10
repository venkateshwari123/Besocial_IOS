//
//  RequestStarProfileViewModel.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/7/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import Foundation
import RxSwift

class RequestStarProfileViewModel: NSObject {
    
    
    //MARK:- Variables&Declarations
    let profileUsersApi = SocialAPI()  // Used To Get the Reference of the SocialAPI Object For Profile
    let api = LoginAPI()
    var didUpdateAny : (([String : Any]) -> Void)?
    var didError: ((CustomErrorStruct) -> Void)?
    var requestStarProfileModel:RequestStarProfieModel?   // Used For  RequestStarProfieModel Ojbect
    let requestStarProfileApi = SocialAPI()   // Used To Get the Reference of the SocialAPI Object For Profile
    var userName:String?            // Used To Store the userName
    var fullName:String?            // Used To Store the fullName
    var knownAs:String?             // Used To Store the KnownAs
    var email:String?               // Used To Store the Email
    var phoneNumber:String?         // Used To Store the phone number
    var imageUrlString:String?      // Used To Store image URL String
    var starCategoryId :String?     // Used To Store the Category ID
    var starCategoryName:String?    // Used To Store the Category Name
    var selectedImage:UIImage?      // Used To Store Picked Image Object
    var termsAndConditions:Bool = false    // Used to check terms and conditions
    
    /// Checking The All Required Fields If Completion Successfull Calling API
    ///
    /// - Parameter complitation: complitation handler after compliting Required Fields Checking
    func checkingRequiredFields(complitation: @escaping(Bool)->Void){
         if  knownAs == "" || knownAs == nil{
             Helper.showAlertViewOnWindow("Message".localized, message: "Please enter".localized + " " + "known as".localized + "!")
        } else if email == nil {
            Helper.showAlertViewOnWindow("Message".localized, message: "Please enter".localized + " " + "email".localized + ".")
        }else if phoneNumber == nil  {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: "Please enter".localized + " " + "phone number".localized + ".")
        }else if !termsAndConditions {
            Helper.showAlertViewOnWindow(Strings.message.localized, message: "Please accept".localized + " \(AppConstants.AppName) " + "star terms and conditions".localized)
        }
        else if (fullName?.count) ?? 1 < 3 {
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.fullNameShouldbeMoreThanThreeCharacters.localized + ".")
        }else if Helper.isValidEmail(emailText: email ?? "") == false{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidEmail.localized )
        }else if (phoneNumber?.count ?? 1) < 6{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseEnterValidPhoneNumber.localized)
        }else if starCategoryId == nil{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseSelectCategory.localized)
        }else if selectedImage == nil{
            Helper.showAlertViewOnWindow(Strings.warning.localized, message: Strings.pleaseChooseFile)
        }
        else {
            complitation(true)
        }
        
    }
    
    
    
    /// Requesting For VerifyProfile API Call - POST
    ///
    /// - Parameters:
    ///   - strUrl: starRequest url String
    ///   - complitation: complitation handler after compliting service call
    func requestPostCall(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        Helper.showPI()
        guard let choosenImage = selectedImage else {return }
        
        CloudinaryManager.sharedInstance.uploadImage(image: choosenImage, folder: .other) { (result, error) in
            DispatchQueue.main.async {
            
                if let url = result?.url {
                    self.imageUrlString = url
                    let params = ["categorieId":self.starCategoryId as Any,
                                  "starUserEmail":self.email as Any,
                                  "starUserPhoneNumber":self.phoneNumber as Any,
                                  "starUserIdProof": self.imageUrlString as Any,
                                  "starUserKnownBy":self.knownAs as Any] as [String : Any]
                    self.requestStarProfileApi.postSocialData(with: strUrl, params: params as [String : Any]) { (response, error) in
                        print(response as Any)
                        if response != nil{
                            complitation(true, error)
                            
                        }else if let error = error{
                            print(error.localizedDescription)
                            Helper.showAlertViewOnWindow(Strings.message.localized, message: error.localizedDescription)
                            complitation(false, error)
                            
                        }
                    }
                }
        }
    }
        
        
    }
    
    func getCurrentTimeStamp() -> String {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmssa"
        formatter.locale = Locale.current
        let result = formatter.string(from: date)
        return result
    }
    
    /// Get verify Profile Status Details
    ///
    /// - Parameter complitation: complitation handler after compliting service call
    func getStarStatusServiceCall(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        let strUrl = AppConstants.starStatus
        profileUsersApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? [String:Any]{
                guard let dict = result as? [String : Any] else{
                    complitation(true, nil)
                    return
                }
                self.knownAs = dict["starUserKnownBy"] as? String
                self.starCategoryName = dict["categoryName"] as? String
                self.starCategoryId = dict["categorieId"] as? String
                self.email = dict["starUserEmail"] as? String
                self.phoneNumber = dict["starUserPhoneNumber"] as? String
                //            self.setCategoryModelData(modelData: result)
                self.requestStarProfileModel = RequestStarProfieModel(modelData: dict)
                
                //            let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error)
            }
            Helper.hidePI()
            
        }
    }
}
