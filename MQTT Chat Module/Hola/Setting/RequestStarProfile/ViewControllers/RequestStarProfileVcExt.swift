//
//  RequestStarProfileVcExt.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/2/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import Foundation
import UIKit
import PhotosUI
import TextFieldEffects
import PhoneNumberKit
// MARK: - UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,     UINavigationControllerDelegate
extension RequestStarProfileViewController:UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5 || indexPath.row == 7{
            let footerCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.requestStarProfileFooterViewCellId, for: indexPath) as! RequestStarProfileFooterViewCell
            return footerCell
        }else if indexPath.row == 6 {
            let categoryCell = tableView.dequeueReusableCell(withIdentifier:
                AppConstants.CellIds.requestStarProfileCategoryCellId, for: indexPath) as! RequestStarProfileCategoryCell
            
            //            let categoryName = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.categoryName) as? String
            categoryCell.categoryTitle.text = "Verify Category".localized
            if self.requestStarProfileVmObject.starCategoryName != nil {
                categoryCell.categoryTitle.text = self.requestStarProfileVmObject.starCategoryName
            }
            
            return categoryCell
        }else if indexPath.row == 8{
            let chooseFileCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.requestStarProfileChooseFileViewCellId, for: indexPath) as! RequestStarProfileChooseFileViewCell
            chooseFileCell.delegate1 = self
            return chooseFileCell
        }
        
        let textCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.requestStarProfileTextCellId, for: indexPath) as! RequestStarProfileTextCell
        
        
        textCell.textCellDelegate = self
        //  textCell.countryPickerViewWidthConstraints.constant = 0
        textCell.countryImageViewWidthConstraint.constant = 0
        textCell.countryCodeLabelWidthConstraint.constant = 0
        textCell.dropDownImageWidthConstraint.constant = 0
        textCell.countryButtonWidthConstraint.constant = 0
        
        
        switch indexPath.row {
        case 0:
            textCell.detailsTextField.placeholder = Strings.userName.localized
            textCell.detailsTextField.text = requestStarProfileVmObject.userName // self.requestStarProfileVmObject.userName
            textCell.detailsTextField.tag = 1
            
        case 1:
            textCell.detailsTextField.placeholder = Strings.fullName.localized
            textCell.detailsTextField.text = requestStarProfileVmObject.fullName
            textCell.detailsTextField.tag = 2
        case 2:
            textCell.detailsTextField.placeholder = Strings.knownAs.localized
            textCell.detailsTextField.text = requestStarProfileVmObject.knownAs
            textCell.detailsTextField.tag = 3
        case 3:
            textCell.detailsTextField.placeholder = Strings.email.localized
            textCell.detailsTextField.text = requestStarProfileVmObject.email
            textCell.detailsTextField.tag = 4
        case 4:
            textCell.detailsTextField.placeholder = Strings.phoneNumber.localized
            ///  textCell.countryPickerViewWidthConstraints.constant = 93
            textCell.countryImageViewWidthConstraint.constant = 32
            textCell.countryCodeLabelWidthConstraint.constant = 40
            textCell.dropDownImageWidthConstraint.constant = 14
            textCell.countryButtonWidthConstraint.constant = 53
            
            if let number = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
                if requestStarProfileVmObject.phoneNumber == number {
                    if !number.contains("+") {
                        textCell.detailsTextField.text = "\(self.countryCodeName ?? "")\(number )"
                    }else{
                        textCell.detailsTextField.text = "\(number )"
                    }
                    
                }else {
                    if !(self.requestStarProfileVmObject.phoneNumber?.contains("+") ?? false) {
                        textCell.detailsTextField.text = "\(self.countryCodeName ?? "")\(self.requestStarProfileVmObject.phoneNumber ?? "")"
                    }else{
                        textCell.detailsTextField.text = "\(self.requestStarProfileVmObject.phoneNumber ?? "")"
                    }
                }
            }
            textCell.detailsTextField.tag = 5
        default:
            break
        }
        return textCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 5 || indexPath.row == 7{
            return 20
        }else if indexPath.row == 6{
            return 50
        }else if indexPath.row == 8{
            return UITableView.automaticDimension
        }else if indexPath.row == 3 || indexPath.row == 4 {
            return 0
        }
        return 78
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 6{
            // requestStarCategoryVmObject.requestCategoryApiCall()
            
            /// Pushing To Category View Controller
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let categoryVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.requestStarCategoryViewControllerId) as! RequestStarCategoryViewController
            categoryVc.starProfiledelegate = self
            self.navigationController?.pushViewController(categoryVc, animated: true)
        }
    }
    
    
    /// Opening Alert Sheet with Image selection Options
    func imageSelection(){
        let alertController:UIAlertController = {
            let alert = UIAlertController.init(title: Strings.chooseSource.localized, message: Strings.selectImageSource.localized + "...", preferredStyle: .actionSheet)
            
            //Add the buttons to the AlertController
            
            let cancelBtn:UIAlertAction = UIAlertAction.init(title: Strings.cancel.localized, style: .cancel, handler: nil)
            
            let cameraBtn:UIAlertAction = UIAlertAction.init(title: Strings.camera.localized, style: .default, handler: { (cameraBtn) in
                
                //+++++++++Creating the UIImage Picker Controller ++++++++++//
                //==========For Camera  Source Type===========//
                
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                    
                    let cameraPicker = UIImagePickerController.init()
                    
                    cameraPicker.sourceType = .camera
                    
                    cameraPicker.delegate = self
                    
                    self.present(cameraPicker, animated: true, completion: nil)
                }
            })
            
            let photoLibBtn:UIAlertAction = UIAlertAction.init(title: Strings.photoLibrary.localized, style: .default, handler: { (photoBtn) in
                
                //==========For PhotoLibrary  Source Type===========//
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                    
                    let photoPicker = UIImagePickerController.init()
                    photoPicker.navigationBar.tintColor = UIColor.black
                    photoPicker.sourceType = .photoLibrary
                    photoPicker.delegate = self
                    self.present(photoPicker, animated: true, completion: nil)
                }
            })
            let savedAlbumBtn:UIAlertAction = UIAlertAction.init(title: Strings.savedAlbum.localized, style: .default, handler: { (savedBtn) in
                
                //==========For SavedPhotosAlbum  Source Type===========//
                
                if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                    
                    let albumPicker = UIImagePickerController.init()
                    albumPicker.navigationBar.tintColor = UIColor.black
                    albumPicker.sourceType = .savedPhotosAlbum
                    albumPicker.delegate = self
                    self.present(albumPicker, animated: true, completion: nil)
                    
                }
                
            })
            
            alert.addAction(cancelBtn)
            alert.addAction(cameraBtn)
            alert.addAction(photoLibBtn)
            alert.addAction(savedAlbumBtn)
            
            return alert
        }()
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    /// After Picking Image This Will Get Call
    ///
    /// - Parameters:
    ///   - picker: picker Object
    ///   - info: info About Image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        let cell = self.requestStarProfileTableView.cellForRow(at: IndexPath(row: 8, section: 0)) as! RequestStarProfileChooseFileViewCell
        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            return
        }
        cell.choosenImage.image = image
        requestStarProfileVmObject.selectedImage = image
        cell.chooseFileBtn.setTitle("Edit", for: .normal)
        cell.selectedImageHeightConstraintOutlet.constant = 50.0
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


//MARK:- textField Extension

// MARK: - UITextFieldDelegate,RequestStarProfileChooseFileViewCellDelegate, RequestStarProfileTextCellDelegate
extension RequestStarProfileViewController:UITextFieldDelegate, RequestStarProfileChooseFileViewCellDelegate, RequestStarProfileTextCellDelegate{
    func checkingTermsAndCondtions() {
        if let cell = self.requestStarProfileTableView.cellForRow(at: IndexPath(row: 8, section: 0)) as? RequestStarProfileChooseFileViewCell{
            self.requestStarProfileVmObject.termsAndConditions  = cell.termsAndConditionsBtn.isSelected
        }
        
    }
    
    func choosingFile() {
        imageSelection()
    }
    
    func movingToTermsAndCondtions() {
        if  let webView =  UIStoryboard.init(name: AppConstants.StoryBoardIds.chat, bundle: nil).instantiateViewController(withIdentifier: "DocumentViewerViewController") as? DocumentViewerViewController{
            webView.isComingfromSetting = true
            webView.webURL = AppConstants.starTermsConditions
            webView.titleName = "Star Pages Terms and Conditions".localized
            self.navigationController?.pushViewController(webView, animated: true)
            self.navigationController?.navigationBar.isHidden = false
        }
    }
    
    /// Presenting Country Picker ViewController
    func movingToCountryVc() {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true)
    }
    
    
    /// Requesting for Star Profile - POST
    func RequestingApiCall() {
        self.requestingStarProfilePostApiCall()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var index = IndexPath()
        switch textField.tag {
        case 1:
            index = IndexPath(row: textField.tag , section: 0)
            break
        case 2:
            index = IndexPath(row: textField.tag, section: 0)
            self.view.endEditing(true)
            break
        default:
            index = IndexPath(row: 2, section: 0)
            guard let cell = self.requestStarProfileTableView.cellForRow(at: index) as? RequestStarProfileTextCell else{return true}
            cell.detailsTextField.resignFirstResponder()
            return true
        }
        guard let cell = self.requestStarProfileTableView.cellForRow(at: index) as? RequestStarProfileTextCell else{return true}
        cell.detailsTextField.becomeFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        switch textField.tag {
        case 1:
            requestStarProfileVmObject.userName = txtAfterUpdate
            return true
        case 2:
            requestStarProfileVmObject.fullName =  txtAfterUpdate
            return true
        case 3:
            requestStarProfileVmObject.knownAs =  txtAfterUpdate
            return true
        case 4:
            requestStarProfileVmObject.email =  txtAfterUpdate
            return true
        default:
            // requestStarProfileVmObject.phoneNumber = txtAfterUpdate
            return false
        }
    }
    
    func getCell(index : Int) -> RequestStarProfileTextCell{
        let cell : RequestStarProfileTextCell = self.requestStarProfileTableView.cellForRow(at: IndexPath.init(row: index, section: 0)) as! RequestStarProfileTextCell
        return cell
    }
    
    /// To validate number user is entring is valid or not
    ///
    /// - Parameter number: number entered by user
    /// - Returns: if valid return true otherwise false
    //    fileprivate func isEnteredNumberValid(number: String) -> Bool{
    //        var mobileNumber = number
    //        if mobileNumber.first == "0"{
    //            mobileNumber.remove(at: number.startIndex)
    //        }
    //        phoneNumber  = mobileNumber
    //        let phoneUtil = NBPhoneNumberUtil()
    //        do {
    //            let phoneNum = try phoneUtil.parse(phoneNumber, defaultRegion: currentCountryName)
    //            if (phoneUtil.isValidNumber(phoneNum)) {
    //                return true
    //            } else {
    //                return false
    //            }
    //        }catch {
    //            return false
    //        }
    //    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 5{
            textField.inputAccessoryView = doneToolbar
            textField.keyboardType = UIKeyboardType.phonePad
            phoneTextField = textField
        }else {
            textField.keyboardType = UIKeyboardType.default
            textField.inputAccessoryView = nil
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 1:
            return false
        case 2:
            return false
        case 5:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let verifyMobileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verifyUserMobileConfigurationViewControllerId) as! VerifyUserMobileConfigurationViewController
            if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any] {
                verifyMobileVc.visibleMobileNumberInteger =  verifiedDetails["isNumberVisible"] as? Int
            }
            verifyMobileVc.hidesBottomBarWhenPushed = true
            verifyMobileVc.strMobile = self.requestStarProfileVmObject.phoneNumber ?? ""
            self.navigationController?.pushViewController(verifyMobileVc, animated: true)
            verifyMobileVc.countryImage = self.countryImage
            verifyMobileVc.countryCode = self.countryCodeName
            
            //            var phone:PhoneNumber?
            //            if let number = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
            //                if requestStarProfileVmObject.phoneNumber == number {
            //                    phone =  PhoneNumber.init(rawNumber: self.countryCodeName ?? "", region: number)
            //                }else {
            //                    phone = PhoneNumber.init(countryCode: self.countryCodeName ?? "", phoneNumber: requestStarProfileVmObject.phoneNumber ?? "")
            //                }
            //            }
            
            
            
            //
            //
            //            accountKit = AccountKitManager.init(responseType: .accessToken)
            //            let loginVC =  accountKit.viewControllerForPhoneLogin(with: phone, state: "")
            //            self.prepareLoginViewController(loginViewController: loginVC )
            //
            //            self.present(loginVC, animated: true, completion: nil)
            
            return false
        case 4:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let verifyMobileVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.verifyUserEmailViewControllerId) as! verifyUserEmailViewController
            if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any] {
                verifyMobileVc.visibleEmailInteger =  verifiedDetails["isEmailVisible"] as? Int
                
            }
            verifyMobileVc.hidesBottomBarWhenPushed = true
            verifyMobileVc.strEmail = textField.text ?? ""
            self.navigationController?.pushViewController(verifyMobileVc, animated: true)
            return false
        default:
            return true
        }
    }
    
    //    func prepareLoginViewController(loginViewController: AKFViewController) {
    //        loginViewController.delegate = self
    //        loginViewController.isSendToFacebookEnabled = true
    //        //  loginViewController.enableGetACall = true
    //        loginViewController.isSMSEnabled = true
    //        // uiTheme Modification
    //        loginViewController.uiManager = SkinManager.init(skinType: .contemporary, primaryColor:  #colorLiteral(red: 0.831372549, green: 0.6666666667, blue: 0.3647058824, alpha: 1))
    //        //        let theme:Theme = Theme.default()
    //        //      theme.headerTextType
    //        //        loginViewController.setTheme(theme)
    //    }
    //
    //    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith code: String, state: String) {
    //        self.accountKit.requestAccount { (account, error) in
    //            if error == nil {
    //                self.requestStarProfileVmObject.phoneNumber = account?.phoneNumber?.phoneNumber
    //                self.phoneNumber = account?.phoneNumber?.phoneNumber
    //                if (account?.phoneNumber?.countryCode.hasPrefix("+"))!{
    //                    self.countryCodeName = account?.phoneNumber?.countryCode
    //
    //                }else {
    //                    self.countryCodeName = "+\(account?.phoneNumber?.countryCode ?? "")"
    //                }
    //                self.requestStarProfileTableView.reloadData()
    //            }
    //        }
    //        self.requestStarProfileTableView.reloadData()
    //    }
    
    //    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AccessToken, state: String) {
    //        self.accountKit.requestAccount { (account, error) in
    //            if error == nil {
    //                self.requestStarProfileVmObject.phoneNumber = account?.phoneNumber?.phoneNumber
    //                self.phoneNumber = account?.phoneNumber?.phoneNumber
    //                if (account?.phoneNumber?.countryCode.hasPrefix("+"))!{
    //                    self.countryCodeName = account?.phoneNumber?.countryCode
    //
    //                }else {
    //                    self.countryCodeName = "+\(account?.phoneNumber?.countryCode ?? "")"
    //                }
    //             self.requestStarProfileTableView.reloadData()
    //            }
    //        }
    //        self.requestStarProfileTableView.reloadData()
    //    }
}
// MARK: - VNHCountryPickerDelegate
extension RequestStarProfileViewController:VNHCountryPickerDelegate{
    
    /// After Picking Country This method Will Get Call
    ///
    /// - Parameters:
    ///   - country: VNHCountry Object
    ///   - flag: Country Image
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        let textCell = self.requestStarProfileTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! RequestStarProfileTextCell
        textCell.countryCodeNumberOutlet.text = country.dialCode
        self.countryImage = flag
        self.countryCodeName = country.dialCode
        //        self.countryNameOutlet.setTitle(country.name, for: .normal)
        currentCountryName = country.code
        textCell.countryImageView.image = flag
        // self.requestStarProfileTableView.reloadData()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
