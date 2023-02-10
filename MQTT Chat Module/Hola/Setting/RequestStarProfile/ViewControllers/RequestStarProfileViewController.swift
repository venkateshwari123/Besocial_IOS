//
//  RequestStarProfileViewController.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/2/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class RequestStarProfileViewController: UIViewController,requestStarProfileDelegate{
    
    //MARK:- Variables&Declarations
    var dialCode:String?                   // Used To denote country dial code Eg:- (+91)
    var countryCodeName:String?            // Used To denote country Code name Eg:- IN ,SA
    var countryImage = UIImage()           // Used To denote country Flag Image
    var phoneTextField = UITextField()     // Used for Phone Number TextField
    var phoneNumber:String?                //  Used To Store Mobile Number
    var doneToolbar = UIToolbar()          // Used To Add On KeyBoard
    var currentCountryName = "US"          // Used To Store Current Country Name
    var isValidNumber: Bool = false        // used To check Enterd Mobile Number is valid number or not
    var canServiceCall: Bool = false       // used To check the pagination
    var uploadedImageUrl: String?          // used To store uploaded image Url
    //    var accountKit:AccountKitManager!
    
    
    let profileVmObject = ProfileViewModel() // Used for profileViewModel Object Reference
    let requestStarProfileVmObject = RequestStarProfileViewModel()   // Used for requestStarProfileViewModel Object Reference
    
    let requestStarCategoryVmObject = RequestStarCategoryViewModel() // Used for requestCategoryViewModel Object Reference
    
    /// passing categoryName and CategoryId
    ///
    /// - Parameters:
    ///   - categoryName: categoryName string
    ///   - categoryId: categoryId string
    func gettingStarCategoryNameAndId( categoryName:String, categoryId:String) {
        requestStarProfileVmObject.starCategoryName = categoryName
        requestStarProfileVmObject.starCategoryId = categoryId
    }
    
    
    //MARK:- All Outlets
    @IBOutlet weak var requestStarProfileTableView: UITableView!
    @IBOutlet weak var approvedLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var starUserStatusLabel: UILabel!
    @IBOutlet weak var descriptionLbl1: UILabel!
    @IBOutlet weak var descriptionLbl2: UILabel!
    @IBOutlet weak var countryViewWidthConstraint: NSLayoutConstraint!
    
    
    
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStarStatusDetails()
        if let isVerified = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile) as? Bool {
            if isVerified {
                
            }else{
             self.requestStarProfileVmObject.email =  Utility.getUserEmail()
            }
        }else {
             self.requestStarProfileVmObject.email =  Utility.getUserEmail()
        }
        
        
        requestStarProfileVmObject.userName = Utility.getUserName()
        requestStarProfileVmObject.fullName =  Utility.getUserFullName()
            
        if let countryCode = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.countryCode) as? String {
            countryCodeName = countryCode
        }else {
            /// Getting Current Country Details
            if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                currentCountryName = VNHCountryPicker.dialCode(code: countryCode).code
                countryCodeName = VNHCountryPicker.dialCode(code: countryCode).dialCode
                countryImage = VNHCountryPicker.getCountryImage(code: countryCode)
            }
        }
        
        if let number = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userNumber) as? String{
            requestStarProfileVmObject.phoneNumber = number
        }
        
        addDoneButtonOnKeyboard()
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
        //            let textCell = self.requestStarProfileTableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! RequestStarProfileTextCell
        //            textCell.detailsTextField.becomeFirstResponder()
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //  getUserDetails()
        self.requestStarProfileTableView.reloadData()
        uiDesign()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isValidNumber = false
        self.requestStarProfileTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 73, right: 0)
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
 
    /// Managing KeyBoard Hide/Show
    ///
    /// - Parameter notification: Notification
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
    
    
    //MARK:- UI Design
    func uiDesign(){
        navigationItem.leftBarButtonItem = Utility.navigationBar(inViewController: self, title: Strings.NavigationTitles.verifyProfile.localized)
        self.descriptionLbl1.text = "Apply for verify badge that appears next to a".localized + "\(AppConstants.AppName)" + "account's name to indicate that the account is the authentic presence of a notable Public figure,celebrity,global brand or entity it Represents".localized + "."
        self.descriptionLbl2.text = "Submitting a request for verification does not guarantee that your account will be verified".localized
        self.approvedLabelHeightConstraint.constant = 0
    }
    
    
    
    //MARK:- all button Actions
    /// Popping ViewController
    ///
    /// - Parameter sender: Back Button
    @IBAction func backToSettingsVc(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// Requesting For Star Profile API Call - POST
    func requestingStarProfilePostApiCall(){
        let urlStr = AppConstants.starRequest
        requestStarProfileVmObject.checkingRequiredFields(complitation: { (allFieldsEntered) in
            if allFieldsEntered{
                self.requestStarProfileVmObject.requestPostCall(strUrl: urlStr) { (success, error) in
                    if success{
                        let alert = UIAlertController(title: Strings.message.localized, message: Strings.requestedSuccessfully1.localized + "." + Strings.requestedSuccessfully2.localized + ".", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: Strings.ok.localized, style: .default, handler: { (UIAlertAction) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert,animated: true)
                        
                    }else if let error = error{
                        
                        Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                        if error.code != 405{
                            Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                        }
                    }
                    Helper.hidePI()
                }
            }
        })
    }
    
    
    
    /// Get All user Details - GET
    func getUserDetails(){
        let strUrl = AppConstants.userProfile
        profileVmObject.isSelf = true
        profileVmObject.userDetailsService(strUrl: strUrl, params: [:]) { (success, error, canServiceCall) in
            if success{
                
                if let verifiedDetails = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.verifyProfileDetails) as? [String:Any], verifiedDetails.count > 0 {
                    self.requestStarProfileVmObject.email =  verifiedDetails["starUserEmail"] as? String
                    if let number = verifiedDetails["starUserPhoneNumber"] as? String {
                        if number != "" {
                            self.requestStarProfileVmObject.phoneNumber = number
                        }
                    }
                }else{
                    self.requestStarProfileVmObject.email =  Utility.getUserEmail()
                }
                self.countryImage = VNHCountryPicker.getCountryImage(code: (self.profileVmObject.userProfileModel?.countryCode)!)
                self.countryCodeName = self.profileVmObject.userProfileModel?.countryCode
                self.currentCountryName = (self.profileVmObject.userProfileModel?.countryCode)!
                //                self.requestStarProfileTableView.reloadData()
                //
                guard let textCell = self.requestStarProfileTableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? RequestStarProfileTextCell else{fatalError()}
                textCell.countryCodeNumberOutlet.text = self.profileVmObject.userProfileModel?.countryCode
                textCell.countryImageView.image = VNHCountryPicker.getCountryImage(code: (self.profileVmObject.userProfileModel?.countryCode)!)
                self.requestStarProfileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
    }
    
    /// Get Star Status Details - GET
    func getStarStatusDetails(){
        Helper.showPI()
        requestStarProfileVmObject.getStarStatusServiceCall{ (success, error) in
            if success{
                
                Helper.hidePI()
                switch self.requestStarProfileVmObject.requestStarProfileModel?.starUserStatus{
                case Strings.pendingStatus:
                    self.approvedLabelHeightConstraint.constant = 25
                    self.starUserStatusLabel.textColor = Utility.appColor()
                    self.starUserStatusLabel.text = Strings.pendingStatus.localized
                case Strings.approvedStatus:
                    UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                    self.approvedLabelHeightConstraint.constant = 25
                    self.starUserStatusLabel.text = Strings.approvedStatus.localized
                    self.starUserStatusLabel.textColor = Utility.appColor()
                default:
                    self.approvedLabelHeightConstraint.constant = 0
                }
                self.requestStarProfileTableView.reloadData()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
            }
        }
        Helper.hidePI()
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
    
    
    /// Done Button Action On ToolBar
    @objc func doneButtonAction(){
        phoneTextField.resignFirstResponder()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension RequestStarProfileViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        guard let _ = touch.view?.isKind(of: RequestStarProfileCategoryCell.self) else{
            return true
        }
        return false
    }
}
