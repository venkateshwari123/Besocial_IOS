//
//  kycDocumentViewModel.swift
//  PicoAdda
//
//  Created by A.SENTHILMURUGAN on 1/14/1399 AP.
//  Copyright © 1399 Rahul Sharma. All rights reserved.
//

import Foundation
import Locksmith
import RxSwift
import RxCocoa

class KycDocumentViewModel {
    
   var kycverifyApi = KycVerifyAPI()
    var documentListApi = DocumentListAPI()
   var didError: ((CustomErrorStruct) -> Void)?
   var didUpdateAny : (([String : Any]) -> Void)?
   var didGetResponse = PublishSubject<Bool>()
   var kycIsApproved = PublishSubject<Bool>()
    var documentListModel : DocumentListModel?
    var ifscCode = ""
    var accountNumber = ""
    var accountHolderName = ""
    var documentName = ""
    var licenseNumber = ""
    var licenseHolderName = ""
    
    func validateDoc(documentName: String, documentNumber: String, documentHolderName: String) -> Bool{
        
        if documentName.count == 0 {
            Helper.showAlertViewOnWindow("", message: "Select".localized + " " + "document type".localized)
            return true
        }else if documentNumber.count == 0 {
            Helper.showAlertViewOnWindow("", message: "enter".localized + " " + "License Number".localized)
            return true
        }else if documentHolderName.count == 0 {
            Helper.showAlertViewOnWindow("", message: "enter".localized + " " + "License Holder Name".localized)
            return true
        }else {
            return false
        }
    }
    
    func validatePic(documentFrontImage: UIImage, documentBackImage: UIImage) -> Bool {
        if documentFrontImage == #imageLiteral(resourceName: "noun_Image_2536623") {
            Helper.showAlertViewOnWindow("", message: "Select".localized + " " + "front Image".localized)
                 return true
            }else if documentBackImage == #imageLiteral(resourceName: "noun_Image_2536623") {
                Helper.showAlertViewOnWindow("", message: "Select".localized + " " + "back Image".localized)
                 return true
        }else {
            return false
        }
    }
    
   
    
    func verifyKyc(documentName: String, documentNumber: String, documentHolderName: String, ifscCode: String, accountNumber: String, accountHolderName: String,documentFrontImage: String,documentBackImage: String){
        self.kycverifyApi.verifyKyc(ifscCode: ifscCode, accountNumber: accountNumber, accountHolderName: accountHolderName, documentType: documentName, documentNumber: documentNumber, documentHolderName: documentHolderName, documentFrontImage: documentFrontImage, documentBackImage: documentBackImage) { (response, error) in
            if let data = response {
                print(data)
               self.didGetResponse.onNext(true)
                    
            }else{
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func kycApproved() {
        self.kycverifyApi.kycApprovedApi { (success, error) in
            if success {
                self.kycIsApproved.onNext(true)
            } else {
                if let error = error,  let didError = self.didError {
                didError(error)
                }
            }
            
            
        }
    }
    
     func getDocumentList(finished: @escaping(Bool, CustomErrorStruct?)->Void){
          
          let strURl = AppConstants.documentList
        documentListApi.getDocumentList(withURL: strURl, params: [:]) { (modelArray, customError) in
              if let modelData = modelArray as? [String : Any]{
                self.documentListModel = DocumentListModel.init(modelData: modelData)
                  finished(true, nil)
              }
              if let error = customError{
  //                self.apiResponseRecieved.onNext(false)
                  if error.code == 204{
                      finished(true, error)
                  }else{
                      finished(false, error)
                  }
                  print(error)
                  
              }
          }
      }
    
    func getDocumentCount()-> Int{
        if let count = documentListModel?.data?.count {
            return count
        }else{
            return 0
        }
    }
    
    func getDocumentList(index: Int) -> String{
        if let data = documentListModel?.data {
            let list = data[index]
                 return list
           }else{
            return ""
        }
    }
    
}
