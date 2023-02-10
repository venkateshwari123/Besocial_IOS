//
//  NewEditProfileViewController.swift
//  Do Chat
//
//  Created by Rahul Sharma on 17/05/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

import AVKit
import TextFieldEffects
protocol NewEditProfileViewControllerDelegate: class{
    func profilegetUpdated()
}
class NewEditProfileViewController: UIViewController,CropViewControllerDelegate {

    @IBOutlet weak var firstNameHoldingView:UIView!
    @IBOutlet weak var lastNameHoldingView:UIView!
    @IBOutlet weak var userNameHoldingView:UIView!
    @IBOutlet weak var statusHoldingView:UIView!
    @IBOutlet weak var businessWebsiteHoldingView:UIView!
    @IBOutlet weak var businessCategoryHoldingView:UIView!
    @IBOutlet weak var businessLocationHoldingView:UIView!
    @IBOutlet weak var emailHoldingView:UIView!
    @IBOutlet weak var phoneNumberHoldingView:UIView!
    @IBOutlet weak var privateAccoutHoldingView:UIView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var coverImageView:UIImageView!
    @IBOutlet weak var switchOutlet:UISwitch!
    @IBOutlet weak var businessBioHoldingView: UIView!
    
    @IBOutlet weak var businessEmailHoldingView: UIView!
    
    @IBOutlet weak var businessEmailTF: HoshiTextField!
    @IBOutlet weak var businessUserNameHoldingView: UIView!
    @IBOutlet weak var businessNameHoldingView: UIView!
    @IBOutlet weak var businessPhoneHoldingView: UIView!
    @IBOutlet weak var knownAsHoldingView: UIView!
    
    /// outlets for user details
    @IBOutlet weak var businessNameTF: HoshiTextField!
    @IBOutlet weak var firstNameTF: HoshiTextField!
    @IBOutlet weak var lastNameTF: HoshiTextField!
    @IBOutlet weak var userNameTF: HoshiTextField!
    @IBOutlet weak var businessBioTF: UILabel!
    @IBOutlet weak var statusTF: UILabel!
    @IBOutlet weak var websiteTF: HoshiTextField!
    @IBOutlet weak var categoryTF: HoshiTextField!
    @IBOutlet weak var emailTF: HoshiTextField!
    @IBOutlet weak var phoneNumberTF: HoshiTextField!
    @IBOutlet weak var locationTF: UILabel!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var businessUserNameTF: HoshiTextField!
    @IBOutlet weak var userStatusTitleLabel: UILabel!
    @IBOutlet weak var aboutBusinessTitleLabel: UILabel!
    @IBOutlet weak var verifiedUserNameLabel: UILabel!
    @IBOutlet weak var privateAccountLabel: UILabel!
    @IBOutlet weak var privateDescriptionLabel: UILabel!
    @IBOutlet weak var businessLocationLabel: UILabel!
    @IBOutlet weak var verifiedBusinessUserNameLbl: UILabel!

    @IBOutlet weak var businessPhoneTF: HoshiTextField!
    @IBOutlet weak var knownAsTF: HoshiTextField!
    @IBOutlet weak var userNameVerificationStatusImageView: UIImageView!
    
    @IBOutlet weak var businessEmailVerificationStatusLabel: UILabel!
    @IBOutlet weak var businessEmailVerificationImageView: UIImageView!
    @IBOutlet weak var emailVerificationStatusLabel: UILabel!
    @IBOutlet weak var emailVerificationStatusImageView: UIImageView!
    @IBOutlet weak var businessPhoneVerificationImageView: UIImageView!
    @IBOutlet weak var businessPhoneVerificationStatusLabel: UILabel!
    
    @IBOutlet weak var phoneVerificationStatusImageView: UIImageView!
    
    @IBOutlet weak var phoneVerificationStatusLabel: UILabel!
    @IBOutlet weak var locationVIewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var businessBioHeightConstraint: NSLayoutConstraint!
    
    /*
     Feat Name:- BUSINESS PROFILE Call button to initiate a call to the business , EMAIL to send an email , LOCATION icon to locate the business on a map , CHAT icon to chat with the business
     Feat date:- 24th Aug 2021
     Feat By:- Nikunj C
     Description of fix:- add require outlets
     */
    
    @IBOutlet weak var emailVisibilityHoldeingView: UIView!
    @IBOutlet weak var callVisibilityHoldeingView: UIView!
    @IBOutlet weak var messageVisibilityHoldeingView: UIView!
    @IBOutlet weak var emailVisibleLabel: UILabel!
    @IBOutlet weak var callVisibleLabel: UILabel!
    @IBOutlet weak var messageVisibleLabel: UILabel!
    @IBOutlet weak var emailDescriptionLabel: UILabel!
    @IBOutlet weak var callDescriptionLabel: UILabel!
    @IBOutlet weak var messageDescriptionLabel: UILabel!
    @IBOutlet weak var emailSwitchOutlet:UISwitch!
    @IBOutlet weak var callSwitchOutlet:UISwitch!
    @IBOutlet weak var messageSwitchOutlet:UISwitch!

    
    /// variables and declarations
    var updateEmailPhoneVMObject = UpdateEmailPhoneViewModel()
    let imagePickerObj = UIImagePickerController()
    var userDetails: UserProfileModel?
    var changedStatus: String = AppConstants.defaultStatus
    var isChanged: Bool = false
    var delegate: NewEditProfileViewControllerDelegate?
    var privacy:Int?
    var isProfileChanged:Bool = false
    var profileImageUrl:String?
    var coverImageUrl:String?
    var selectedProfileImage : UIImage!
    var selectedCoverImage : UIImage!
    var croppingStyle = CropViewCroppingStyle.default
    var emailId : String = ""
    var businessName:String = ""
    // var businessAddress:String = ""
    var businessStreetAddress:String = ""
    var businessCity:String = ""
    var businessCountry:String = ""
    var businessZipCode:String = ""
    var businessWebsite:String = ""
    var businessEmail:String = ""
    var businessPhone:String = ""
    var businessCountryCode:String = ""
    var businessCategoryName:String = ""
    var businessCategoryid:String = ""
    var businessBio:String = ""
    var businessLat = "0.0"
    var businessLang = "0.0"
    var isUserNameChanged:Bool = false
    var isPrivicySelected:Bool = false
    var firstName = ""
    var lastName = ""
    var userName = ""
    var userStatus = ""
    var businessCategoryId = ""
    var emailStatus: Bool = false
    var phoneStatus: Bool = false
    var businessEmailStatus: Bool = false
    var businessphoneStatus: Bool = false
    var profilePicChanged:Bool = false
    var coverPicChanged:Bool = false
    var isPrivacyChanged:Bool = false
    var isCallTextFileBegingEditign = false
    var businessAddressVmObject = BusinessAddressViewModel()
    let chatSwitchVmObject = ChatSwitchViewModel()
    var isEmailVisibleInt:Int = 0
    var isMobileNumberVisible:Int = 0
    var isChatVisible:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetUp()
        guard let data = userDetails else{fatalError()}
        
        if let businessCategory = data.businessDetails.first?.businessCategoryName {
            self.businessCategoryName = businessCategory
        }
        if let businessName = data.businessDetails.first?.businessName {
            self.businessName = businessName
        }
        if let businessphone = data.businessDetails.first?.businessPhone?.mobileNumber, let businessCoutryCode = data.businessDetails.first?.businessPhone?.countryCode {
            self.businessPhone = businessphone
            self.businessCountryCode = businessCoutryCode
        }
        
        if let businessEmailObj = data.businessDetails.first?.businessEmail?.emailid {
            self.businessEmail = businessEmailObj
        }
        
        if let businessCategoryId = data.businessDetails.first?.businessCategoryId {
            self.businessCategoryId = businessCategoryId
        }
        
        
        self.businessBio = data.businessDetails.first?.businessBio ?? ""
        self.businessStreetAddress = data.businessDetails.first?.businessStreetAddress ?? ""
        self.businessCity = data.businessDetails.first?.businessCity ?? ""
        self.businessZipCode = data.businessDetails.first?.businessZipCode ?? ""
        self.businessWebsite = data.businessDetails.first?.businessWebsite ?? ""
        self.businessCategoryid = data.businessDetails.first?.businessCategoryId ?? ""
        
        if let businessEmail = data.businessDetails.first?.businessEmail?.emailid {
            self.businessEmail = businessEmail
        }
        
        if let details = userDetails, let status = details.status, status != ""{
            self.changedStatus = status
        }
        
        self.setAllData(modelData: data)
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)
    
    }
    
    func viewSetUp(){
        changePasswordBtn.makeBorderWidth(width: 2, color: Utility.appColor())
        changePasswordBtn.setTitleColor(Utility.appColor(), for: .normal)
        changePasswordBtn.makeCornerRadious(readious: 7)
        phoneNumberTF.delegate = self
        self.verifiedUserNameLabel.text = "Verified".localized + " !"
        self.verifiedBusinessUserNameLbl.text = "Verified".localized + " !"
        self.businessLocationLabel.text = "Business Location".localized
        self.profileImageView.makeCornerRadious(readious: self.profileImageView.frame.width / 2)
        
        if let businessData = self.userDetails?.businessDetails.first {
            if let emailStatus = businessData.businessEmail?.isVerified , emailStatus == 0 {
                self.businessEmailVerificationStatusLabel.text = "Not verified".localized + " !"
                self.businessEmailVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
                self.businessEmailVerificationImageView.image = #imageLiteral(resourceName: "notVerified")
                self.businessEmailStatus = false
            }else{
                self.businessEmailVerificationStatusLabel.text = "Verified".localized + " !"
                self.businessEmailVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
                self.businessEmailVerificationImageView.image = #imageLiteral(resourceName: "verified_profile")
                self.businessEmailStatus = true
            }
            if let phoneStatus = businessData.businessPhone?.isVerified , phoneStatus == 0 {
                self.businessPhoneVerificationStatusLabel.text = "Not verified".localized + " !"
                self.businessPhoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
                self.businessPhoneVerificationImageView.image = #imageLiteral(resourceName: "notVerified")
                self.businessphoneStatus = false
            }else{
                self.businessPhoneVerificationStatusLabel.text = "Verified".localized + " !"
                self.businessPhoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
                self.businessPhoneVerificationImageView.image = #imageLiteral(resourceName: "verified_profile")
                self.businessphoneStatus = true
            }
            if let emailVisible = businessData.businessEmail?.isVisible, emailVisible == 1 {
                self.isEmailVisibleInt = 1
                self.emailSwitchOutlet.isOn = true
            }else{
                self.isEmailVisibleInt = 0
                self.emailSwitchOutlet.isOn = false
            }
            if let phoneVisible = businessData.businessPhone?.isVisible, phoneVisible == 1 {
                self.isMobileNumberVisible = 1
                self.callSwitchOutlet.isOn = true
            }else{
                self.isMobileNumberVisible = 0
                self.callSwitchOutlet.isOn = false
            }
            if let chatVisible = businessData.isChatvisible, chatVisible == 1 {
                self.isChatVisible = 1
                self.messageSwitchOutlet.isOn = true
            }else{
                self.isChatVisible = 0
                self.messageSwitchOutlet.isOn = false
            }
        }
        
        /*
         Feat name:- add chat visibility for star user
         feat date:- 2nd Dec 2021
         feat by :- nikunj c
         */
        
        if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool,isStarVerified {
            
            if let chatVisible = userDetails?.starRequest?.isChatVisible, chatVisible == 1 {
                self.isChatVisible = 1
                self.messageSwitchOutlet.isOn = true
            }else{
                self.isChatVisible = 0
                self.messageSwitchOutlet.isOn = false
            }
            
        }
        
       
        
        /*
         Feat Name:- for normal user should show verified label
         Feat Date:- 10/07/21
         Feat By  :- Nikunj C
         Description of Fix:- show verified/unverified label from userDetails
         */
      
        if let emailStatus = self.userDetails?.isVerifiedEmail, emailStatus == 0{
            self.emailVerificationStatusLabel.text = "Not verified".localized + " !"
            self.emailVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
            self.emailVerificationStatusImageView.image = #imageLiteral(resourceName: "notVerified")
            self.emailStatus = false
        }else{
            self.emailVerificationStatusLabel.text = "Verified".localized + " !"
            self.emailVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
            self.emailVerificationStatusImageView.image = #imageLiteral(resourceName: "verified_profile")
            self.emailStatus = true
        }
        
        if let phoneStatus = self.userDetails?.isVerifiedNumber, phoneStatus == 0{
            self.phoneVerificationStatusLabel.text = "Not verified".localized + " !"
            self.phoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.9699947238, green: 0.1412755549, blue: 0, alpha: 1)
            self.phoneVerificationStatusImageView.image = #imageLiteral(resourceName: "notVerified")
            self.phoneStatus = false
        }else{
            self.phoneVerificationStatusLabel.text = "Verified".localized + " !"
            self.phoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
            self.phoneVerificationStatusImageView.image = #imageLiteral(resourceName: "verified_profile")
            self.phoneStatus = true
        }
        
        if let starUser = userDetails?.isStar, starUser == 1{
            self.privateAccoutHoldingView.isHidden = true
        }else{
            self.privateAccoutHoldingView.isHidden = false
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Strings.editProfile.localized
        let cancelBtn = UIBarButtonItem.init(title: Strings.cancel, style: .plain, target: self, action: #selector(dismissSelf))
        cancelBtn.tintColor = .label
        navigationItem.leftBarButtonItem = cancelBtn
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.tintColor = .black
            navigationItem.leftBarButtonItem?.tintColor = .label
        } else {
            // Fallback on earlier versions
        }
        self.navigationController?.navigationBar.isHidden = false
        if self.isChanged{
            self.delegate?.profilegetUpdated()
            self.dismiss(animated: true, completion: nil)
        }
        if self.emailId != "" {userDetails?.userEmail = self.emailId }
        if self.businessBio != "" {userDetails?.businessDetails.first?.businessBio = self.businessBio }
        isCallTextFileBegingEditign = false
    }
        
    @objc func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            
            let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
            UIView.animate(withDuration: duration!, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                let frame = self.view.frame
                let height = UIScreen.main.bounds.height - keyboardHeight
                self.view.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: height)
            }, completion: nil)
            view.layoutIfNeeded()
        }
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    func setAllData(modelData: UserProfileModel){
        
        //coverImage
        
        //profilePic
        if modelData.businessProfileActive == 1 {
            Helper.addedUserImage(profilePic: modelData.businessDetails.first?.businessProfileImage, imageView: self.profileImageView, fullName: modelData.businessDetails.first?.businessName ?? "D")
            self.coverImageView.setImageOn(imageUrl: modelData.businessDetails.first?.businessCoverImage, defaultImage: Utility.setDefautlCoverImage())
            self.callVisibilityHoldeingView.isHidden = false
            self.emailVisibilityHoldeingView.isHidden = false
            self.messageVisibilityHoldeingView.isHidden = false
        }else{
            Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.profileImageView, fullName: modelData.firstName + " " + modelData.lastName)
            self.coverImageView.setImageOn(imageUrl: modelData.coverImage, defaultImage: Utility.setDefautlCoverImage())
            self.callVisibilityHoldeingView.isHidden = true
            self.emailVisibilityHoldeingView.isHidden = true
            if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool,isStarVerified {
                self.messageVisibilityHoldeingView.isHidden = false
            }else{
                self.messageVisibilityHoldeingView.isHidden = true
            }
        }
        
        //account
        if modelData.privicy == 0{
            isPrivicySelected = false
            self.switchOutlet.isOn = false
        }else{
            isPrivicySelected = true
            self.switchOutlet.isOn = true
        }
        
//        if modelData.lastName == "" {
//            self.lastNameHoldingView.isHidden = true
//        }
        
        self.privateAccountLabel.text = "Private Account".localized
        self.privateDescriptionLabel.text = "To switch to a business account".localized + ", " + "your account must be Public".localized
        self.changePasswordBtn.setTitle("Change Password".localized, for: .normal)
        
        //status
        self.businessBio = modelData.businessDetails.first?.businessBio ?? ""
        self.userStatus = modelData.status ?? AppConstants.defaultStatus
        self.userStatusTitleLabel.text = "User Status".localized
        self.aboutBusinessTitleLabel.text = "About Business".localized
        
        // firstName
        if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool, businessProfile == true{
            self.businessUserNameTF.text = modelData.businessDetails.first?.businessName ?? ""
            self.lastNameHoldingView.isHidden = true
            self.firstNameHoldingView.isHidden = true
            self.emailHoldingView.isHidden = true
            self.phoneNumberHoldingView.isHidden = true
            self.userNameHoldingView.isHidden = true
            self.businessNameTF.text = self.businessName
            self.businessNameTF.placeholder = "Business Name".localized
            self.businessBioTF.text = self.businessBio
            /*
             Feat Name:- add multiple line for bio and address
             Feat Date:- 15/06/21
             Feat By  :- Nikunj C
             description of Feat:- increase view hight according to content
             */
            DispatchQueue.main.async {
                let height = self.heightForView(text: self.businessBioTF.text ?? "", font:UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.businessBioTF.bounds.size.width)
                self.businessBioHeightConstraint.constant = height + 40
                self.businessBioHoldingView.layoutIfNeeded()
            }
            self.statusHoldingView.isHidden = true
            self.businessEmailTF.text = self.businessEmail
            self.businessEmailTF.placeholder = "Business Email".localized
            self.businessPhoneTF.text = "\(self.businessCountryCode)\(self.businessPhone)"
            self.businessPhoneTF.placeholder = "Business Phone".localized
            self.userName = modelData.userName ?? ""
            self.businessUserNameTF.text = modelData.businessDetails.first?.businessUserName
            self.businessUserNameTF.placeholder = "Business UserName".localized
            self.privateAccoutHoldingView.isHidden = true
            self.lastNameHoldingView.isHidden = true
        }else {
            self.businessWebsiteHoldingView.isHidden = true
            self.businessCategoryHoldingView.isHidden = true
            self.businessLocationHoldingView.isHidden = true
            self.businessUserNameHoldingView.isHidden = true
            self.businessNameHoldingView.isHidden = true
            self.businessBioHoldingView.isHidden = true
            self.businessEmailHoldingView.isHidden = true
            self.businessPhoneHoldingView.isHidden = true
            self.firstName = modelData.firstName
            self.firstNameTF.text = self.firstName
            self.firstNameTF.placeholder = "First Name".localized
            self.statusTF.text = self.userStatus
            /*
             Feat Name:- add multiple line for bio and address
             Feat Date:- 15/06/21
             Feat By  :- Nikunj C
             description of Feat:- increase view hight according to content
             */
            DispatchQueue.main.async {
                let height = self.heightForView(text: self.statusTF.text ?? "", font: UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.statusTF.bounds.size.width)
                self.statusHeightConstraint.constant = height + 40
                self.statusHoldingView.layoutIfNeeded()
            }
            self.emailTF.text = modelData.userEmail ?? ""
            self.emailTF.placeholder = "Email".localized
            self.phoneNumberTF.text = "\(modelData.countryCode ?? "")\(modelData.number ?? "")"
//            self.phoneNumberTF.isEnabled = false
            self.phoneNumberTF.placeholder = "Phone".localized
            self.userName = modelData.userName ?? ""
            self.userNameTF.text = self.userName
            self.userNameTF.placeholder = Strings.userName
            
            /*
             Feat Name:- Known as not being displayed in the edit profile page
             Feat Date:- 24th June 2021
             feat By:- Nikunj C
             Description of Feat:- now show known as for star user
             */
            if modelData.isStar == 1{
                
                self.knownAsTF.text = modelData.starRequest?.starUserKnownBy ?? ""
                self.knownAsHoldingView.isHidden = false
            }else{
                self.knownAsHoldingView.isHidden = true
            }
        }
        
        //lastName
        self.lastName = modelData.lastName
        self.lastNameTF.text = self.lastName
        self.lastNameTF.placeholder = Strings.SignUp.lastName
        
        
        //businessWebsite
        self.businessWebsite = modelData.businessDetails.first?.businessWebsite ?? "zzz"
        self.websiteTF.text = self.businessWebsite
        self.websiteTF.placeholder = "Business Website".localized
        
       //businessCategory
        self.businessCategoryName = modelData.businessDetails.first?.businessCategoryName ?? ""
        self.categoryTF.text = self.businessCategoryName
        self.categoryTF.placeholder = Strings.businessCategory
        
      //business address
        /*
         Feat Name:- add multiple line for bio and address
         Feat Date:- 15/06/21
         Feat By  :- Nikunj C
         description of Feat:- increase view hight according to content
         */
        self.locationTF.text = "\(self.businessStreetAddress),\(self.businessCity),\(self.businessZipCode)"
        DispatchQueue.main.async {
            let height = self.heightForView(text: self.locationTF.text ?? "", font: UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.locationTF.bounds.size.width)
            self.locationVIewHeightConstraint.constant = height + 40
            self.businessLocationHoldingView.layoutIfNeeded()
        }
        
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
    
    //MARK:- Buttons Action
    /*
     Bug Name:- For a new user we are not able to set a cover photo. on updating a cover photo, it is not being displayed.
     Fix Date:- 26/07/21
     Fixed By:- Jayaram G
     Description of Fix:- Handling multi operations
     */
    @IBAction func saveAction(_ sender: Any) {
        self.view.endEditing(true)
        if coverPicChanged {
            Helper.showPI()
            self.uploadingCoverPic { (success) in
                DispatchQueue.main.async {
                    Helper.hidePI()
                }
                if success {
                    var params = [String:Any]()
                    if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool, businessProfile == true{
                        params = [Strings.businessProfileCoverImage: self.userDetails?.businessDetails.first?.businessCoverImage ?? "" as String,Strings.businessUniqueId:Utility.getBusinessUniqueId()]
                    }else{
                        params = [Strings.profileCoverImage: self.userDetails?.coverImage as Any]
                    }
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        DispatchQueue.main.async {
                            self.updateProfilePic()
                        }
                    }
                }
        }
        }else{
            self.updateProfilePic()
        }
    }
    
    func updateProfilePic() {
        if profilePicChanged {
            Helper.showPI()
                self.uploadingProfilePic { (success) in
                    DispatchQueue.main.async {
                        Helper.hidePI()
                    }
                    var params = [String:Any]()
                    if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool, businessProfile == true{
                        params = [Strings.businessProfilePic: self.userDetails?.businessDetails.first?.businessProfileImage ?? "" as String,Strings.businessUniqueId:Utility.getBusinessUniqueId()]
                    }else{
                        params = [Strings.profilePic: self.userDetails?.profilePic as Any]
                    }
                    self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                        DispatchQueue.main.async {
                            self.updatePrivacy()
                        }
                    }
            }
        }else{
            self.updatePrivacy()
        }
    }
    
    func updatePrivacy() {
        if isPrivacyChanged {
            let params = ["private": self.switchOutlet.isOn ? 1 : 0]
            self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                DispatchQueue.main.async {
                    Helper.toastViewForNavigationBar(messsage: "Profile updated".localized + ".", view: self.view)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /*
    Feat Name:- BUSINESS PROFILE Call button to initiate a call to the business , EMAIL to send an email , LOCATION icon to locate the business on a map , CHAT icon to chat with the business
    Feat Date:- 27th Aug 2021
    Feat By:- Nikunj C
    Description of Feat:- call required api to change visibility of chat, call, email
    */
    func messageSwitchApiCall(){
        let  params = ["isChatVisible":self.isChatVisible as Any,
                       "businessCategoryId":self.businessCategoryId as Any,
                       "isPhoneNumberVisible": self.isMobileNumberVisible as Any,
                       "isEmailVisible":self.isEmailVisibleInt as Any] as [String : Any]
        
        UpdateProfileApi.updateVisibleMobileNumber(params: params) { (dict) in
            Helper.toastViewForNavigationBar(messsage: "Profile updated".localized + ".", view: self.view)
             Helper.hidePI()
        }
    }
    
    func chatSwitchApiCall(state:Bool) {
        let strUrl = AppConstants.starUserChat
        chatSwitchVmObject.chatStatusChangingApiCall(strUrl: strUrl, status: state) { (finished, error) in
            if finished {
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshUserDetails), object: nil)
                Helper.toastViewForNavigationBar(messsage: "Profile updated".localized + ".", view: self.view)
                Helper.hidePI()
            }else{
                print(error?.localizedDescription)
            }
        }
    }
    
    func emailCallSwitchApiCall(){
        
        let  params = ["isEmailVisible":self.isEmailVisibleInt as Any,
                       "businessCategoryId":self.businessCategoryId as Any,
                       "isPhoneNumberVisible": self.isMobileNumberVisible as Any] as [String : Any]
        
        UpdateProfileApi.updateVisibleMobileNumber(params: params) { (dict) in
            Helper.toastViewForNavigationBar(messsage: "Profile updated".localized + ".", view: self.view)
             Helper.hidePI()
        }
    }
    
    
    
    /*
     Feat Name:- add multiple line for bio and address
     Feat Date:- 15/06/21
     Feat By  :- Nikunj C
     description of Feat:- add button action for address and bio
     */
    
    @IBAction func pushToDetailsVC(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else {return }
            updateStatusVC.value =  self.changedStatus
            updateStatusVC.isFromBusiness = false
            updateStatusVC.delegate = self
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
        case 1:
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else {return }
            updateStatusVC.value =  self.businessBioTF.text
            updateStatusVC.isFromBusiness = true
            updateStatusVC.delegate = self
    //        self.present(updateStatusVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
        case 2:
            let storyBoardObj = UIStoryboard.init(name: "AddAddress", bundle: nil)
            if #available(iOS 13.0, *) {
                let searchPlacesViewController = storyBoardObj.instantiateViewController(identifier: "SearchPlacesViewController") as! SearchPlacesViewController
                searchPlacesViewController.notifier = { search in
                    print(search)
                    self.fetchTheAddressPlaceDetails(selectedaddress: search)
                }
                self.present(searchPlacesViewController, animated: true, completion: {})
            } else {
                // Fallback on earlier versions
            }
        default:
            break
        }
    }
    
    func enableSaveAction(){
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Save".localized, style: .plain, target: self, action: #selector(saveAction(_:)))
        navigationItem.rightBarButtonItem?.tintColor = .label
    }

    //MARK:- Buttons Action
    @IBAction func privateSwitchBtnAction(_ sender: Any) {
        self.enableSaveAction()
        isPrivacyChanged = true
        if self.switchOutlet.isOn {
            self.userDetails?.privicy = 1
        }else {
            self.userDetails?.privicy = 0
        }
        
    }
    
    /*
     Feat Name:- BUSINESS PROFILE Call button to initiate a call to the business , EMAIL to send an email , LOCATION icon to locate the business on a map , CHAT icon to chat with the business
     Feat date:- 24th Aug 2021
     Feat By:- Nikunj C
     Description of fix:- add require action
     */
    
    //MARK:- Buttons Action
    @IBAction func callSwitchBtnAction(_ sender: Any) {
      
        if self.callSwitchOutlet.isOn {
            self.isMobileNumberVisible = 1
            self.userDetails?.businessDetails.first?.businessPhone?.isVisible = 1
            self.emailCallSwitchApiCall()
        }else {
            self.userDetails?.businessDetails.first?.businessPhone?.isVisible = 0
            self.isMobileNumberVisible = 0
            self.emailCallSwitchApiCall()
        }
        
    }
    
    //MARK:- Buttons Action
    @IBAction func messageSwitchBtnAction(_ sender: Any) {
       
        if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool,businessProfileCreated {
            if self.messageSwitchOutlet.isOn {
                self.isChatVisible = 1
                self.userDetails?.businessDetails.first?.isChatvisible = 1
                self.messageSwitchApiCall()
            }else {
                self.isChatVisible = 0
                self.userDetails?.businessDetails.first?.isChatvisible = 0
                self.messageSwitchApiCall()
            }
        }else{
            if self.messageSwitchOutlet.isOn {
                self.isChatVisible = 1
                self.userDetails?.starRequest?.isChatVisible = 1
                self.chatSwitchApiCall(state: true)
            }else {
                self.isChatVisible = 0
                self.userDetails?.starRequest?.isChatVisible = 0
                self.chatSwitchApiCall(state: false)
            }
        }
        
        
    }
    
    //MARK:- Buttons Action
    @IBAction func emailSwitchBtnAction(_ sender: Any) {
        
        if self.emailSwitchOutlet.isOn {
            self.isEmailVisibleInt = 1
            self.userDetails?.businessDetails.first?.businessEmail?.isVisible = 1
            self.emailCallSwitchApiCall()
        }else {
            self.isEmailVisibleInt = 0
            self.userDetails?.businessDetails.first?.businessEmail?.isVisible = 0
            self.emailCallSwitchApiCall()
        }
        
    }
    
    @IBAction func changePasswordAction(_ sender: Any){
        // change password
        guard  let resetPasswordVC =  UIStoryboard.init(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController else  { return }
  //       self.present(resetPasswordVC, animated : true)
      navigationController?.pushViewController(resetPasswordVC, animated: true)
    }
    
    @IBAction func changeCoverImageAction(_ sender: Any){
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.takePhoto.localized, style: .default, handler: { (action) in
            self.openCamera(2)
        }))
        alert.addAction(UIAlertAction(title: Strings.choosePhoto.localized, style: .default, handler: { (action) in
            self.openGallery(2)
        }))
        
        alert.addAction(UIAlertAction(title: Strings.removePhoto.localized, style: .destructive, handler: { (action) in
            /*Refactor Name :- should show default cover image when remove cover image
              Fix Date :- 05/04/2021
              Fixed By :- Nikunj C
              Description Of refactor :- add default banner */
            
            self.selectedCoverImage = UIImage.init(named: Strings.ImageNames.defaultBannerpng)
            
            /*Refactor Name :- change default cover image
              Fix Date :- 22/03/2021
              Fixed By :- Nikunj C
              Description Of refactor :- add default banner */
            
            self.coverImageView.image = self.selectedCoverImage
            self.enableSaveAction()
            self.coverPicChanged = true
            Helper.saveImage(image: self.selectedCoverImage, name: "defaultCoverImage.png")
            self.coverImageUrl = Helper.getSavedImage(name: "defaultCoverImage.png").absoluteString
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePicAction(_ sender: Any){
        self.view.endEditing(true)
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.takePhoto.localized, style: .default, handler: { (action) in
            self.openCamera(1)
        }))
        alert.addAction(UIAlertAction(title: Strings.choosePhoto.localized, style: .default, handler: { (action) in
            self.openGallery(1)
        }))
        alert.addAction(UIAlertAction(title: Strings.removePhoto.localized, style: .destructive, handler: { (action) in
//            self.selectedProfileImage = UIImage.init(named: Strings.ImageNames.defaultImagepng)
//            self.profileImageUrl = Bundle.main.url(forResource: Strings.ImageNames.defaultImage, withExtension: "png")
            
            /*
             Feat Name::- DP PlaceHolder with first character of firstname and lastname
             Feat Date:- 03/04/21
             Feat By  :- Nikunj C
             Description of Feat:-  create default placeholder
             */
            
            var profileImage = UIImage()
            if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool{
                if businessProfile{
                    profileImage = Helper.getCustomImage(imageDisplayName: self.businessName.uppercased() , imageView: self.profileImageView)
                }else{
                    let username = self.firstName + " " + self.lastName
                    profileImage = Helper.getCustomImage(imageDisplayName: username.uppercased() , imageView: self.profileImageView)
                }
            }else{
                let username = self.firstName + " " + self.lastName
                profileImage = Helper.getCustomImage(imageDisplayName: username.uppercased(), imageView: self.profileImageView)
            }
            
            self.profilePicChanged = true
            self.enableSaveAction()
            Helper.saveImage(image: profileImage, name: "defaultProfileImage.png")
            /*
             Refactor Name:- use cloudinary wrapper
             Refactor Date:- 13/05/21
             Refactor By  :- Nikunj C
             Description of Refactor:- set profileimage url and use cloudinary manager
             */
            
            self.profileImageUrl = Helper.getSavedImage(name: "defaultProfileImage.png").absoluteString
            self.userDetails?.profilePic = self.profileImageUrl
        }))
        alert.addAction(UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: { (action) in
            
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Service call
    func updateUserProfile(){
        /*
         * DeviceType  1-ios,2-android
         */
        guard let data = userDetails else{return}
        if ((data.userName?.count)! <= 0 && data.firstName.count <= 0) {
            self.showAlert(Strings.pleaseEnterYourName, message: "")
            return
        }
        var firstName: String = ""
        var lastName: String = " "
        var userName: String = ""
        
        if isUserNameChanged {
            let fullNameArr = data.firstName.components(separatedBy: " ")
            if fullNameArr.count > 0{
                firstName = data.firstName
//                    fullNameArr[0]
            }
            if fullNameArr.count > 1{
                for index in 1..<fullNameArr.count {
                    if index > 1 {
                        lastName = data.lastName
//                            lastName + " " + fullNameArr[index]
                    }else {
                        lastName = data.lastName
//                            lastName + fullNameArr[index]
                    }
                 }
            }
        }else {
            firstName = data.firstName
            lastName = data.lastName
        }
        
        if let uName = data.userName{
            userName = uName
        }
        if let mail = data.email{
            if let id = mail.emailId{
                emailId = id
            }
        }
        if self.privacy == nil {
            privacy = data.privicy
        }
        
        
        Helper.showPI(_message: " " + "Updating profile".localized + " ")
        
        self.uploadingProfilePic { (finished) in
            self.uploadingCoverPic(complitation: { (finished) in
                var params = [Strings.profilePic: data.profilePic! ,
                              Strings.firstName: firstName,
                              Strings.lastName: lastName,
                              Strings.userNameKey: userName,
                              Strings.status: data.status!,
                              Strings.emailKey:data.userEmail!,
                              Strings.privacy:self.privacy!,
                              Strings.profilCoverImage : data.coverImage! as Any,
                              Strings.businessNameKey : self.businessName,
                              "businessAddress": "\(self.businessStreetAddress),\(self.businessCity),\(self.businessZipCode)",
                              "businessStreet": self.businessStreetAddress,
                              "businessCity": self.businessCity,
                              "businessZipCode": self.businessZipCode,
                              Strings.businessWebsite : self.businessWebsite,
                              Strings.businessEmail : self.businessEmail,
                              Strings.businessPhone: self.businessPhone,
                              Strings.businessCountryCode : self.businessCountryCode,
                              Strings.businessCategoryId : self.businessCategoryid,
                              Strings.businessBioKey: self.businessBio] as [String:Any]
                
                if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool, businessProfile == true {
                    params["businessProfilePic"] = "dfdf"
                    params["businessProfileCoverImage"] = "fdf"
                }
                
                   
                UpdateProfileApi.updateUserProfile(params: params) { (dict) in
                    Helper.hidePI()
                    URLCache.shared.removeAllCachedResponses()
                    let cache = ImageCache.default
                    cache.clearMemoryCache()
                    cache.clearDiskCache { print("Done") }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                  //  NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshProfileData), object: nil)
                    if self.privacy == 1 {
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                    }
                    self.profileUpdatedSuccesfully(userData: data, firstName: firstName, lastName: lastName)
                    self.delegate?.profilegetUpdated()
                    self.dismissSelf()
                }
            })
        }
    }
    
    func profileUpdatedSuccesfully(userData: UserProfileModel, firstName: String, lastName: String) {
        let couchbase = Couchbase.sharedInstance
        let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
        let userDocVMObject = UsersDocumentViewModel(couchbase: couchbase)
        UserDefaults.standard.setValue(userData.userName, forKeyPath: AppConstants.UserDefaults.userName)
        //        Utility.getLoggedInUserProfile()?.profilePic = userData.profilePic!
        
        UserDefaults.standard.setValue(userData.profilePic!, forKeyPath: AppConstants.UserDefaults.userImage)
        UserDefaults.standard.setValue(userData.profilePic!, forKeyPath: AppConstants.UserDefaults.userImageForChats)
        UserDefaults.standard.setValue(userData.coverImage, forKey: AppConstants.UserDefaults.coverImage)
        UserDefaults.standard.setValue(self.privacy, forKey: AppConstants.UserDefaults.isPrivate)
        UserDefaults.standard.set(userData.firstName + " " + userData.lastName, forKey: AppConstants.UserDefaults.userFullName)
        UserDefaults.standard.setValue(userData.status, forKey: AppConstants.UserDefaults.userStatus)
        indexDocVMObject.updateIndexDocID(isUserSignedIn: true)
        guard let userDocID = userDocVMObject.getCurrentUserDocID() else {return}
        let refreshToken = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.refreshToken) as? String
        let privacy : Int = userData.privicy
        /*
         Bug Name:- Show full name in chats instead of username
         Fix Date:- 12/05/2021
         Fixed By:- Jayaram G
         Discription of Fix:- Replaced username with fullname
         */
        userDocVMObject.updateUserDoc(withUser: firstName, lastName: lastName, userName: userData.firstName + " " + userData.lastName, imageUrl: userData.profilePic ?? "", privacy: privacy, loginType: "1", receiverIdentifier: "", docId: userDocID, refreshToken: refreshToken)
        UserDefaults.standard.synchronize()
            
    }
}

//MARK:- Text field delegate
extension NewEditProfileViewController: UITextFieldDelegate,editBusinessBioTextCellDelegate,EditBioViewControllerDelegate{
    func done(value: String, isBusinessProfile: Bool) {
        if isBusinessProfile {
            self.changedStatus = value.isEmpty ? AppConstants.defaultStatus : value
            self.businessBio = changedStatus
            self.businessBioTF.text = changedStatus
            /*
             Feat Name:- add multiple line for bio and address
             Feat Date:- 15/06/21
             Feat By  :- Nikunj C
             description of Feat:- increase view hight according to content
             */
            DispatchQueue.main.async {
                let height = self.heightForView(text: self.businessBioTF.text ?? "", font: UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.businessBioTF.bounds.size.width)
                self.businessBioHeightConstraint.constant = height + 40
                self.businessBioHoldingView.layoutIfNeeded()
            }
        }else{
            self.changedStatus = value.isEmpty ? AppConstants.defaultStatus : value
            userDetails?.status = changedStatus
            self.statusTF.text = changedStatus
            /*
             Feat Name:- add multiple line for bio and address
             Feat Date:- 15/06/21
             Feat By  :- Nikunj C
             description of Feat:- increase view hight according to content
             */
            DispatchQueue.main.async {
                let height = self.heightForView(text: self.statusTF.text ?? "", font: UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.statusTF.bounds.size.width)
                self.statusHeightConstraint.constant = height + 40
                self.statusHoldingView.layoutIfNeeded()
            }
            
        }
    }

        
    func pushingToBusinessBioVc() {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let businessBioVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessBioViewControllerVcId) as! BusinessBioViewController
        if let data = userDetails {
            businessBioVc.businessBio = data.businessDetails.first?.businessBio ?? ""
        }
        self.navigationController?.pushViewController(businessBioVc, animated: true)
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if isCallTextFileBegingEditign { return  false}
        
        isCallTextFileBegingEditign = true
        
        _ = UpdateFieldType(rawValue: textField.tag)
        
        let updateEmailVC : UpdateEmailViewController = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.updateEmailVc) as! UpdateEmailViewController
        updateEmailVC.delegate = self
        view.endEditing(true)
        
        switch textField {
        case self.firstNameTF:
            if let data = userDetails {
                updateEmailVC.value =  data.firstName
            }
            updateEmailVC.currentUpdateField = .firstName
            updateEmailVC.currentBusinessField = .none
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.lastNameTF:
            if let data = userDetails {
                updateEmailVC.value =  data.lastName
            }
            updateEmailVC.currentUpdateField = .lastName
            updateEmailVC.currentBusinessField = .none
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.userNameTF: // username
            if let data = userDetails {
                updateEmailVC.value =  data.userName
            }
            updateEmailVC.currentUpdateField = .userName
            updateEmailVC.currentBusinessField = .none
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.statusTF:
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else {return false}
            updateStatusVC.value =  self.changedStatus
            updateStatusVC.isFromBusiness = false
            updateStatusVC.delegate = self
    //        self.present(updateStatusVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
            return false
        case self.businessBioTF: // status
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else {return false}
            updateStatusVC.value =  self.businessBioTF.text
            updateStatusVC.isFromBusiness = true
            updateStatusVC.delegate = self
    //        self.present(updateStatusVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
            
            return false
        case self.websiteTF: // website
            if let data = userDetails {
                updateEmailVC.value =  data.businessDetails.first?.businessWebsite
            }
            updateEmailVC.isForBusinessProfie = true
            updateEmailVC.currentUpdateField = .none
            updateEmailVC.currentBusinessField = .businessWebsite
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.categoryTF://category
            self.changeBusinessCategoryAction()
            return false
        case self.businessNameTF:
            updateEmailVC.value =  self.businessNameTF.text
            updateEmailVC.isForBusinessProfie = true
            updateEmailVC.currentUpdateField = .none
            updateEmailVC.currentBusinessField = .BusinessName
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.businessUserNameTF:
            updateEmailVC.value =  self.businessUserNameTF.text
            updateEmailVC.isForBusinessProfie = true
            updateEmailVC.currentUpdateField = .none
            updateEmailVC.currentBusinessField = .businessUserName
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        case self.emailTF:
            guard let data = userDetails else { return false }
            Route.naivgateToUpdateEmailPhoneVC(controller: self, navigationController: self.navigationController,userDetails: data,businessEmail:self.businessEmail,email: data.userEmail, isForBusiness: false,isVerified: self.emailStatus)
            return false
        case self.phoneNumberTF:
            guard let data = userDetails else { return false }
            Route.naivgateToUpdateEmailPhoneVC(controller: self, navigationController: self.navigationController,userDetails: data,phoneNumber: data.number, isForBusiness: false, isForPhone: true, countryCode: data.countryCode,isVerified: self.phoneStatus)
            return false
        case self.businessEmailTF:
            Route.naivgateToUpdateEmailPhoneVC(controller: self, navigationController: self.navigationController,userDetails: self.userDetails!,businessEmail:self.businessEmail, isForBusiness: true,isVerified: self.businessEmailStatus)
            return false
        case self.businessPhoneTF:
            Route.naivgateToUpdateEmailPhoneVC(controller: self, navigationController: self.navigationController,userDetails: self.userDetails!,businesPhoneNumber: self.businessPhone, isForBusiness: true, isForPhone: true, countryCode: self.businessCountryCode,isVerified: self.businessphoneStatus)
            return false
        case self.locationTF:
            let storyBoardObj = UIStoryboard.init(name: "AddAddress", bundle: nil)
            if #available(iOS 13.0, *) {
                let searchPlacesViewController = storyBoardObj.instantiateViewController(identifier: "SearchPlacesViewController") as! SearchPlacesViewController
                searchPlacesViewController.notifier = { search in
                    print(search)
                    self.fetchTheAddressPlaceDetails(selectedaddress: search)
                }
                self.present(searchPlacesViewController, animated: true, completion: {})
            } else {
                // Fallback on earlier versions
            }
            return false
        case self.knownAsTF:
            updateEmailVC.value =  self.knownAsTF.text
            updateEmailVC.isForBusinessProfie = false
            updateEmailVC.currentUpdateField = .knownAs
            updateEmailVC.currentBusinessField = .none
            self.navigationController?.pushViewController(updateEmailVC, animated: true)
            return false
        default:
            return true
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        
        switch textField.tag {
        case 1:
            
            return false
            
        case 2:
            self.userDetails?.lastName = txtAfterUpdate
        case 3:
            self.userDetails?.userName = txtAfterUpdate
            return false
        case 4:
            // guard let text = textField.text else{ return true}
            if txtAfterUpdate.count >= 4{
                if txtAfterUpdate == "www."{
                    self.userDetails?.businessDetails.first?.businessWebsite = self.userDetails?.businessDetails.first?.businessWebsite
                    self.businessWebsite = ""
                }else {
                    self.userDetails?.businessDetails.first?.businessWebsite = txtAfterUpdate
                    self.businessWebsite = txtAfterUpdate
                }
                
                return true
            }
            return false
        case 5:
            // guard let text = textField.text else{ return true}
            self.userDetails?.businessDetails.first?.businessBio = txtAfterUpdate
            self.businessBio = txtAfterUpdate
            return true
        case 6:
            // guard let text = textField.text else{ return true}
            self.emailId = txtAfterUpdate
            return true
        default:
            break
        }
        return true
    }

    
}

//MARK:- EditProfileImageTableViewCell delegate and image picker delegate
extension NewEditProfileViewController: EditProfileImageTableViewCellDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,EditProfileSwitchToBusinessTableViewCellDelegate{
    
    func privicyCheckButtonTap(isSelected: Bool) {
        if isSelected{
            self.userDetails?.privicy = 1
        }else{
            self.userDetails?.privicy = 0
        }
    }
    
    func moveToSwitchVc(){
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let SwitchToBusinessVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.SwitchToBusinessVcId) as! SwitchToBusinessViewController
        //        self.navigationController?.pushViewController(SwitchToBusinessVc, animated: true)
        let navigation = UINavigationController.init(rootViewController: SwitchToBusinessVc)
        present(navigation,animated: true)
    }
    func editProfileButtonTap() {
        self.view.endEditing(true)
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.takePhoto.localized, style: .default, handler: { (action) in
            self.openCamera(1)
        }))
        alert.addAction(UIAlertAction(title: Strings.choosePhoto.localized, style: .default, handler: { (action) in
            self.openGallery(1)
        }))
        alert.addAction(UIAlertAction(title: Strings.removePhoto.localized, style: .destructive, handler: { (action) in

            var profileImage = UIImage()
            if let businessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool{
                if businessProfile{
                    profileImage = Helper.getCustomImage(imageDisplayName: self.businessName.uppercased() , imageView: self.profileImageView)
                }else{
                    let username = self.firstName + " " + self.lastName
                    profileImage = Helper.getCustomImage(imageDisplayName: username.uppercased() , imageView: self.profileImageView)
                }
            }else{
                let username = self.firstName + " " + self.lastName
                profileImage = Helper.getCustomImage(imageDisplayName: username.uppercased(), imageView: self.profileImageView)
            }
            
            Helper.saveImage(image: profileImage, name: "defaultProfileImage.png")
            
            self.profileImageUrl = Helper.getSavedImage(name: "defaultProfileImage.png").absoluteString
            self.userDetails?.profilePic = self.profileImageUrl
            }))
        alert.addAction(UIAlertAction(title: Strings.cancel.localized, style: .cancel, handler: { (action) in
            
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(_ tag: Int) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePickerObj.view.tag = tag
            imagePickerObj.navigationBar.tintColor = UIColor.black
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerObj.allowsEditing = false
            imagePickerObj.modalPresentationStyle = .fullScreen
            self.present(imagePickerObj, animated: true, completion: {
                self.checkingCameraPermissions()
            })
        } else {
            self.showAlert(Strings.alert.localized, message: Strings.yourDeviceNotSupportCamera.localized)
        }
    }
    
    func openGallery(_ tag: Int) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            imagePickerObj.navigationBar.tintColor = UIColor.black
            imagePickerObj.view.tag = tag
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.photoLibrary;
            imagePickerObj.allowsEditing = false
            imagePickerObj.modalPresentationStyle = .fullScreen
            self.present(imagePickerObj, animated: true, completion: {
                self.checkingCameraPermissions()
            })
        }
    }
    
    /// Checking Camera Permissions
    func checkingCameraPermissions(){
        let cameraMediaType = convertFromAVMediaType(AVMediaType.video)
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: cameraMediaType))
        switch cameraAuthorizationStatus {
        case .denied:
            self.showdefaultAlert(title: "Permission Denied".localized, message: AppConstants.cameraPermissionMsg)
        case .authorized:
            break
        case .restricted:
            self.showdefaultAlert(title: "Permission Denied".localized, message: AppConstants.cameraPermissionMsg)
        default:
            break
        }
    }
    
    /// Showing alert ,if camera disabled
    ///
    /// - Parameters:
    ///   - title: Alert
    ///   - message: if camera permission disabled ,Showing alert on imagepicker obj
    func showdefaultAlert(title : String ,message : String){
        let alert =  UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (cancel) in
            self.imagePickerObj.dismiss(animated: true, completion: nil)
        }
        let settingsAction = UIAlertAction.init(title: "Settings".localized, style: .default) { (settings) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        }
        alert.addAction(action1)
        alert.addAction(settingsAction)
        imagePickerObj.present(alert, animated: true, completion: nil)
    }
    
    
    
    //    /// Removing Profile Pic
    //    func updatePrivatePublicAccount(){
    //        let params = ["private": privateAccount
    //            ] as [String : Any]
    //        UpdateProfileApi.updateUserProfile(params: params) { (dict) in
    //            Helper.hidePI()
    //
    //        }
    //
    //    }
    //
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4Ø.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        self.view.endEditing(true)
        if picker.view.tag == 1{
            print("update profile")
            if #available(iOS 11.0, *) {
                //                self.profileImageUrl = info[UIImagePickerControllerImageURL] as? URL
                //                self.selectedProfileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            } else {
                // Fallback on earlier versions
            }
            croppingStyle = CropViewCroppingStyle.circular
            let cropController = CropViewController(croppingStyle: croppingStyle, image: (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!)
            self.profilePicChanged = true
            cropController.delegate = self
            cropController.aspectRatioPreset = .presetSquare;
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            picker.dismiss(animated: true, completion: {
                cropController.modalPresentationStyle = .fullScreen
                self.present(cropController, animated: true, completion: nil)
            })
            
            self.dismiss(animated: true, completion: nil)
            
        }else{
            print("update cover")
            if #available(iOS 11.0, *) {
                //                self.coverImageUrl = info[UIImagePickerControllerImageURL] as? URL
                //                self.selectedCoverImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            } else {
                // Fallback on earlier versions
            }
            croppingStyle = CropViewCroppingStyle.default
            let cropController = CropViewController(croppingStyle: croppingStyle, image: (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)!)
            self.coverPicChanged = true
            cropController.delegate = self
            cropController.aspectRatioPreset = .preset16x9;
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            picker.dismiss(animated: true, completion: {
                cropController.modalPresentationStyle = .fullScreen
                self.present(cropController, animated: true, completion: nil)
            })
            
        }
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.enableSaveAction()
        if cropViewController.croppingStyle == .circular {
            cropViewController.dismiss(animated: true, completion: nil)

            self.profileImageView.image = image
            self.profileImageView.contentMode = .scaleAspectFit
            self.selectedProfileImage = image
            self.profileImageUrl = self.saveImageToDocumentDirectory(selectedProfileImage)
            }else{
            cropViewController.dismiss(animated: true, completion: nil)
                  
            self.coverImageView.image = image
            self.coverImageView.contentMode = .scaleAspectFill
            self.selectedCoverImage = image
            self.coverImageUrl = self.saveImageToDocumentDirectory(selectedCoverImage)
            }
    }
    
    
    func uploadingCoverPic(complitation: @escaping(Bool)->Void){
        if #available(iOS 11.0, *) {
            if coverImageUrl != nil{
                guard let imgUrl =  coverImageUrl else{
                    //   print("Faild to get image url")
                    complitation(true)
                    return
                }
                guard let url = URL(string: imgUrl) else {return}
                guard let imageData = NSData(contentsOf: url) else {return}
                guard let image = UIImage(data: imageData as Data) else {return}
                var folder = CloudinaryFolder.coverImage
                if Utility.isActiveBusinessProfile(){
                    folder = CloudinaryFolder.businessCoverImage
                }
                
                CloudinaryManager.sharedInstance.uploadImage(image: image, folder: folder,publicId: Utility.getUserid()!, isForCover: true,compressionQuality: 0.5) { (result,error) in
                    
                    if error != nil {
                        print("cloudinary error ===",error?.localizedDescription ?? "")
                        Helper.hidePI()
                        complitation(false)
                    }else{
                        Helper.hidePI()
                        self.isProfileChanged = true
                        guard let data = self.userDetails else{return}
                        var coverImageUrl = data.coverImage
                        KingfisherManager.shared.cache.removeImage(forKey: coverImageUrl ?? "")
                        if let url = result?.url{
                            coverImageUrl = url.replace(target: "upload/", withString: "upload/q_60/")
                            DispatchQueue.main.async {
                                if Utility.isActiveBusinessProfile() {
                                    self.userDetails?.businessDetails.first?.businessCoverImage = coverImageUrl
                                }else{
                                    self.userDetails?.coverImage = coverImageUrl
                                }
                                complitation(true)
                            }
                        }
                    }
                }
            }else{
                complitation(true)
            }
        }
        
    }
    
    func uploadingProfilePic(complitation: @escaping(Bool)->Void){
        if #available(iOS 11.0, *) {
            
            if profileImageUrl != nil && profileImageUrl != ""{
                guard let imgUrl = profileImageUrl else{
                    // print("Faild to get image url")
                    complitation(true)
                    return
                }
                guard let url = URL(string: imgUrl) else {return}
                guard let imageData = NSData(contentsOf: url) else {return}
                guard let image = UIImage(data: imageData as Data) else {return}
    
                var folder = CloudinaryFolder.profileImage
                if Utility.isActiveBusinessProfile(){
                    folder = CloudinaryFolder.businessProfileImage
                }
                
                CloudinaryManager.sharedInstance.uploadImage(image: image, folder: folder,publicId: Utility.getUserid()!,compressionQuality: 0.5) { (result, error) in
                    if error != nil {
                        print("cloudinary error ===",error?.localizedDescription ?? "")
                        Helper.hidePI()
                        complitation(false)
                    }else{
                        Helper.hidePI()
                        guard let data = self.userDetails else{return}
                        var profileImageUrl = data.profilePic
                        self.isProfileChanged = true
                        KingfisherManager.shared.cache.removeImage(forKey: profileImageUrl ?? "")
                        
                        if let url = result?.url{
                            profileImageUrl = url
                        }
                        
                        if Utility.isActiveBusinessProfile(){
                            self.userDetails?.businessDetails.first?.businessProfileImage = profileImageUrl
                        }else{
                            self.userDetails?.profilePic = profileImageUrl
                        }
                        complitation(true)
                    }
                }

            } else {
                // Fallback on earlier versions
                complitation(true)
            }
        }
    }
    

    
    func saveImageToDocumentDirectory(_ chosenImage: UIImage) -> String? {
        let directoryPath =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let filename = dateFormatter.string(from: Date()).appending(".jpeg")
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try chosenImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            let string = url.absoluteString
            return string//String.init("/Documents/\(filename)")
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return nil
        }
    }
}

extension NewEditProfileViewController: EditPrivateAccountCellDelegate{
    
    /// switching to private account
    func switchingToPrivateAccount() {
        if let isBusinessProfile = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
            if isBusinessProfile {
                if self.switchOutlet.isOn{
                    Helper.showAlertViewOnWindow(Strings.message.localized, message: Strings.businessPrivateAccoutMessage)
                }else {
                    print("public Account")
                }
            }else{
            }
        }
        if self.switchOutlet.isOn {
            self.userDetails?.privicy = 1
        }else {
            self.userDetails?.privicy = 0
        }
        
    }
    
}

extension NewEditProfileViewController : UpdateEmailViewControllerDelegate{
    func updateDone(fieldType : UpdateBusinessFieldType, value : String, countryCode : String) {
    }
    func updateDone(fieldType: UpdateBusinessFieldType, value: String) {
        switch fieldType {
        case .businessWebsite:
            self.businessWebsite = value
            self.websiteTF.text = value
        case .BusinessName:
            self.businessName = value
            self.businessNameTF.text = value
        case .businessUserName:
            self.businessUserNameTF.text = value
            break
        default:
            break
        }
        isCallTextFileBegingEditign = false
    }
    
    func updateDone(fieldType: UpdateFieldType, value: String) {
        switch fieldType {
        case .firstName:
            userDetails?.firstName =  value
            self.firstNameTF.text = value
        case  .lastName:
            userDetails?.lastName = value
            self.lastNameTF.text = value
        case .userName:
            userDetails?.userName = value
            self.userNameTF.text = value
        case .mobile:
            userDetails?.number = value
            self.phoneNumberTF.text = value
        case .email:
            userDetails?.userEmail = value
            self.emailTF.text = value
        case .knownAs:
            self.knownAsTF.text = value
        default: break
            
        }
        isCallTextFileBegingEditign = false
//        editProfileTableView.reloadData()
    }
    func updateDone(fieldType: UpdateFieldType, value: String, countryCode : String) {

        switch fieldType {
        case .firstName:
            userDetails?.firstName =  value
        case  .lastName:
            userDetails?.lastName = value
        case .userName:
            userDetails?.userName = value
        case .mobile:
            userDetails?.number = value
            userDetails?.countryCode = countryCode
            self.phoneNumberTF.text = countryCode + value
        case .email:
            userDetails?.userEmail = value
        default: break
            
        }
        isCallTextFileBegingEditign = false
//        editProfileTableView.reloadData()
    }
    
}

//MARK:- NewEditPhoneNumberViewController delegate
extension NewEditProfileViewController: EditPhoneNumberViewControllerDelegate , BusinessProfileDelegate, BusinessContactInfoDelegate,saveDetailsToNewEditProfile{
    
    /*
     Refactor Name:- update profile while save value
     Refactor Date:- 19/05/21
     Refactor By  :- Nikunj C
     Description of Refactor:- change email and phone number value
     */
    
    func changedDetails(businessEmail: String, businessPhone: String, businessCountryCode: String, isforEmail: Bool) {
        
        if let businessData = self.userDetails?.businessDetails.first {
            
            if isforEmail{
                self.businessEmail = businessEmail
                self.businessEmailTF.text = businessEmail
                
            }else{
                self.businessCountryCode = businessCountryCode
                self.businessPhone = businessPhone
                self.businessPhoneTF.text = "\(businessCountryCode)\(businessPhone)"
                businessData.businessPhone?.isVerified = 1
                self.businessPhoneVerificationStatusLabel.text = "Verified".localized + " !"
                self.businessPhoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
                self.businessPhoneVerificationImageView.image = #imageLiteral(resourceName: "verified_profile")
            }
            
        }
      
        
    }
    
    /*
     Feat Name:- for normal user should show verified label
     Feat Date:- 10/07/21
     Feat By  :- Nikunj C
     Description of Fix:- show email
     */
    func changeNormalUserDetails(email: String, phone: String, countryCode: String, isforEmail: Bool) {
        if isforEmail{
            self.emailTF.text = email
        }else{
            self.phoneNumberTF.text = "\(countryCode)\(phone)"
            self.phoneVerificationStatusLabel.text = "Verified".localized + " !"
            self.phoneVerificationStatusLabel.textColor = #colorLiteral(red: 0.06470585614, green: 0.7891405225, blue: 0.06970766932, alpha: 1)
            self.phoneVerificationStatusImageView.image = #imageLiteral(resourceName: "verified_profile")
        }
        
    }
    
    func fetchTheAddressPlaceDetails(selectedaddress : Places){
        if let placeid = selectedaddress.placeId , placeid.count != 0
        {
            let urlString = String(format: ServiceManager.PlaceEnlarge,placeid)
            ServiceManager.fetchLocationwithplaceId(from: urlString) { placeFrom in
                if placeFrom.count > 0
                {
                    
                    /*
                     Bug Name:- address are not saved
                     Fix Date:- 15/06/21
                     Fixed By:- Nikunj C
                     description of Fix:- add required content
                     */
                    
                    DispatchQueue.main.async {
                        let latitude =  (((placeFrom.value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat") as! NSNumber)
                        let longitude =  (((placeFrom.value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng") as! NSNumber)
                        self.businessLat = "\(latitude)"
                        self.businessLang = "\(longitude)"
                        if let addressComponent = placeFrom["address_components"] as? [[String:Any]] {
                            DispatchQueue.main.async {
                                for item in addressComponent {
                                    if let types = item["types"] as? [String] {
                                        if types.contains("country") {
                                            self.businessCountry = item["long_name"] as? String ?? ""
                                        }else if types.contains("postal_code") {
                                            self.businessZipCode = item["long_name"] as? String ?? ""
                                        }else if types.contains("locality") {
                                            self.businessCity = item["long_name"] as? String ?? ""
                                        }
                                    }
                                }
                            }
                        }
                        
                        self.businessStreetAddress = selectedaddress.name ?? ""
                        let  businessUniqueId  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessUniqueId) as? String ?? ""
                       let params = ["BusinessAddress": "\(self.businessStreetAddress),\(self.businessCity),\(self.businessZipCode)",
                        "businessStreet": self.businessStreetAddress,
                        "businessCity": self.businessCity,
                        "businessZipCode": self.businessZipCode,
                        "businessUniqueId" : businessUniqueId,
                        "businessLat": self.businessLat,
                        "businessLng": self.businessLang
                       ]
                        
                        self.updateEmailPhoneVMObject.updateProfile(params: params) { (dict) in
                            self.locationTF.text = "\(self.businessStreetAddress),\(self.businessCity),\(self.businessZipCode)"
                            /*
                             Feat Name:- add multiple line for bio and address
                             Feat Date:- 15/06/21
                             Feat By  :- Nikunj C
                             description of Feat:- increase view hight according to content
                             */
                            DispatchQueue.main.async {
                                let height = self.heightForView(text: self.locationTF.text ?? "", font:UIFont(name: "ProductSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), width: self.locationTF.bounds.size.width)
                                self.locationVIewHeightConstraint.constant = height + 40
                                self.businessLocationHoldingView.layoutIfNeeded()
                            }
                        }
                        
                    }
                        
                    
                }
            }
        }
    }
    
    func changeBusinessConatactOptionsAction() {
        /// Pushing To BusinessMobileConfigurationViewController
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let businessContactsVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessEditContactOptionsVcId) as! BusinessEditContactOptionsViewController
        businessContactsVcId.mobileNumber = self.businessPhone
        businessContactsVcId.email = self.businessEmail
        businessContactsVcId.countryCode = self.businessCountryCode
        businessContactsVcId.streetAddress = self.businessStreetAddress
        businessContactsVcId.cityTown = self.businessCity
        businessContactsVcId.zipCode = self.businessZipCode
        businessContactsVcId.businessCategoryId = self.businessCategoryid
        self.navigationController?.pushViewController(businessContactsVcId, animated: true)
    }
    
    func gettingBusinessCategoryNameAndId(businessCategoryName: String, businessCategoryId: String) {
        self.businessCategoryid = businessCategoryId
        self.businessCategoryName = businessCategoryName
        self.categoryTF.text = businessCategoryName
//        self.editProfileTableView.reloadData()
    }
    
    
    /// Passing Business Address Through Protocol Delegate
    ///
    /// - Parameters:
    ///   - streetAddress: streetAddress String
    ///   - zipCode: zipCode String
    func gettingBusinessAddress(streetAddress: String,placeAddress:String, zipCode: String,lat: String, lang:String) {
        self.businessStreetAddress = streetAddress
        self.businessZipCode = "\(zipCode)"
        self.businessCity = "\(placeAddress)"
        
        /*
         Feat Name:- add error label instead of popup.
         Feat Date:- 14/05/21
         Feat By  :- Nikunj C
         Description of Feat:- hide error label when select address
         */
        
//        let indexPath = IndexPath.init(row: 5, section: 0)
//        if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoAddressTextviewCell{
//            cell.titleLabel.isHidden = false
//            cell.errorLabel.isHidden = true
//        }
//        self.isValidAddress = true
//        self.checkingAllRequiredFields()
    }
    
    func changeBusinessCategoryAction() {
        let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
        let businessCategoryVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessCategoryViewControllerId) as! BusinessCategoryViewController
        businessCategoryVc.categoryName = self.businessCategoryName
        businessCategoryVc.businessProfileDelegate = self
        //        businessCategoryVc.businessProfileDelegate = self
        self.navigationController?.pushViewController(businessCategoryVc, animated: true)
        
    }
    
    
    func isPhoneNumberupdated(){
        self.isChanged = true
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
    return input.rawValue
}
