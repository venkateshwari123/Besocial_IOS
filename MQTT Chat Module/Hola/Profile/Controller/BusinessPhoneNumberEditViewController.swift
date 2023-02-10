//
//  BusinessPhoneNumberEditViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 05/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import TextFieldEffects
class BusinessPhoneNumberEditViewController: UIViewController {
    
    /// All Outlets
    @IBOutlet weak var countryPickerView: UIView!
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var phoneNumberTextField: HoshiTextField!
    @IBOutlet weak var countryCodeLabelOutlet: UILabel!
    @IBOutlet weak var yourPhoneNumberLbl: UILabel!
    @IBOutlet weak var nextBtnOutlet: UIButton!
    
    /// variables and declarations
    var countryCode:String?
    var countryFlag:UIImage?
    var mobileNumber:String?
    var currentCountryName = "US"                  // Used to Store current country name
    var isValidNumber: Bool = false                // Used to check the entered Number isValid or not
    var businessEditViewModelObject = BusinessEditViewModel()
    
    /// View life cycle
    override func viewDidLoad(){
        super.viewDidLoad()
        setUpUI()
        self.countryCodeLabelOutlet.text = self.countryCode
        self.countryImageView.image = self.countryFlag
        self.phoneNumberTextField.text = mobileNumber
        self.businessEditViewModelObject.businessMobileNumber = mobileNumber
        self.businessEditViewModelObject.businessCountryCode = countryCode
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    /// Setting UI
    func setUpUI(){
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.phoneNumber.localized)
        nextBtnOutlet.layer.cornerRadius = 20.0
        yourPhoneNumberLbl.text = "Your Phone Number".localized
        phoneNumberTextField.placeholder = "Phone Number".localized
        nextBtnOutlet.setTitle("NEXT".localized, for: .normal)
        self.phoneNumberTextField.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
        self.phoneNumberTextField.placeholderColor = UIColor.lightGray
        self.phoneNumberTextField.placeholderLabel.font = Utility.Font.Regular.ofSize(22)
        let frame = self.phoneNumberTextField.frame
        self.phoneNumberTextField.borderRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 0.1))
    }
    
    
    /// Country piceker Action
    @IBAction func countryPickerAction(_ sender: UIButton) {
        let countryPickerVc = VNHCountryPicker.instantiate(storyBoardName: AppConstants.StoryBoardIds.CountryPicker) as VNHCountryPicker
        countryPickerVc.delegate = self
        self.present(countryPickerVc, animated: true)
    }
    
    /// Next button action
    ///
    /// - Parameter sender: Otp service calling
    @IBAction func nextBtnAction(_ sender: UIButton) {
        getMobileOtpApiCall()
    }
    
    /// Api Call for business mobile number
    func getMobileOtpApiCall() {
        businessEditViewModelObject.getMobileOtp(strUrl: AppConstants.bussinessPhoneVerification) { (isFinshed, error) in
            if isFinshed{
                /// Pushing To BusinessVerificationViewController
                let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
                let verificationVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessVerificationViewControllerId) as! BusinessVerificationViewController
                verificationVc.viaEmailOrPhone =  Strings.viaMobile
                verificationVc.phoneNumber = self.mobileNumber
                verificationVc.countryCode = self.countryCode
                self.navigationController?.pushViewController(verificationVc, animated: true)
            }else if let error = error{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
            }
        }
    }
}

extension BusinessPhoneNumberEditViewController: UITextFieldDelegate {
    
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
        return true
        
    }
    
    // To validate number user is entring is valid or not
    //
    // - Parameter number: number entered by user
    // - Returns: if valid return true otherwise false
    fileprivate func isEnteredNumberValid(number: String) -> Bool{
        var mobileNumber = number
        if mobileNumber.first == "0"{
            mobileNumber.remove(at: number.startIndex)
        }
        self.mobileNumber  = mobileNumber
        self.businessEditViewModelObject.businessMobileNumber = mobileNumber
        let phoneUtil = NBPhoneNumberUtil()
        do {
            let phoneNum = try phoneUtil.parse(self.mobileNumber, defaultRegion: currentCountryName)
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

// MARK: - VNHCountryPickerDele
extension BusinessPhoneNumberEditViewController: VNHCountryPickerDelegate{
    func didPickedCountry(country: VNHCounty, flag: UIImage) {
        self.countryImageView.image = flag
        self.countryCodeLabelOutlet.text = country.dialCode
        self.currentCountryName = country.code
        self.countryCode = country.dialCode
        self.businessEditViewModelObject.businessCountryCode = country.dialCode
    }
}
