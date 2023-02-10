//
//  BusinessContactInfoViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/23/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G

import UIKit
import Cloudinary
import Kingfisher
import IQKeyboardManagerSwift
class BusinessContactInfoViewController: UIViewController,UIGestureRecognizerDelegate{
    
    //MARK:- Outlets
    @IBOutlet weak var businessContactInfoTableView: UITableView!
    
 
    @IBOutlet weak var coverImageBtn: UIButton!
    @IBOutlet weak var profileImageBtnAction: UIButton!
    @IBOutlet weak var businessProfileImage: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var businessCoverImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    //MARK:- Constants&Declarations
    var businessFullAddress:String?
    var businessStreetAddress = ""
    var businessZipCode = ""
    var placeAddress = ""
    var doneToolbar = UIToolbar()
    var phoneTextField = UITextField()
    var businessContactInfoVmObject = BusinessContactInfoViewModel()
    let profileVmObject = ProfileViewModel() // Used for profileViewModel Object Reference
    var isFirstTime: Bool = false
    var businessEmail:String?
    var businessPhone:String?
    var isValidNumber: Bool = false                // Used to check the entered Number isValid or not
    var countryCode:String?                // Used to Store current country name
    var countryImageView:UIImage?
//    var accountKit:AccountKitManager!
    var textFieldHeight:CGFloat = 40
    var isPhoneNumberIsVisible:Bool = false
    var businessBio = ""
    var businessLat:Float = 0.0
    var businessLang:Float = 0.0
    var businessCity:String = ""
    var businessState:String = ""
    var businessCountry:String = ""
    let imagePickerObj = UIImagePickerController()
    var croppingStyle = CropViewCroppingStyle.default
    var selectedProfileImage : UIImage!
    var selectedCoverImage : UIImage!
    var profileImageUrl:String?
    var coverImageUrl:String?
    var profileImageString:String?
    var coverImageString:String?
    var profileImage:UIImage?
    var coverImage:UIImage?
    var userStatus:String?
    var isUserNameExist:Bool = false
    var businessContactTextViewCell:BusinessContactTextViewCell?
    var businessContactInfoTextCell:BusinessContactInfoTextCell?
    
    /*
     Refactor Name:- only enable next button if all details are correct
     Refactor Date:- 15/05/21
     Refactor   By:- Nikunj C
     Description of Refactor:- various properties used for enable/disable next button
     */
    
    var isMessageForEmail:Bool = false // use to handle api "business/emailPhoneVerification" 's response
    
    var isValidUserName:Bool = false
    var isValidName:Bool = false
    var isValidEmail:Bool = false
    var isValidPhoneNumber:Bool = false
    var isValidCategory:Bool = false
    var isValidAddress:Bool = false
    var isValidWebsite:Bool = false
    var isValidBio:Bool = false
    

    //MARK:- ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
      
        IQKeyboardManager.shared.enable = true
        self.businessProfileImage.makeCornerRadious(readious: self.businessProfileImage.frame.size.width / 2)
        /*
         Feat Name:- default userStatus should be use in Bussiness Profile
         Feat Date:- 24/04/21
         Feat By  :- Nikunj C
         Description of Feat:- get userStatus from userdefault
         */
 
        self.businessContactInfoVmObject.isPhoneNumberVisible = isPhoneNumberIsVisible

        self.businessContactInfoVmObject.isPhoneNumberVisible = isPhoneNumberIsVisible
        

        
        addDoneButtonOnKeyboard()
       
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        self.getUserDetails()
        uiDesign()
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        self.businessContactInfoTableView.reloadData()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !self.isFirstTime{
            self.isFirstTime = true
        }
        /*
         Bug Name:- toast not appear sometime
         Fix Date:- 16/04/21
         Fix By  :- Nikunj C
         Description of Fix:- refactor extra code
         */
        Helper.checkConnectionAvaibility(view: self.view)
        
    }
    
   
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    //MARK:- UIDesign
    func uiDesign(){
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.businessProfileContactInfo.localized)
        self.descriptionLbl.text = "Edit or remove any information that you do not wish to display".localized
        self.nextButton.setTitle("Submit".localized, for: .normal)
    }
    
    /*
     Refactor Name:- only enable next button if all details are correct
     Refactor Date:- 15/05/21
     Refactor   By:- Nikunj C
     Description of Refactor:- function used to make next button enable/disable
     */
    
    func checkingAllRequiredFields(){
        if self.isValidUserName && self.isValidName && self.isValidEmail && self.isValidPhoneNumber && self.isValidCategory && self.isValidAddress && self.isValidWebsite && self.isValidBio {
            self.nextButton.isEnabled = true
            self.nextButton.backgroundColor = Utility.appColor()
        }else{
            self.nextButton.isEnabled = false
            self.nextButton.backgroundColor = .lightGray
        }
    }
    
    
    // Adding Done Button Function
    func addDoneButtonOnKeyboard(){
        doneToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: Strings.done.localized, style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
    }
    
    
    @IBAction func countryBtnAction(_ sender: Any) {
        let countryPicker = CountryPickerVC.instantiate(storyBoardName: "Authentication") as CountryPickerVC
        countryPicker.currentCountryCode = self.countryCode
        countryPicker.countryDataDelegate = self
        present(countryPicker, animated: true, completion: nil)

    }
    
    /*
     Refactor Name:- only enable next button if all details are correct
     Refactor Date:- 15/05/21
     Refactor   By:- Nikunj C
     Description of Refactor:- next button action
     */
    
    @IBAction func nextBtnAction(_ sender: Any) {
        self.createBusinessAccountPostApiCall()
        
    }
    /// Done Button Action On ToolBar
    @objc func doneButtonAction(){
        phoneTextField.resignFirstResponder()
    }
    
    
    /// Api Call For Create Business Account
    func createBusinessAccountPostApiCall()
    {
        let url = AppConstants.businessRequest
       
        Helper.showPI()
        self.uploadingProfilePic(categoryId: self.businessContactInfoVmObject.businessCategoryId!) { (success) in
            if success {
                self.businessContactInfoVmObject.profileImageURL = self.profileImageString
                self.uploadingCoverPic(categoryId:  self.businessContactInfoVmObject.businessCategoryId!) { (success) in
                    if success {
                        DispatchQueue.main.async {
                            Helper.hidePI()
                        }
                        self.businessContactInfoVmObject.coverImageURL = self.coverImageString
                        self.businessContactInfoVmObject.businessAccountApiCall(strUrl: url) { (isSucces, error) in
                            if isSucces {
                                DispatchQueue.main.async {
                                    Helper.hidePI()
                                     UserDefaults.standard.set(self.businessContactInfoVmObject.phoneNumber, forKey: AppConstants.UserDefaults.businessMobileNumber)
                                     UserDefaults.standard.set(self.businessContactInfoVmObject.businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
                                     let customAlert = BusinessCustomAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
                                     customAlert.tag = 15
                                     customAlert.delegete = self
                                     appDelegetConstant.window.addSubview(customAlert)
                                     customAlert.popUpAnimation()

                                }
                            }
                            else if error != nil{
                               Helper.hidePI()
                           }
                        }
                    }
                }
            }
        }
        
        return

//        self.businessContactInfoVmObject.checkingAllRequiredFields { (allFieldsEntered) in
//            if allFieldsEntered{
//                self.businessContactInfoVmObject.businessAccountApiCall(strUrl: url) { (success, error) in
//                    if success{
//                             self.uploadingProfilePic(categoryId: self.businessContactInfoVmObject.businessCategoryId!, complitation: { (success) in
//                                if success{
//                                print("profile image updated")
//                                    self.uploadingCoverPic(categoryId: self.businessContactInfoVmObject.businessCategoryId!, complitation: { (success) in
//                                        print("cover image updated")
//                                        /* Bug Name : Crashing while submit to businessprofile
//                                         Fix Date : 06-Apr-2021
//                                         Fixed By : Jayaram G
//                                         Description Of Fix : Application crashing due to threads ,so presenting ui on main thread
//                                         */
//                                        DispatchQueue.main.async {
//                                            Helper.hidePI()
//                                             UserDefaults.standard.set(self.businessContactInfoVmObject.phoneNumber, forKey: AppConstants.UserDefaults.businessMobileNumber)
//                                             UserDefaults.standard.set(self.businessContactInfoVmObject.businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
//                                             let customAlert = BusinessCustomAlertView.init(frame: CGRect.init(x: 0, y: 0, width: (appDelegetConstant.window.bounds.width), height: (appDelegetConstant.window.bounds.height)))
//                                             customAlert.tag = 15
//                                             customAlert.delegete = self
//                                             appDelegetConstant.window.addSubview(customAlert)
//                                             customAlert.popUpAnimation()
//
//                                        }
//                                    })
//                                }
//                             })
//                        //   UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
//
//                     }else if let error = error{
//                        Helper.hidePI()
////                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
//                    }
//
//                }
//            }
//        }
    }
    
    
    
    func uploadingCoverPic(categoryId:String,complitation: @escaping(Bool)->Void){
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
                
                
                CloudinaryManager.sharedInstance.uploadImage(image: image, folder: .businessCoverImage,publicId: Utility.getUserid()!,isForCover: true) { (result, error) in
                    if error != nil {
                        print("cloudinary error ===",error?.localizedDescription ?? "")
                        Helper.hidePI()
                        complitation(false)
                    }else{
                        if let url = result?.url{
                            KingfisherManager.shared.cache.removeImage(forKey: url)
                            DispatchQueue.main.async {
                                self.coverImageString = url
                                complitation(true)
                            }
                        }
                    }
                }
                
            }else {
                // Fallback on earlier versions
                complitation(true)
            }
        }
        
    }
    
    func uploadingProfilePic(categoryId:String,complitation: @escaping(Bool)->Void){
        if #available(iOS 11.0, *) {
            
            if profileImageUrl != nil{
                guard let imgUrl = profileImageUrl else{
                    // print("Faild to get image url")
                    complitation(true)
                    return
                }
                                
                guard let url = URL(string: imgUrl) else {return}
                guard let imageData = NSData(contentsOf: url) else {return}
                guard let image = UIImage(data: imageData as Data) else {return}
                                
                CloudinaryManager.sharedInstance.uploadImage(image: image, folder: .businessProfileImage,publicId: Utility.getUserid()!) { (result, error) in
                    if error != nil {
                        print("cloudinary error ===",error?.localizedDescription ?? "")
                        Helper.hidePI()
                        complitation(true)
                    }else{
                        if let url = result?.url{
                            let imageUrl = url.replace(target: "upload/", withString: "upload/q_80/")
                            KingfisherManager.shared.cache.removeImage(forKey: imageUrl)
                            DispatchQueue.main.async {
                                self.profileImageString = imageUrl
                                complitation(true)
                            }
                        }
                    }
                }
                
            }else {
                // Fallback on earlier versions
                complitation(true)
            }
        }
    }
    
    @IBAction func editCoverImageAction(_ sender: UIButton) {
        //editProfileButtonTap()
        let alert = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.takePhoto.localized, style: .default, handler: { (action) in
            self.openCamera(2)
        }))
        alert.addAction(UIAlertAction(title: Strings.choosePhoto.localized, style: .default, handler: { (action) in
            self.openGallery(2)
        }))
        
        alert.addAction(UIAlertAction(title: Strings.removePhoto.localized, style: .destructive, handler: { (action) in
            
            /*Refactor Name :- change default cover image
              Fix Date :- 24/03/2021
              Fixed By :- Nikunj C
              Description Of refactor :- add default banner */
            self.selectedCoverImage = UIImage.init(named: Strings.ImageNames.defaultBannerpng)
            self.businessCoverImage.image = UIImage.init(named: Strings.ImageNames.defaultBannerpng)
            self.coverImage = self.selectedCoverImage
            Helper.saveImage(image: self.selectedCoverImage, name: "defaultCoverImage.png")
            self.coverImageUrl = Helper.getSavedImage(name: "defaultCoverImage.png").absoluteString
            

            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
             
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel".localized.localized, style: .cancel, handler: { (action) in
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editProfilePicButton(_ sender: UIButton) {
        editProfileButtonTap()
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
            self.selectedProfileImage = UIImage.init(named: Strings.ImageNames.defaultImagepng)
            self.profileImageUrl = Bundle.main.url(forResource: Strings.ImageNames.defaultImage, withExtension: "png")?.absoluteString
            self.profileImage = nil
            self.businessProfileImage.image = self.selectedProfileImage
                        
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized.localized, style: .cancel, handler: { (action) in
            
            
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openCamera(_ tag: Int) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePickerObj.view.tag = tag
            imagePickerObj.navigationBar.tintColor = UIColor.black
            imagePickerObj.delegate = self
            imagePickerObj.sourceType = UIImagePickerController.SourceType.camera;
            imagePickerObj.allowsEditing = false
            imagePickerObj.modalPresentationStyle = .fullScreen
            self.present(imagePickerObj, animated: true, completion: nil)
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
            self.present(imagePickerObj, animated: true, completion: nil)
        }
    }
    
    /// Pushing To Profile ViewController
    func didDonecliked() {
        let customalertView = appDelegetConstant.window.viewWithTag(15)
        customalertView?.popDownAnimation(animationDone: { (finished) in
            if let profileVc = self.navigationController?.viewControllers.filter({$0.isKind(of: ProfileViewController.self)}).first as? ProfileViewController{
                self.navigationController?.popToViewController(profileVc, animated: true)
            }
            /* Bug Name :  notnavigating to home screen after clicking on ok button
             Fix Date : 06-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : added navigation to pop to rootviewcontroller
             */
            if let homeVc = self.navigationController?.viewControllers.filter({$0.isKind(of: PostDetailsViewController.self)}).first as? PostDetailsViewController{
                self.navigationController?.popToViewController(homeVc, animated: true)
            }
        })
    }

    

}

//MARK:- Extensions

// TableView Extension

// MARK: - UITableViewDelegate, UITableViewDataSource,BusinessContactCellDelegate,BusinessProfileDelegate,BusinessContactInfoDelegate,BusinessCustomViewdelegte
extension BusinessContactInfoViewController: UITableViewDelegate, UITableViewDataSource,BusinessProfileDelegate,BusinessContactInfoDelegate,BusinessCustomViewdelegte{
  
    
    
    /// Passing Business Address Through Protocol Delegate
    ///
    /// - Parameters:
    ///   - streetAddress: streetAddress String
    ///   - zipCode: zipCode String
    func gettingBusinessAddress(streetAddress: String,placeAddress:String, zipCode: String,lat: String, lang:String) {
        self.businessStreetAddress = streetAddress
        self.businessZipCode = "\(zipCode)"
        self.placeAddress = "\(placeAddress)"
        
        /*
         Feat Name:- add error label instead of popup.
         Feat Date:- 14/05/21
         Feat By  :- Nikunj C
         Description of Feat:- hide error label when select address
         */
        
        let indexPath = IndexPath.init(row: 5, section: 0)
        if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoAddressTextviewCell{
            cell.titleLabel.isHidden = false
            cell.errorLabel.isHidden = true
        }
        self.isValidAddress = true
        self.checkingAllRequiredFields()
    }
    
    
    /// Storing Business Category name and id
    ///
    /// - Parameters:
    ///   - businessCategoryName: businessCategoryName string
    ///   - businessCategoryId: businessCategoryId string
    func gettingBusinessCategoryNameAndId(businessCategoryName: String, businessCategoryId: String) {
        self.businessContactInfoVmObject.businessCategoryName = businessCategoryName
        self.businessContactInfoVmObject.businessCategoryId = businessCategoryId
        
        /*
         Feat Name:- add error label instead of popup.
         Feat Date:- 14/05/21
         Feat By  :- Nikunj C
         Description of Feat:- hide error label when select category
         */
        
        let indexPath = IndexPath.init(row: 4, section: 0)
        if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
            cell.errorLabelHeightConstraint.constant = 0
            cell.errorLabel.isHidden = true
            cell.heightConstraint?.constant = 78
        }
        self.isValidCategory = true
        self.checkingAllRequiredFields()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 9 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactInfoHeaderCellId , for: indexPath) as! BusinessContactInfoHeaderCell
            return headerCell
        }else if indexPath.row == 8 {
            let detailsTextCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactInfoDetailsTextCellId , for: indexPath) as! BusinessContactInfoDetailsTextCell
            return detailsTextCell
        }else if indexPath.row == 7{
            let textviewCell = tableView.dequeReusableCell(withIdentifier: AppConstants.CellIds.BusinessContactInfoAddressTextviewCellId, indexPath: indexPath) as! BusinessContactInfoAddressTextviewCell
            if !textviewCell.isBioChanged{
                DispatchQueue.main.async {
                    textviewCell.setPlaceholder(placeHolder: Strings.aboutBusiness.localized)
                }
            }
            textviewCell.addressTextView.text = businessContactInfoVmObject.businessBio
            textviewCell.businessContactInfoTextCellDelegate = self
            textviewCell.titleLabel.text = Strings.aboutBusiness.localized
            textviewCell.contactInfoButtonOutlet.tag = 8
            return textviewCell
        }else if indexPath.row == 10 {
            let privateAccountCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactInfoPrivateAccountCellId , for: indexPath) as! BusinessContactInfoPrivateAccountCell
            
            if let privacy = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isPrivate) as? Int{
                if privacy == 0 {
                    businessContactInfoVmObject.privateAccount = 0
//                    privateAccountCell.switchOutlet.isEnabled = false
                    privateAccountCell.switchOutlet.isOn = false
                }else {
                    businessContactInfoVmObject.privateAccount = 1
//                    privateAccountCell.switchOutlet.isEnabled = true
                    privateAccountCell.switchOutlet.isOn = true
                }
            }
            privateAccountCell.privateAccountCellDelegate = self
            return privateAccountCell
        }else if indexPath.row == 5{
            
            /*
             Refactor Name:- make address multiple line
             Refactor Date:- 15/05/21
             Refactor   By:- Nikunj C
             Description of Refactor:- setup for address textview
             */
            
            let textviewCell = tableView.dequeReusableCell(withIdentifier: AppConstants.CellIds.BusinessContactInfoAddressTextviewCellId, indexPath: indexPath) as! BusinessContactInfoAddressTextviewCell
            if !textviewCell.isAddressChanged{
                DispatchQueue.main.async {
                    textviewCell.setPlaceholder(placeHolder: Strings.address.localized)
                }
            }
            
            textviewCell.contactInfoButtonOutlet.tag = 6
            textviewCell.businessContactInfoTextCellDelegate = self
            textviewCell.titleLabel.text = Strings.address.localized
            if let fullAddress = "\(businessStreetAddress)  \(placeAddress) \(businessZipCode)" as? String{
                if fullAddress.replace(target: " ", withString: "").count == 0{
                    textviewCell.addressTextView.text = ""
                }else {
                      self.businessFullAddress = fullAddress
                    self.businessContactInfoVmObject.businessStreetAddress = businessStreetAddress
                    self.businessContactInfoVmObject.businessLat = self.businessLat
                    self.businessContactInfoVmObject.businessLang = self.businessLang
                    self.businessContactInfoVmObject.businessCity = placeAddress
                    self.businessContactInfoVmObject.businessZipCode = businessZipCode
//                    self.businessContactInfoVmObject.address = fullAddress
                    textviewCell.addressTextView.text = fullAddress
                }
            }
            
            return textviewCell
        }else if indexPath.row == 6 {
             let textViewCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactTextViewCellId , for: indexPath) as! BusinessContactTextViewCell
            textViewCell.contactInfoTextField.placeholder = Strings.webSite.localized
            textViewCell.contactInfoTextField.text = businessContactInfoVmObject.businessWebsite
            textViewCell.contactInfoTextField.tag = 7
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            
            self.businessContactInfoVmObject.BusinessContactTextViewCellDic[indexPath.row] = textViewCell
            return textViewCell
        }else if indexPath.row == 0 {
            guard let textViewCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactTextViewCellId , for: indexPath) as? BusinessContactTextViewCell else {return UITableViewCell()}
            textViewCell.contactInfoTextField.placeholder = "Enter Business User Name".localized
            textViewCell.contactInfoTextField.text = businessContactInfoVmObject.businessUserName
            textViewCell.contactInfoTextField.tag = 1
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            self.businessContactInfoVmObject.BusinessContactTextViewCellDic[indexPath.row] = textViewCell
             return textViewCell
         }else if indexPath.row == 1 {
            let textViewCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactTextViewCellId , for: indexPath) as! BusinessContactTextViewCell
             textViewCell.contactInfoTextField.placeholder = Strings.businessName.localized
            textViewCell.contactInfoTextField.text = businessContactInfoVmObject.businessName
            textViewCell.contactInfoTextField.tag = 2
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            self.businessContactInfoVmObject.BusinessContactTextViewCellDic[indexPath.row] = textViewCell
             return textViewCell
         }
        
        let textCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessContactInfoTextCellId , for: indexPath) as! BusinessContactInfoTextCell
        textCell.textFieldOutlet.delegate = self
        textCell.arrowImageOutlet.isHidden = false
        textCell.businessContactInfoTextCellDelegate = self
        textCell.countryLabel.text =  ""
        switch indexPath.row {
         case 2:   // email field
            textCell.contactInfoButtonOutlet.isHidden = true
            textCell.textFieldOutlet.placeholder = Strings.email.localized
             if businessContactInfoVmObject.businessEmail != nil{
                textCell.textFieldOutlet.text =  self.businessContactInfoVmObject.businessEmail
             }
            textCell.textFieldOutlet.keyboardType = .default
            textCell.countryViewWidthConstraint.constant = 0
            textCell.textFieldLeadingConstraint.constant = 20
            textCell.textFieldOutlet.tag = 3
            textCell.contactInfoButtonOutlet.tag = 3
            textCell.arrowImageOutlet.isHidden = false
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            self.businessContactInfoVmObject.BusinessContactInfoTextCellDic[indexPath.row] = textCell
        case 3:
            textCell.countryViewWidthConstraint.constant = 0
            textCell.textFieldLeadingConstraint.constant = 20
            textCell.contactInfoButtonOutlet.isHidden = true
            textCell.textFieldOutlet.keyboardType = .numberPad
            textCell.textFieldOutlet.placeholder = Strings.phoneNumber.localized
            if let countryCodeObj = self.countryCode , countryCodeObj != "" {
                textCell.countryLabel.isHidden = true
                textCell.countryLabel.text = self.countryCode
                
                let number = countryCodeObj + " " + (businessContactInfoVmObject.phoneNumber ?? "")
                textCell.textFieldOutlet.text = number
               self.businessContactInfoVmObject.countryCode = self.countryCode
            }else {
                
            }
             
        //    self.businessContactInfoVmObject.countryCode =  textCell.countryCodeLabel.text
            textCell.arrowImageOutlet.isHidden = false
            textCell.contactInfoButtonOutlet.tag = 4
            textCell.textFieldOutlet.tag = 4
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            self.businessContactInfoVmObject.BusinessContactInfoTextCellDic[indexPath.row] = textCell
        case 4:
            textCell.textFieldOutlet.keyboardType = .default
            textCell.countryViewWidthConstraint.constant = 0
            textCell.textFieldLeadingConstraint.constant = 20
            textCell.contactInfoButtonOutlet.isHidden = false
            textCell.textFieldOutlet.placeholder = Strings.businessCategory.localized
            textCell.textFieldOutlet.text = businessContactInfoVmObject.businessCategoryName
            textCell.contactInfoButtonOutlet.tag = 5
            textCell.textFieldOutlet.tag = 5
            /*
             Feat Name:- add error label instead of popup.
             Feat Date:- 14/05/21
             Feat By  :- Nikunj C
             Description of Feat:- add cell in dic for use in view model
             */
            self.businessContactInfoVmObject.BusinessContactInfoTextCellDic[indexPath.row] = textCell
//        case 7:
//            textCell.textFieldOutlet.keyboardType = .default
//            textCell.countryViewWidthConstraint.constant = 0
//            textCell.contactInfoButtonOutlet.isHidden = true
//            textCell.textFieldOutlet.placeholder = Strings.bio
////            if let businessBio = businessContactInfoVmObject.businessBio{
////                textCell.contactInfoTextLabel.text = businessBio
////            }else{
////                textCell.contactInfoTextLabel.text = ""
////            }
//            textCell.arrowImageOutlet.isHidden = true
//            textCell.textFieldOutlet.text =  businessContactInfoVmObject.businessBio
//            textCell.textFieldOutlet.tag = 8
//            textCell.contactInfoButtonOutlet.tag = 8
//            /*
//             Feat Name:- add error label instead of popup.
//             Feat Date:- 14/05/21
//             Feat By  :- Nikunj C
//             Description of Feat:- add cell in dic for use in view model
//             */
//            self.businessContactInfoVmObject.BusinessContactInfoTextCellDic[indexPath.row] = textCell
         default:
             break
        }
        return textCell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0 , 1 , 2 , 3 ,4:
            return 65
        case 5,7:
            return UITableView.automaticDimension
        case 6:
            return 65
        case 8:
            return 78
        case 9:
            return 25
        case 10 :
            return 0
        default:
            return 100
        }
    }
}

// TextFieldDelegate Extension
// MARK: - UITextFieldDelegate
extension BusinessContactInfoViewController: UITextFieldDelegate,BusinessContactCellDelegate,GrowingTextViewDelegate{
    func pushingToDetailsVc(tag: Int) {
        switch tag {
        case 3:
            /// Pushing To BusinessEmailConfigurationViewController
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessEmailVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessEmailConfigurationViewControllerId) as! BusinessEmailConfigurationViewController
            if let businessEmailDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessEmail) as? [String:Any]{
                if let isEmailVisible = businessEmailDetails["isVisible"] as? Bool{
                    businessEmailVcId.isEmailVisible = isEmailVisible
                }
            }else {
                businessEmailVcId.email = self.businessContactInfoVmObject.businessEmail
            }
            self.navigationController?.pushViewController(businessEmailVcId, animated: true)
        case 4:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessMobileVcId = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessMobileConfigurationViewControllerId) as! BusinessMobileConfigurationViewController
            businessMobileVcId.countryCode = self.countryCode
            if let businessPhoneDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.businessMobileNumber) as? [String:Any]{
                if let isNumberisVisible = businessPhoneDetails[Strings.isVisible] as? Bool{
                    businessMobileVcId.visibleMobileNumberInteger = isNumberisVisible
                }
            }
            //businessMobileVcId.isEditingBusiess = true
            businessMobileVcId.mobileNumber = businessContactInfoVmObject.phoneNumber
            businessMobileVcId.countryCode = self.countryCode
            businessMobileVcId.isFromBusinessCreateVC = true
            self.navigationController?.pushViewController(businessMobileVcId, animated: true)
        case 5:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessCategoryVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessCategoryViewControllerId) as! BusinessCategoryViewController
            businessCategoryVc.isFromCreate = true
            businessCategoryVc.categoryName = self.businessContactInfoVmObject.businessCategoryName ?? ""
            businessCategoryVc.businessProfileDelegate = self
            self.navigationController?.pushViewController(businessCategoryVc, animated: true)
        case 6:
//            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
//            let businessAddressVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessAddressViewControllerId) as! BusinessAddressViewController
//            if businessFullAddress != nil{
//                businessAddressVc.placeAddress = businessStreetAddress
//                businessAddressVc.cityTown = self.placeAddress
//                businessAddressVc.zipCode = businessZipCode
//            }
//            businessAddressVc.businessContactInfoDelegate = self
//            self.navigationController?.pushViewController(businessAddressVc, animated: true)
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
        case 8:
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else { return }
            updateStatusVC.isFromCreateBusiness = true
            updateStatusVC.value = businessContactInfoVmObject.businessBio
            updateStatusVC.delegate = self
    //        self.present(updateStatusVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
        default:
            break
        }
    }
    
    
    func fetchTheAddressPlaceDetails(selectedaddress : Places){
        if let placeid = selectedaddress.placeId , placeid.count != 0
        {
            let urlString = String(format: ServiceManager.PlaceEnlarge,placeid)
            ServiceManager.fetchLocationwithplaceId(from: urlString) { placeFrom in
                if placeFrom.count > 0
                {
                    DispatchQueue.main.async {
                        self.businessStreetAddress = selectedaddress.name ?? ""
                        let latitude =  (((placeFrom.value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lat") as! NSNumber)
                        let longitude =  (((placeFrom.value(forKey: "geometry") as! NSDictionary).value(forKey: "location") as! NSDictionary).value(forKey: "lng") as! NSNumber)
                        self.businessLat = Float(latitude)
                        self.businessLang = Float(longitude)
                        self.businessContactInfoVmObject.businessLat = Float(latitude)
                        self.businessContactInfoVmObject.businessLang = Float(longitude)
                    }
                        if let addressComponent = placeFrom["address_components"] as? [[String:Any]] {
                            DispatchQueue.main.async {
                                for item in addressComponent {
                                    if let types = item["types"] as? [String] {
                                        if types.contains("locality") {
                                            self.businessCity = item["long_name"] as? String ?? ""
                                            self.businessContactInfoVmObject.businessCity = item["long_name"] as? String ?? ""
                                        } else if types.contains("administrative_area_level_1") {
                                            self.businessState =  item["long_name"] as? String ?? ""
                                            self.businessContactInfoVmObject.businessState  = item["long_name"] as? String ?? ""
                                        } else if types.contains("country") {
                                            self.businessCountry = item["long_name"] as? String ?? ""
                                            self.businessContactInfoVmObject.businessCountry = item["long_name"] as? String ?? ""
                                        } else if types.contains("postal_code") {
                                            self.businessZipCode = item["long_name"] as? String ?? ""
                                            self.businessContactInfoVmObject.businessZipCode = item["long_name"] as? String ?? ""
                                        }
                                    }
                                    
                                }
                                self.isValidAddress = true
                                self.checkingAllRequiredFields()
                                let indexpath = IndexPath(row: 5, section: 0)
                                if let cell = self.businessContactInfoTableView.cellForRow(at: indexpath) as? BusinessContactInfoAddressTextviewCell{
                                    DispatchQueue.main.async {
                                        cell.addressTextView.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
                                        cell.addressTextView.font = Utility.Font.Regular.ofSize(16)
                                        cell.titleLabel.isHidden = false
                                        cell.isAddressChanged = true
                                        self.businessContactInfoTableView.reloadData()
                                    }
                                    
                                }
                            }
                        }
                    
                }
            }
        }
    }
    
    /*
    Bug Name:- keyboard hide details
    Fix Date:- 13/05/21
    Fixed By:- Nikunj C
    Description of Fix:- add required methods
    */
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let updateEmailVC : UpdateEmailViewController = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil).instantiateViewController(withIdentifier: AppConstants.viewControllerIds.updateEmailVc) as! UpdateEmailViewController
        updateEmailVC.delegate = self
        updateEmailVC.currentUpdateField = .none
        updateEmailVC.isFromBussinessCreate = true
        view.endEditing(true)
        switch textField.tag {
        case 1:
            updateEmailVC.currentBusinessField = .businessUserName
            updateEmailVC.value = businessContactInfoVmObject.businessUserName
        case 2:
            updateEmailVC.currentBusinessField = .BusinessName
            updateEmailVC.value = businessContactInfoVmObject.businessName
        case 3:
            updateEmailVC.currentBusinessField = .email
            updateEmailVC.value = businessContactInfoVmObject.businessEmail
        case 4:
            updateEmailVC.currentBusinessField = .mobile
            updateEmailVC.value = businessContactInfoVmObject.phoneNumber
            updateEmailVC.strCountryCode = businessContactInfoVmObject.countryCode ?? "+91"
        case 7:
            updateEmailVC.currentBusinessField = .businessWebsite
            updateEmailVC.value = businessContactInfoVmObject.businessWebsite
        case 8:
//            updateEmailVC.currentBusinessField = .about
//            updateEmailVC.value = businessContactInfoVmObject.
            guard let updateStatusVC = UIStoryboard(name: AppConstants.StoryBoardIds.Profile, bundle: nil).instantiateViewController(withIdentifier: "EditBioViewController") as? EditBioViewController else { return false}
            updateStatusVC.isFromCreateBusiness = true
            updateStatusVC.value = businessContactInfoVmObject.businessBio
            updateStatusVC.delegate = self
    //        self.present(updateStatusVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(updateStatusVC, animated: true)
            return false
        
        default:
            break
        }
        self.navigationController?.pushViewController(updateEmailVC, animated: true)
       
        return  false
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var index = IndexPath()
        switch textField.tag {
        case 1:
            index = IndexPath(row: textField.tag , section: 0)
            break
        default:
            index = IndexPath(row: 1, section: 0)
            self.view.endEditing(true)
            guard let cell = self.businessContactInfoTableView.cellForRow(at: index) as? BusinessContactInfoTextCell else{return true}
            cell.textFieldOutlet.resignFirstResponder()
            return true
        }
        guard let cell = self.businessContactInfoTableView.cellForRow(at: index) as? BusinessContactInfoTextCell else{return true}
        cell.textFieldOutlet.becomeFirstResponder()
        return true

////        textField.resignFirstResponder()
//        return true
    }
    
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        switch textField.tag {
        case 1:
            businessContactInfoVmObject.businessUserName = txtAfterUpdate
            
            /*
             Bug Name:- need username don't allow special characters and whitespace and only 15 character
             Fix Date:- 12/04/21
             Fixed By:- Nikunj C
             Description of Fix:- add required validation
             */
            
            let cs = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.").inverted
            let filtered = string.components(separatedBy: cs).joined(separator: "")
            if string == filtered {
                textField.tintColor = UIColor.blue
            } else {
                textField.tintColor = UIColor.red
            }
            let currentCharacterCount = textField.text?.count ?? 0
            if range.length + range.location > currentCharacterCount {
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return (string == filtered) && newLength <= 15

        case 2:
            businessContactInfoVmObject.businessName = txtAfterUpdate
            return true
        case 3:
            businessContactInfoVmObject.businessEmail = txtAfterUpdate
            return true
        case 4:
            businessContactInfoVmObject.phoneNumber = txtAfterUpdate
            return true
//        case 7:
//          //  guard let text = textField.text else{ return true}
//            if txtAfterUpdate.count >= 4 {
//                if txtAfterUpdate == "www." {
//                    businessContactInfoVmObject.businessWebsite = ""
//                }else {
//
//                    businessContactInfoVmObject.businessWebsite = txtAfterUpdate
//                }
//
//                return true
//            }
//            return false
            /*
         Bug Name:- business bio not save its value
         Fix Date:- 13/05/21
         Fixed By:- Nikunj C
         Description of Fix:- add tag and on tag save value
         */
        case 8:
            businessContactInfoVmObject.businessBio = txtAfterUpdate
            self.businessBio = txtAfterUpdate
            return true
        
        default:
            return true
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.checkingAllRequiredFields()
        switch textField.tag {
        
        /*
         Feat Name:- add error label instead of popup.
         Feat Date:- 14/05/21
         Feat By  :- Nikunj C
         Description of Feat:- show error label according to validation
         */
        
        case 1:
            if Helper.isValidName(textName: textField.text!){
                self.businessContactInfoVmObject.validateUserName(userName: textField.text!) { (success, error) in
                    if success{
                        self.isUserNameExist = true
                        let indexPath = IndexPath.init(row: 0, section: 0)
                        if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                            cell.errorLabelHeightConstraint.constant = 21
                            cell.errorLabel.text = "Entered username already exists."
                            cell.errorLabel.isHidden = false
                            cell.heightConstraint?.constant = 92
                        }
                        self.isValidUserName = false
                        self.checkingAllRequiredFields()
                    }else{
                        self.isUserNameExist = false
                        let indexPath = IndexPath.init(row: 0, section: 0)
                        if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                            cell.errorLabelHeightConstraint.constant = 0
                            cell.errorLabel.isHidden = true
                            cell.heightConstraint?.constant = 78
                        }
                        self.isValidUserName = true
                        self.checkingAllRequiredFields()
                    }
                    
                }
            }
        case 2:
            if textField.text == "" || textField.text == nil{
                let indexPath = IndexPath.init(row: 1, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                    cell.errorLabelHeightConstraint.constant = 21
                    cell.errorLabel.text = Strings.pleaseEnterBusinessName.localized
                    cell.errorLabel.isHidden = false
                    cell.heightConstraint?.constant = 92
                }
                self.isValidName = false
                self.checkingAllRequiredFields()
            }else{
                let indexPath = IndexPath.init(row: 1, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                    cell.errorLabelHeightConstraint.constant = 0
                    cell.errorLabel.isHidden = true
                    cell.heightConstraint?.constant = 78
                }
                self.isValidName = true
                self.checkingAllRequiredFields()
            }
        case 3:
            if Helper.isValidEmail(emailText: textField.text!){
                self.validateEmailPhone(text: textField.text!, type: 1)
            }else{
                let indexPath = IndexPath.init(row: 2, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                    cell.errorLabel.text = Strings.pleaseEnterValidEmail.localized
                    cell.errorLabelHeightConstraint.constant = 21
                    cell.errorLabel.isHidden = false
                    cell.heightConstraint?.constant = 92
                }
                self.isValidEmail = false
                self.checkingAllRequiredFields()
            }
        case 4:
            if Helper.isValidNumber( "\(self.countryCode ?? "+91")" + textField.text!){
                self.validateEmailPhone(text: textField.text!, type: 2)
            }else{
                let indexPath = IndexPath.init(row: 3, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                    cell.errorLabelHeightConstraint.constant = 21
                    cell.errorLabel.text = "Please enter valid phone number."
                    cell.errorLabel.isHidden = false
                    cell.heightConstraint?.constant = 92
                }
                self.isValidPhoneNumber = false
                self.checkingAllRequiredFields()
            }
            
        case 7:
            if Helper.isValidWebsite(websiteText: textField.text!){
                let indexPath = IndexPath.init(row: 6, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                    cell.errorLabelHeightConstraint.constant = 0
                    cell.errorLabel.isHidden = true
                    cell.heightConstraint?.constant = 78
                }
                self.isValidWebsite = true
                self.checkingAllRequiredFields()
            }else{
                let indexPath = IndexPath.init(row: 6, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactTextViewCell{
                    cell.errorLabelHeightConstraint.constant = 21
                    cell.errorLabel.text = "Please enter valid website."
                    cell.errorLabel.isHidden = false
                    cell.heightConstraint?.constant = 92
                }
                self.isValidWebsite = false
                self.checkingAllRequiredFields()
            }
            
        case 8:
            if textField.text == "" || textField.text == nil{
                let indexPath = IndexPath.init(row: 7, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                    cell.errorLabelHeightConstraint.constant = 21
                    cell.errorLabel.text = Strings.pleaseEnterBusinessBio.localized
                    cell.errorLabel.isHidden = false
                    cell.heightConstraint?.constant = 92
                }
                self.isValidBio = false
                self.checkingAllRequiredFields()
            }else{
                let indexPath = IndexPath.init(row: 7, section: 0)
                if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                    cell.errorLabelHeightConstraint.constant = 0
                    cell.errorLabel.isHidden = true
                    cell.heightConstraint?.constant = 78
                }
                self.isValidBio = true
                self.checkingAllRequiredFields()
            }
            
        default:
            break
        }
    }
    
    /*
     Refactor Name:- change Business/emailPhoneVerification api
     Refactor Date:- 12/04/21
     Refactor By:- Nikunj C
     Description of Refactor:- change api from get to post
     */
    
    func validateEmailPhone(text: String,type:Int) {
        var url = AppConstants.businessPhoneEmailValidate
        var params = [String:Any]()
        if type == 1 {
            // email
            params = ["email":text,"type":1]
            self.isMessageForEmail = true
        }else if type == 2 {
            // phone
            params = ["phone":text,"countryCode":self.countryCode ?? "+91","type":2]
            self.isMessageForEmail = false
        }
        
        self.businessContactInfoVmObject.validateEmailPhone(strUrl: url,params: params) { (message,success, error) in
            if success {
                
                /*
                 Bug Name:- should not open alert for email or phone validation
                 Fix Date:- 15/05/21
                 Fixed By:- Nikunj C
                 Description of Fix:- show error label according to email/phone validation
                 */
                
                if self.isMessageForEmail{
                    let indexPath = IndexPath.init(row: 2, section: 0)
                    if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                        cell.errorLabel.text = Strings.pleaseChooseDifferentEmail.localized
                        cell.errorLabelHeightConstraint.constant = 21
                        cell.errorLabel.isHidden = false
                        cell.heightConstraint?.constant = 92
                    }
                    self.isValidEmail = false
                    self.checkingAllRequiredFields()
                }else{
                    let indexPath = IndexPath.init(row: 3, section: 0)
                    if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                        cell.errorLabel.text = Strings.pleaseChooseDifferentPhonenumber.localized
                        cell.errorLabelHeightConstraint.constant = 21
                        cell.errorLabel.isHidden = false
                        cell.heightConstraint?.constant = 92
                    }
                    self.isValidPhoneNumber = false
                    self.checkingAllRequiredFields()
                }
                
                
            }else{
                if self.isMessageForEmail{
                    let indexPath = IndexPath.init(row: 2, section: 0)
                    if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                        cell.errorLabelHeightConstraint.constant = 0
                        cell.errorLabel.isHidden = true
                        cell.heightConstraint?.constant = 78
                    }
                    self.isValidEmail = true
                    self.checkingAllRequiredFields()
                }else{
                    let indexPath = IndexPath.init(row: 3, section: 0)
                    if let cell = self.businessContactInfoTableView.cellForRow(at: indexPath) as? BusinessContactInfoTextCell{
                        cell.errorLabelHeightConstraint.constant = 0
                        cell.errorLabel.isHidden = true
                        cell.heightConstraint?.constant = 78
                    }
                    self.isValidPhoneNumber = true
                    self.checkingAllRequiredFields()
                }
                
            }
        }
    }

    func getUserDetails(){
        let strUrl = AppConstants.userProfile
        profileVmObject.userDetailsService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                self.businessContactInfoTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - VNHCountryPickerDelegate
extension BusinessContactInfoViewController{
//    func didPickedCountry(country: VNHCounty, flag: UIImage) {
//        let textCell = self.businessContactInfoTableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! BusinessContactInfoTextCell
//     //   textCell.countryCodeLabel.text = country.dialCode
//        //        self.countryNameOutlet.setTitle(country.name, for: .normal)
//        textCell.currentCountryCode = country.code
//        self.businessContactInfoVmObject.countryCode = country.code
//        currentCountryName = country.code
//        textCell.countryImageView.image = flag
//        // self.requestStarProfileTableView.reloadData()
//    }

}

// create Business Private account cell Delegate

// MARK: - BusinessContactInfoPrivateAccountCellDelegate
extension BusinessContactInfoViewController: BusinessContactInfoPrivateAccountCellDelegate{
    func privateAccountSwitching() {
        let privateCell = self.businessContactInfoTableView.cellForRow(at: IndexPath(row: 10, section: 0)) as! BusinessContactInfoPrivateAccountCell
        if privateCell.switchOutlet.isOn {
            self.businessContactInfoVmObject.privateAccount = 1
            businessContactInfoVmObject.updatePrivatePublicAccount()
        }else{
            self.businessContactInfoVmObject.privateAccount = 0
            businessContactInfoVmObject.updatePrivatePublicAccount()
        }
        }
    
    func creatBusinessPostApiCalling() {
        self.createBusinessAccountPostApiCall()
    }
    
    
    
}


// MARK: -  UINavigationController Extesnsion
extension  UINavigationController {
    
    func popViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        popViewController(animated: animated)
        
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
}

extension BusinessContactInfoViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate,CropViewControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        self.view.endEditing(true)
        if picker.view.tag == 1{
            print("update profile")
            if #available(iOS 11.0, *) {
                //                self.profileImageUrl = info[UIImagePickerControllerImageURL] as? URL
//                                self.selectedProfileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            } else {
                // Fallback on earlier versions
            }
            croppingStyle = CropViewCroppingStyle.circular
            /*
             Bug Name :- Crash
             Fix Date :- 23/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added guard let for image object
             */
            guard let image = (info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage)else {return}
            let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
            cropController.delegate = self
            cropController.aspectRatioPreset = .presetSquare;
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            cropController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
                self.dismiss(animated: true, completion: nil)
            }
            
        }else{
            print("update cover")
            if #available(iOS 11.0, *) {
                //                self.coverImageUrl = info[UIImagePickerControllerImageURL] as? URL
                //                self.selectedCoverImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            } else {
                // Fallback on earlier versions
            }
            
            /*
             Bug Name:- crashing In business banner update
             Fix Date:- 28/06/21
             Fixed By:- jayaram G
             Description of Fix:- Added guard check for nil value
             */
            guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {return}
            croppingStyle = CropViewCroppingStyle.default
            let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
            cropController.delegate = self
            cropController.aspectRatioPreset = .preset16x9;
            cropController.aspectRatioLockEnabled = true
            cropController.resetAspectRatioEnabled = false
            cropController.modalPresentationStyle = .fullScreen
            DispatchQueue.main.async {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            }
        }
    }
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        self.businessContactInfoTableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        if cropViewController.croppingStyle == .circular {
            DispatchQueue.main.async {
                cropViewController.dismiss(animated: true, completion: nil)
            }
            let reSizedImage = image.resizeImageUsingVImage(size: CGSize(width: 100, height: 100))
            businessProfileImage.image = reSizedImage
            self.selectedProfileImage = reSizedImage
            self.profileImage = reSizedImage
            self.profileImageUrl = self.saveImageToDocumentDirectory(selectedProfileImage)
        }else{
            DispatchQueue.main.async {
                cropViewController.dismiss(animated: true, completion: nil)
            }
//            let editHeaderTableViewCell = self.editProfileTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! EditProfileImageTableViewCell
            /*
             Bug Name:- cover image blurred
             Fix Date:- 10/05/21
             Fixed By:- Nikunj C
             Description of Fix:- add frame with height 150 for rectengal crop
             */
            businessCoverImage.image = image
            self.selectedCoverImage = image
            self.coverImage = image
            self.coverImageUrl = self.saveImageToDocumentDirectory(selectedCoverImage)
            
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
//        let dateFormatter = DateFormatter.init()
//        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let filename = UUID.init().uuidString.appending(".jpeg")
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try chosenImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            let stringUrl = url.absoluteString
            return stringUrl//String.init("/Documents/\(filename)")
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return nil
        }
    }
    
}

extension BusinessContactInfoViewController: EditBioViewControllerDelegate {
    func done(value: String,isBusinessProfile: Bool
    ) {
        self.businessBio = value
        self.businessContactInfoVmObject.businessBio = value
        isValidBio = true
        checkingAllRequiredFields()
        let indexpath = IndexPath(row: 7, section: 0)
        if let cell = self.businessContactInfoTableView.cellForRow(at: indexpath) as? BusinessContactInfoAddressTextviewCell{
            cell.titleLabel.isHidden = false
            cell.addressTextView.font = Utility.Font.Regular.ofSize(16)
            DispatchQueue.main.async {
                cell.addressTextView.textColor = UIColor.setColor(lightMode: "#484848", darkMode: AppColourStr.whiteColor)
                cell.isBioChanged = true
                self.businessContactInfoTableView.reloadData()
            }
            
        }
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

/*
 Feat Name:- should navigate to other page on click of business username,name and website
 Feat Date:- 03/05/21
 Feat By  :- Nikunj C
 Description of Feat:- required delegate method
 */

extension BusinessContactInfoViewController : UpdateEmailViewControllerDelegate{
    func updateDone(fieldType: UpdateFieldType, value: String) {
        
    }
    
    func updateDone(fieldType: UpdateFieldType, value: String, countryCode: String) {
        
    }

    func updateDone(fieldType: UpdateBusinessFieldType, value: String , countryCode : String) {
        businessContactInfoVmObject.phoneNumber = value
        businessContactInfoVmObject.countryCode = countryCode
        self.countryCode = countryCode
        isValidPhoneNumber = true
        checkingAllRequiredFields()
    }
    func updateDone(fieldType: UpdateBusinessFieldType, value: String) {
        switch fieldType {
        case .BusinessName:
            businessContactInfoVmObject.businessName = value
            isValidName = true
        case .businessUserName:
            businessContactInfoVmObject.businessUserName = value
            isValidUserName = true
        case .businessWebsite:
            businessContactInfoVmObject.businessWebsite = value
            isValidWebsite = true
        case .about:
            businessContactInfoVmObject.businessBio = value
            isValidBio = true
        case .email:
            businessContactInfoVmObject.businessEmail = value
            businessEmail = value
            isValidEmail = true
        case .mobile:
            businessContactInfoVmObject.phoneNumber = value
            isValidPhoneNumber = true
        case .none:break
       
        }
        checkingAllRequiredFields()
        businessContactInfoTableView.reloadData()
    }
}

extension BusinessContactInfoViewController:CountryDataDelegate{
    
    func countryData(countryName: String, phoneCode: String, countryCode: String, countryFlag: UIImage) {
        self.countryCode = phoneCode
        self.countryImageView = countryFlag
        self.businessContactInfoVmObject.countryCode = phoneCode
        DispatchQueue.main.async {
            self.businessContactInfoTableView.reloadRows(at: [IndexPath.init(row: 3, section: 0)], with: .none)
        }
    }
}
