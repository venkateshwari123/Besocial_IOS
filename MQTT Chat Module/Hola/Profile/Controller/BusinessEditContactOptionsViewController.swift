//
//  BusinessEditContactOptionsViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 02/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
import UIKit
class BusinessEditContactOptionsViewController: UIViewController {
    
    /// All Outlets
    @IBOutlet weak var contactOptionsTableView: UITableView!
    @IBOutlet weak var businessContactTitleLbl: UILabel!
    
    /// All Declarations & Variables
    var mobileNumber:String?
    var email:String?
   // var address:String?
    var countryCode:String?
    var countryImage:UIImage?
//    var accountKit:AccountKitManager!
    var streetAddress:String?
    var cityTown:String?
    var zipCode:String?
    var businessLat:String?
    var businessLang:String?
    var businessCategoryId:String?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        businessContactTitleLbl.text = "Business Information".localized
        self.navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.contactOptions.localized)
        let nextBtn = UIBarButtonItem.init(title: Strings.done.localized, style: .done, target: self, action: #selector(nextAction))
        nextBtn.tintColor = .label
        self.navigationItem.rightBarButtonItem = nextBtn
        self.contactOptionsTableView.estimatedRowHeight = 70
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        self.contactOptionsTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    @objc func nextAction() {
//        let editVc = self.navigationController?.viewControllers[0] as! EditProfileViewController
//        editVc.businessStreetAddress = self.streetAddress ?? ""
//        editVc.businessCity = self.cityTown ?? ""
//        editVc.businessZipCode = self.zipCode ?? ""
//        editVc.businessEmail = self.email ?? ""
//        editVc.businessPhone = self.mobileNumber ?? ""
//        editVc.businessCountryCode = self.countryCode ?? ""
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

//MARK:- Extension
// MARK: - UITableViewDelegate,UITableViewDataSource
extension BusinessEditContactOptionsViewController: UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate ,BusinessContactInfoDelegate,UITextViewDelegate{
    func gettingBusinessAddress(streetAddress: String, placeAddress: String, zipCode: String, lat: String, lang: String) {
        // self.address = "\(streetAddress),\(placeAddress),\(zipCode)"
        self.streetAddress = streetAddress
        self.cityTown = placeAddress
        self.zipCode = zipCode
        self.businessLat = lat
        self.businessLang = lang
        self.contactOptionsTableView.reloadData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
       guard let businessContactEditOptionsCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessEditContactOptionsCell, for: indexPath) as? BusinessEditContactOptionsCell else {fatalError()}
            businessContactEditOptionsCell.businessContactOptionsCellDelegate  = self
            self.setDataInCell(textCell: businessContactEditOptionsCell, index: indexPath)
            return businessContactEditOptionsCell
      
    }
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func setDataInCell(textCell: BusinessEditContactOptionsCell, index: IndexPath){
        switch index.row {
        case 0:
            textCell.placeHolderLabelText.text = Strings.email.localized
            textCell.detailsLabelText.text = self.email
           // textCell.detailTextField.tag = 1
            textCell.editBusinessContactOptionsBtnOutlet.tag = 1
           // textCell.countryViewOutlet.isHidden = true
        case 1:
            textCell.placeHolderLabelText.text = Strings.phoneNumber.localized
             //textCell.countryViewOutlet.isHidden = false
//            textCell.detailTextField.tag = 2
            textCell.editBusinessContactOptionsBtnOutlet.tag = 2
            let path = Bundle.main.path(forResource: Strings.callingCodes, ofType: Strings.plist)
            let array = NSArray(contentsOfFile: path!) as! [[String: String]]
            if let defaultCountry = array.filter({$0[Strings.dialCode] == countryCode}).first{
                let countryImageName = defaultCountry[Strings.code]
                countryImage = VNHCountryPicker.getCountryImage(code: countryImageName ?? "")
//                textCell.countryImageView.image = countryImage
//                textCell.countryCodeLabelOutlet.text = self.countryCode
                textCell.detailsLabelText.text = "\(self.countryCode ?? "")\(self.mobileNumber ?? "")"
            }
        default:
            textCell.detailsLabelText.text = "\(streetAddress ?? ""),\(cityTown ?? ""),\(zipCode ?? "")"
            textCell.placeHolderLabelText.text = Strings.address.localized
            textCell.editBusinessContactOptionsBtnOutlet.tag = 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            if self.streetAddress == "" {
                return 70
            }else {
            return UITableView.automaticDimension
            }
        }else {
        return 70
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
//        switch textField.tag {
//        case 1:
//
//            return false
//        case 2:
//            /// Pushing To BusinessMobileConfigurationViewController
////            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
////            let businessMobileVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessMobileConfigurationViewControllerId) as! BusinessMobileConfigurationViewController
////            if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
////                if let isNumberisVisible = businessPhoneDetails[Strings.isVisible] as? Bool{
////                    businessMobileVcId.visibleMobileNumberInteger = isNumberisVisible
////                }
////            }
////            //            businessMobileVcId.isEditingBusiess = true
////
////            businessMobileVcId.mobileNumber = self.mobileNumber
////            businessMobileVcId.countryCode = self.countryCode
////            self.navigationController?.pushViewController(businessMobileVcId, animated: true)
//
//            //            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
//            //            let businessEditPhoneVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessPhoneNumberEditViewControllerId) as! BusinessPhoneNumberEditViewController
//            //            businessEditPhoneVc.countryFlag = self.countryImage
//            //            businessEditPhoneVc.countryCode = self.countryCode
//            //            businessEditPhoneVc.mobileNumber = self.mobileNumber
//            //            self.navigationController?.pushViewController(businessEditPhoneVc, animated: true)
//
//
//
//            return false
//        case 3:
//
//            return false
//        default:
//            break
//        }
        return false
    }
//
//    func prepareLoginViewController(loginViewController: AKFViewController) {
//        loginViewController.delegate = self
//        loginViewController.isSendToFacebookEnabled = true
//        //  loginViewController.enableGetACall = true
//        loginViewController.isSMSEnabled = true
//        // uiTheme Modification
//        loginViewController.uiManager = SkinManager.init(skinType: .contemporary, primaryColor: .red)
//        //        let theme:Theme = Theme.default()
//        //      theme.headerTextType
//        //        loginViewController.setTheme(theme)
//    }
//
 
//    func viewController(_ viewController: UIViewController & AKFViewController, didCompleteLoginWith accessToken: AccessToken, state: String) {
//        self.accountKit.requestAccount { (account, error) in
//            if error == nil {
//                self.mobileNumber = account?.phoneNumber?.phoneNumber
//                if (account?.phoneNumber?.countryCode.hasPrefix("+"))!{
//                    self.countryCode = account?.phoneNumber?.countryCode
//                }else {
//                    self.countryCode = "+\(account?.phoneNumber?.countryCode ?? "")"
//                }
//        self.contactOptionsTableView.reloadData()
//            }
//        }
//        self.contactOptionsTableView.reloadData()
//    }
}

extension BusinessEditContactOptionsViewController: BusinessEditContactOptionsCellDelegate {
  
    func editBusinessContactOptionsAction(_ buttonTag: Int) {
        switch buttonTag {
        case 1:
            /// Pushing To BusinessEmailConfigurationViewController
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessEmailVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessEmailConfigurationViewControllerId) as! BusinessEmailConfigurationViewController
            if let businessEmailDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessEmail) as? [String:Any]{
                if let isEmailVisible = businessEmailDetails[Strings.isVisible] as? Bool{
                    businessEmailVcId.isEmailVisible = isEmailVisible
                }
            }
            businessEmailVcId.isFromEditBusniess = true
            
            businessEmailVcId.email = self.email
            self.navigationController?.pushViewController(businessEmailVcId, animated: true)
        case 2:
            
            // Pushing To BusinessMobileConfigurationViewController
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessMobileVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessMobileConfigurationViewControllerId) as! BusinessMobileConfigurationViewController
            if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
                if let isNumberisVisible = businessPhoneDetails[Strings.isVisible] as? Bool{
                    businessMobileVcId.visibleMobileNumberInteger = isNumberisVisible
                }
            }
            businessMobileVcId.isFromEditBusniess = true
            businessMobileVcId.businessCategoryId = self.businessCategoryId
            businessMobileVcId.mobileNumber = self.mobileNumber
            businessMobileVcId.countryCode = self.countryCode
            self.navigationController?.pushViewController(businessMobileVcId, animated: true)
            
//                                    let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
//                                    let businessEditPhoneVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessPhoneNumberEditViewControllerId) as! BusinessPhoneNumberEditViewController
//                                    businessEditPhoneVc.countryFlag = self.countryImage
//                                    businessEditPhoneVc.countryCode = self.countryCode
//                                    businessEditPhoneVc.mobileNumber = self.mobileNumber
//                                    self.navigationController?.pushViewController(businessEditPhoneVc, animated: true)
            
            
//            var phone:PhoneNumber?
//            accountKit = AccountKitManager.init(responseType: .accessToken)
//
//            phone = PhoneNumber.init(countryCode: self.countryCode ?? "", phoneNumber: self.mobileNumber ?? "")
//            let loginVC =  accountKit.viewControllerForPhoneLogin(with: phone, state: "")
//            self.prepareLoginViewController(loginViewController: loginVC )
//            self.present(loginVC, animated: true, completion: nil)
        default:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessAddressVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessAddressViewControllerId) as! BusinessAddressViewController
            businessAddressVc.businessContactInfoDelegate = self
            businessAddressVc.placeAddress = self.streetAddress
            businessAddressVc.cityTown = self.cityTown ?? ""
            businessAddressVc.zipCode = zipCode
            self.navigationController?.pushViewController(businessAddressVc, animated: true)
        }
    }
}
