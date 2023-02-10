//
//  EditPhoneNumberViewController.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 26/02/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS
import RxCocoa
import RxSwift
import Locksmith
import Alamofire

protocol EditPhoneNumberViewControllerDelegate: class {
    func isPhoneNumberupdated()
}

class EditPhoneNumberViewController: UIViewController {
    
    
    /// Outlets
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var phoneNumberTextView: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    
    /// variables and Declarations
    var countryCode: String = "IN"
    var countryCodeNumber: String = "+91"
    var phoneNumber: String = ""
    var isValidNumber: Bool = false
    var isChanged: Bool = false
    var delegate: EditPhoneNumberViewControllerDelegate?
    
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.getPhoneNumberAndCountryCode()
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            self.countryCodeNumber = VNHCountryPicker.dialCode(code: countryCode).dialCode
            self.countryCodeLabel.text = self.countryCodeNumber
            self.countryCode = VNHCountryPicker.dialCode(code: countryCode).code
            self.countryImageView.image = VNHCountryPicker.getCountryImage(code: countryCode)
        }
        self.doneButtonOutlet.isEnabled = false
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isChanged{
            self.delegate?.isPhoneNumberupdated()
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isValidNumber = false
        self.phoneNumberTextView.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.phoneNumberTextView.resignFirstResponder()
    }
    
    
    /// To extract country code and phone number from combined country code and phone number and set it to labels and text view
    //    private func getPhoneNumberAndCountryCode(){
    //        let phonUtil = NBPhoneNumberUtil()
    //        do {
    //            let nbPhone : NBPhoneNumber = try phonUtil.parse(withPhoneCarrierRegion: self.phoneNumberWithCountryCode)
    //            countryCode = "+\(nbPhone.countryCode ?? 1)"
    //            phoneNumber = "\(nbPhone.nationalNumber ?? 1)"
    //            DispatchQueue.main.async {
    //                self.countryCodeLabel.text = self.countryCode
    //                self.countryImageView.image = VNHCountryPicker.getCountryImagefromCountryCode(countryCode: self.countryCode)
    //                self.phoneNumberTextView.text = self.phoneNumber
    //            }
    //        }catch{
    //            //Phone Number Invalid!
    //        }
    //    }
    
    
    /// To manage view height according to keyboard height
    ///
    /// - Parameter notification: keyboard notification object
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            //            if #available(iOS 11, *) {
            //                if keyboardHeight > 0 {
            //                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
            //                }
            //            }
            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                let frame = self.view.frame
                let height = UIScreen.main.bounds.height - keyboardHeight
                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstants.segueIdentifiers.editNumberVarificationSegue{
            let editNumberVarificationVC = segue.destination as? EditNumberVarificationViewController
            editNumberVarificationVC?.phoneNumber = self.phoneNumberTextView.text
            editNumberVarificationVC?.countryCode = self.countryCodeNumber
            editNumberVarificationVC?.delegate = self
        }
    }
    
    //MARK:- Buttons Action
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCountryCodeAction(_ sender: Any) {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonAction(_ sender: Any) {
        let isNetwork = (UIApplication.shared.delegate as? AppDelegate)?.isNetworkThere
        if isNetwork == false{
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.checkInternetConnection.localized)
            return
        }
        
        self.view.endEditing(true)
        if self.phoneNumberTextView.text?.count == 0{
            return
        }
        //Checing and Removing first charector if it is zero in entered number
        guard var number = self.phoneNumberTextView.text?.digits else { return }
        if number.first == "0"{
            number.remove(at: number.startIndex)
        }
        phoneNumber = number
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNum = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode)
            if (phoneUtil.isValidNumber(phoneNum)) {
                //Removed popup
                let customView = CustomAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                customView.tag = 10
                customView.delegete  = self
                customView.userNumberLbl.text =  "\(String(describing: countryCodeLabel.text!))" + "\(String(describing: phoneNumber))"
                appDelegetConstant.window.addSubview(customView)
                customView.popUpAnimation()
            } else {
                let alert = UIAlertController(title: Strings.alert.localized, message: Strings.yourPhoneNumberisINCorrect.localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.okay.localized, style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        catch let error{
            //            DDLogDebug(error.localizedDescription)
            print(error)
            Helper.showAlertViewOnWindow(Strings.oops.localized, message: Strings.phoneNumberIsTooLong.localized)
        }
        
    }
    
    
    //MARK:- Service call
    func requestChnageNumber() {
        Helper.showPI()
        let strURL =  AppConstants.requestChangeNumber
        //        guard let number = self.phoneNumberOutlet.text?.digits else { return }
        guard let countryCode = self.countryCodeLabel.text else { return }
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        
        let deviceName = UIDevice.current.name
        let deviceOS = UIDevice.current.systemVersion
        let deviceModel = UIDevice.modelName
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        let params = [Strings.newNumberWithOutCountryCode:phoneNumber,
                      Strings.couuntryCodekey:countryCode,
                      Strings.deviceIdKey:deviceID,
                      Strings.deviceNameKey:deviceName,
                      Strings.deviceOsKey:deviceOS,
                      Strings.modelNumberKey:deviceModel,
                      Strings.deviceTypeKey:"1",
                      Strings.appVersionKey:appVersion as Any,
                      ] as [String:Any]
        
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict[Strings.tokenKey] as? String  else {return}
        
        let headers = [Strings.authorizationKey:token,
                       Strings.langKey:Utility.getSelectedLanguegeCode()] as [String: String]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestChangeNumber.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.requestChangeNumber.rawValue {
                    apiCall.subject_response.subscribe().dispose()
                    self.performSegue(withIdentifier: AppConstants.segueIdentifiers.editNumberVarificationSegue, sender: nil)
                    Helper.hidePI()
                }
            }, onError: {error in
                //                DDLogDebug("\(error)")
                print(error.localizedDescription)
                Helper.hidePI()
            })
    }
}

// MARK:- Country Picker Delegate
extension EditPhoneNumberViewController : VNHCountryPickerDelegate{
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.countryCodeLabel.text = country.dialCode
        self.countryCode = country.code
        self.countryImageView.image = flag
        self.phoneNumberTextView.text = ""
    }
}


// MARK:- Country Picker Text Field Delegate
extension EditPhoneNumberViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.isValidNumber && string != ""{
            return false
        }
        let textWithoutSpaces = textField.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        var number = textWithoutSpaces
        if string == ""{
            number?.removeLast()
        }else{
            number = textWithoutSpaces! + string
        }
        self.isValidNumber = self.isEnteredNumberValid(number: number!)
        if self.isValidNumber {
            self.doneButtonOutlet.isEnabled = true
            self.doneButtonOutlet.titleLabel?.textColor = AppColourStr.themeColor
        }else{
            self.doneButtonOutlet.isEnabled = false
            self.doneButtonOutlet.titleLabel?.textColor = UIColor.lightGray
        }
        return true
    }
    
    /// To validate number user is entring is valid or not
    ///
    /// - Parameter number: number entered by user
    /// - Returns: if valid return true otherwise false
    fileprivate func isEnteredNumberValid(number: String) -> Bool{
        var mobileNumber = number
        if mobileNumber.first == "0"{
            mobileNumber.remove(at: number.startIndex)
        }
        phoneNumber = mobileNumber
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNum = try phoneUtil.parse(phoneNumber, defaultRegion: countryCode)
            if (phoneUtil.isValidNumber(phoneNum)) {
                return true
            } else {
                return false
            }
        }catch {
            return false
        }
    }
}

// MARK: - customViewdelegte
extension EditPhoneNumberViewController: customViewdelegte{
    func  didDonecliked() {
        let customalertView = appDelegetConstant.window.viewWithTag(10)
        //        customalertView?.removeFromSuperview()
        
        customalertView?.popDownAnimation(animationDone: { (finished) in
            self.phoneNumberTextView.becomeFirstResponder()
            
            if (self.phoneNumber.count)>4 {
                self.doneButtonOutlet.isEnabled = true
                self.doneButtonOutlet.titleLabel?.textColor = AppColourStr.mainColor
            }else{
                self.doneButtonOutlet.isEnabled = false
                self.doneButtonOutlet.titleLabel?.textColor = UIColor.lightGray
            }
            self.requestChnageNumber()
        })
    }
    
    
    func  didEditCliked() {
        
        let customalertView = appDelegetConstant.window.viewWithTag(10)
        //        customalertView?.removeFromSuperview()
        customalertView?.popDownAnimation(animationDone: { (finished) in
            self.phoneNumberTextView.becomeFirstResponder()
            if (self.phoneNumberTextView.text?.count)!>4 {
                self.doneButtonOutlet.isEnabled = true
                self.doneButtonOutlet.titleLabel?.textColor = AppColourStr.mainColor
            }else{
                self.doneButtonOutlet.isEnabled = false
                self.doneButtonOutlet.titleLabel?.textColor = UIColor.lightGray
            }
        })
    }
}

extension EditPhoneNumberViewController: EditNumberVarificationViewControllerDelegate{
    
    func isNumberChanged(){
        self.isChanged = true
    }
}
