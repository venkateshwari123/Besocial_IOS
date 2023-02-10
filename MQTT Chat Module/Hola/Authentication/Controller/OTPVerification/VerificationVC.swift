//
//  VerificationVC.swift
//  Shoppd
//
//  Created by Rahul Sharma on 27/09/19.
//  Copyright © 2019 Nabeel Gulzar. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CocoaLumberjack
import Locksmith
import CocoaLumberjack
import Kingfisher
import Alamofire

enum VerificationVCType{
    case signUp
    case login
    case resetPassword
    case updateMobile
    case changePassword
}

struct VerificationData{
    var countryCode:String
    var phoneNumber:String
    var otpId:String
}

struct SignUpData{
    var name:String
    var lastName:String
    var email:String
    var password:String
    var terms:Int
}

protocol VerificationVCDelegate : NSObjectProtocol {
    func done()
}

class VerificationVC: UIViewController {
    
    
    @IBOutlet weak var codeView1: UIView!
    @IBOutlet weak var codeView2: UIView!
    
    @IBOutlet weak var codeView3: UIView!
    
    @IBOutlet weak var codeView4: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleDescription: UILabel!
    @IBOutlet weak var otpMessage: UILabel!
//    @IBOutlet weak var centerYAnchor: NSLayoutConstraint!
    @IBOutlet weak var resendText: UILabel!
    @IBOutlet weak var otpTF1: UITextField!
    @IBOutlet weak var otpTF2: UITextField!
    @IBOutlet weak var otpTF3: UITextField!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var otpTF4: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var loginButtonView: UIView!
    @IBOutlet weak var loginViewTitle: UILabel!
//    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var invalidMessage: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var isVerifying:Bool = false
    var isFromEditProfile:Bool = false
    var verificationData:VerificationData?
    var changePassword:(()->Void)?
    var str = ""
    var oldLength = 0
    var replacementLength = 0
    var verificationType:VerificationVCType = .login
    var loginVM = LoginViewModel(api: LoginAPI())
   // let loginVM = LoginVM()
    let disposeBag = DisposeBag()
    var resetResponse:Bool = false
    var isEnableButton:Bool = false{
        didSet{
            loginButtonView.backgroundColor  = isEnableButton ? UIColor.blue : UIColor.Light.blue
            continueButton.isEnabled = isEnableButton
            continueButton.isUserInteractionEnabled = true
        }
    }
    
    weak var delegate : VerificationVCDelegate?
    var isBessines = false
    var otpId : String?
    
    @IBOutlet weak var popView: UIView!
    
    @IBOutlet weak var numberLabel : UILabel!
    
    var phoneNumber :String!
    var counrtyCode : String!
    var userEnteredNumber : String!
    var remainingTime:Double!
    var emailId : String = ""
    var signUpData : [String : Any]!
    var loginViewModel : LoginViewModel = LoginViewModel.init(api: LoginAPI())
    var profileImageObj:UIImage?
    var countryName:String = ""
    var isFromRegistration = false
    
    override func loadView() {
        super.loadView()
          initialSetUp()
    }
    
    var totalSeconds = 30
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        DispatchQueue.main.async {
            self.startTimer()
        }
        didGetSignUpResponse()
        didGetResponse()
        /*
         Bug Name :- 11). make app background transparent
         Fix Date :- 22/03/2021
         Fixed By :- Jayaram G
         Description Of Fix :- changed view background color
         */
        if AppConstants.appType == .dubly {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         addObserver()
        otpTF1.becomeFirstResponder()
//        if Changebles.showDefaultOTP{
//            otpTF4.becomeFirstResponder()
//            [otpTF1,otpTF2,otpTF3,otpTF4].forEach{$0?.text = "1"}
//        }
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        /*
         Bug Name :- verificationVC back button not work in edit profile
         Fix Date :- 10/07/21
         Fixed By :- Nikunj C
         Description Of Fix :- check with boolen value instead of presented viewcontroller as it give always nil for  presented or push view
         */
        
        if self.isFromEditProfile{
            self.dismiss(animated: false, completion: nil)
        }else{
            navigationController?.popViewController(animated: false)
        }
    }
    @IBAction func resendButtonAction(_ sender: Any) {
//        guard let verificationData = verificationData else{return}
//        resetResponse = true
        requestOTP()
       
    }
    
    //MARK:- Service call
    func requestOTP() {
        switch verificationType{
        case .resetPassword:
            guard let emailAddress = self.emailId as? String,!emailAddress.isEmpty else{return}
            loginVM.requestOtpEmail(withType: 2, andUserEmailId: emailAddress)
            loginVM.didUpdateAny = { userObj in
                // self.activateTimer()
                Helper.showAlertViewOnWindow("Message".localized, message: "The verificaiton code has been resent to".localized + " \(self.emailId)".localized)
                 self.otpTF1.clear()
                 self.otpTF2.clear()
                 self.otpTF3.clear()
                 self.otpTF4.clear()
                 self.otpTF1.becomeFirstResponder()
                 self.totalSeconds = 30
                 DispatchQueue.main.async {
                  self.startTimer()
                 }
                 Helper.hidePI()
            }
            loginVM.didError = { error in
                Helper.hidePI()
            }
        default:
            Helper.showPI(_message: "Sending".localized + "...")
            let strURL = AppConstants.requestOTP
            guard let number = self.phoneNumber else { return }
            guard let countryCode = self.counrtyCode else { return }
            guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
            let params = ["phoneNumber":number,
                          "countryCode":countryCode,
                          "deviceId":deviceID,
                          "development":"true" ] as [String:Any]
            
            let headers = ["authorization":AppConstants.authorization] as [String: String]
            
            let apiCall = RxAlmofireClass()
            apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.requestOtp.rawValue)
           _ = apiCall.subject_response
                .subscribe(onNext: {dict in
                    guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                    if responseKey == AppConstants.resposeType.requestOtp.rawValue {
                       // self.activateTimer()
                        Helper.showAlertViewOnWindow("Message".localized, message: "The verificaiton code has been resent to".localized + " \(self.userEnteredNumber!)".localized)
                        self.otpTF1.clear()
                        self.otpTF2.clear()
                        self.otpTF3.clear()
                        self.otpTF4.clear()
                        self.otpTF1.becomeFirstResponder()
                        self.totalSeconds = 30
                        DispatchQueue.main.async {
                         self.startTimer()
                        }
                        Helper.hidePI()
                    }
                }, onError: {error in
                    Helper.hidePI()
                })
        }
    }
    @IBAction func loginButtonAction(_ sender: Any) {
        continueButton.isUserInteractionEnabled = false
        verifyOtpAPI()
    }
    
    ///  verifying OTP
    func verifyOtpAPI() {
        
        /*
         Feat Name:- for normal user should show verified label
         Feat Date:- 10/07/21
         Feat By  :- Nikunj C
         Description of Fix:- for normal user emailphoneverify api call
         */
        if isFromEditProfile{
            if isBessines {
                
                let updateEmailPhoneViewModel = UpdateEmailPhoneViewModel()

                guard let otp1Text = otpTF1.text, let otp2Text = otpTF2.text, let otp3Text = otpTF3.text, let otp4Text = otpTF4.text,!otp1Text.isEmpty,!otp4Text.isEmpty,!otp2Text.isEmpty,!otp3Text.isEmpty else{return}
                let otpArray:[String] = [otp1Text,otp2Text,otp3Text,otp4Text]
                let otpText = otpArray.reduce("",+)
                
                updateEmailPhoneViewModel.verifyBusinessPhoneOTP(phoneNumber: phoneNumber, countryCode: counrtyCode, otpId: otpId ?? "", otpCode: otpText) { (success, error) in
                    if success{
                        self.navigationController?.dismiss(animated: true, completion: {
                            self.delegate?.done()
                        })
                    }
                     
                }
                updateEmailPhoneViewModel.verifyBusinessPhoneOTP(phoneNumber: phoneNumber, countryCode: counrtyCode, otpId: otpId!, otpCode: otpText) { [self] (str1, st2) in
                    navigationController?.dismiss(animated: true, completion: {
                        delegate?.done()
                    })
                    
                }
                
                return
            }else{
                let updateEmailPhoneViewModel = UpdateEmailPhoneViewModel()

                guard let otp1Text = otpTF1.text, let otp2Text = otpTF2.text, let otp3Text = otpTF3.text, let otp4Text = otpTF4.text,!otp1Text.isEmpty,!otp4Text.isEmpty,!otp2Text.isEmpty,!otp3Text.isEmpty else{return}
                let otpArray:[String] = [otp1Text,otp2Text,otp3Text,otp4Text]
                let otpText = otpArray.reduce("",+)
                
                updateEmailPhoneViewModel.verifyNormalUserPhoneOTP(phoneNumber: phoneNumber, countryCode: counrtyCode, otpId: otpId ?? "", otpCode: otpText) { (success, error) in
                    if success{
                        self.navigationController?.dismiss(animated: true, completion: {
                            self.delegate?.done()
                        })
                    }
                    
                }
                
                return
            }
        }
        
        if verificationType == .resetPassword {
            guard let otp1Text = otpTF1.text, let otp2Text = otpTF2.text, let otp3Text = otpTF3.text, let otp4Text = otpTF4.text,!otp1Text.isEmpty,!otp4Text.isEmpty,!otp2Text.isEmpty,!otp3Text.isEmpty else{return}
            let otpArray:[String] = [otp1Text,otp2Text,otp3Text,otp4Text]
            let otpText = otpArray.reduce("",+)
           
            loginViewModel.verifyOTPCode(otpId:self.emailId , otpCode:otpText , type: .Phone) { (success,tokeId) in
                self.continueButton.isUserInteractionEnabled = true
                if success{
                    self.handleSuccessResponse(token: "")
                }else{
                    self.handleErrorResponse(errorCode: .ExpiredToken)
                }
            }
            
            return
        }else if verificationType == .updateMobile
        {
            guard let otp1Text = otpTF1.text, let otp2Text = otpTF2.text, let otp3Text = otpTF3.text, let otp4Text = otpTF4.text,!otp1Text.isEmpty,!otp4Text.isEmpty,!otp2Text.isEmpty,!otp3Text.isEmpty else{return}
            let otpArray:[String] = [otp1Text,otp2Text,otp3Text,otp4Text]
            let otpText = otpArray.reduce("",+)
            
            let updateType : FiledVerificationType = .phoneNumber
            
            let updateViewModel = UpdateViewModel()
            updateViewModel.verifyOTP(updateType: updateType, otpId:verificationData!.otpId, otpCode: otpText, phoneNumber: verificationData?.phoneNumber, countryCode: verificationData?.countryCode) { (data, err) in
                self.dismiss(animated: true) {
                    self.delegate?.done()
                }
                
                if data == "Ok"
                {
                    self.delegate?.done()
                }
                else
                {
                    if data != nil
                    {
                        Helper.showAlert(head: "", message: data!)
                    }
                    
                }
            }
            
            
            
            return
        }
        let trimmedString = AppConstants.verifyOTP.trimmingCharacters(in: .whitespaces)
        guard let encodedHost = trimmedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        guard let otp1Text = otpTF1.text, let otp2Text = otpTF2.text, let otp3Text = otpTF3.text, let otp4Text = otpTF4.text,!otp1Text.isEmpty,!otp4Text.isEmpty,!otp2Text.isEmpty,!otp3Text.isEmpty else{return}
        let otpArray:[String] = [otp1Text,otp2Text,otp3Text,otp4Text]
        let otpText = otpArray.reduce("",+)
        guard let number = self.phoneNumber else { return }
        guard let countryCode = self.counrtyCode else { return }
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else { return }
        let deviceName = UIDevice.current.name
        let deviceOs = UIDevice.current.systemVersion
        guard let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String else {return}
        let modelNumber = UIDevice.modelName
        let params = ["phoneNumber":number,
                      "countryCode":countryCode,
                      "countryName": countryName, //For dynamic countryName,
            "otp":otpText,
            "deviceId":deviceID,
            "deviceName":deviceName,
            "deviceOs":deviceOs,
            "modelNumber":modelNumber,
            "deviceType":"1",
            "appVersion":appVersion,
            "type":"1",
            "isVisible":false,
            "isSignUp":true
            ] as [String:Any]
        
        Helper.showPI(_message: "Verifying".localized + "...")
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: encodedHost, requestType: .post, parameters: params,headerParams:HTTPHeaders.init(Helper.getHeaderForSocial()), responseType: AppConstants.resposeType.verifyOTP.rawValue)
        
      _ =  apiCall.subject_response
            .subscribe(onNext: {response in
                guard let responseKey = response[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.verifyOTP.rawValue {
                    Helper.hidePI()
                    
                    
                    /*
                     Bug Name:- for entering invalid otp it not give any error and stuck on otp page
                     Fix Date:- 10th Nov 2021
                     Fixed By:- Nikunj C
                     Description of Fix:- show invalid otp alert
                     */
                    
                    if let code = response["code"] as? Int, code == 138{
                        self.continueButton.isUserInteractionEnabled = true
                        Helper.hidePI()
                        Helper.showAlertViewOnWindow("Error".localized, message: "invalid".localized + " " + "otp".localized)
                    }
                    
                    if let code = response["code"] as? Int, code == 200{
                        if self.signUpData != nil{
                            self.signUpUser(data: response)
                            return
                        }
                    }
                    
                    guard let userData = response["response"] as? [String:Any] else { return }
                    
                    
                    
                    let userDefault = UserDefaults.standard
                    guard let userID = userData["userId"] as? String else { return }
                    userDefault.setValue(userID, forKeyPath: AppConstants.UserDefaults.userID)
                    /* Refactor Name :  Need to subscribe with deviceId in Onesignal
                     Refactor Date : 07-Apr-2021
                     Refactor By : Jayaram G
                     Description Of Refactor : subscribing onesignal with deviceId.
                     */
                    if let oneSignalId = userData["oneSignalId"] as? String {
                        UserDefaults.standard.set(oneSignalId, forKey: AppConstants.UserDefaults.oneSignalId)
                        Utility.subscribeToOneSignal(externalUserId: oneSignalId)
                    }
                    

                    
                    if let sellerId = userData["storeId"] {
                    userDefault.setValue(sellerId, forKeyPath: "sellerId")
                    }

                    do{
                        try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                    }
                    catch{
                        DDLogDebug("error handel it")
                    }
                    
                    guard let token = userData["token"] as? String else {return}
                    do{
                        try Locksmith.saveData(data: ["token":token], forUserAccount: AppConstants.keyChainAccount)
                    }catch{
                        DDLogDebug("error handel it")
                    }
                    if let businessProfileActive = userData["isActiveBusinessProfile"] as? Int{
                        if businessProfileActive == 1 {
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        }
                    }
                    
                    if let currencyData = userData["currency"] as? [String:Any] {
                        if let currencyCode = currencyData["currencyCode"] as? String {
                            UserDefaults.standard.set(currencyCode, forKey: AppConstants.UserDefaults.walletCurrency)
                        }
                        if let currencySymbol = currencyData["currencySymbol"] as? String {
                            UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.walletCurrecnySymbol)
                        }
                        if let currencyName = currencyData["countryCodeName"] as? String {
                            UserDefaults.standard.set(currencyName, forKey: AppConstants.UserDefaults.currencycountryCodeName)
                        }
                    }
                    
                    if let type = userData["userType"] as? Int {
                    UserDefaults.standard.setValue(type, forKey: "userType")
                    }
                    if let type = userData["referralCode"] as? Int {
                    UserDefaults.standard.setValue(type, forKey: "referralCode")
                    }
                    
                    if let isVerifiedStar = userData["isStar"] as? Int {
                                           if isVerifiedStar == 1 {
                                               UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                                           }else {
                                               UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                                           }
                                       }
                    
                    if let streamData = userData["stream"] as? [String:Any] {
                        if let topic = streamData["fcmTopic"] as? String {
                            UserDefaults.standard.setValue(topic, forKeyPath: AppConstants.UserDefaults.fcmToken)
                        }
                    }
                    if let firstName = userData["firstName"] as? String {
                        var fullName = firstName
                        if let lastName = userData["lastName"] as? String{
                            fullName = fullName + lastName
                        }
                        UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userFullName)
                    }
                    if let firstName = userData["firstName"] as? String {
                        var fullName = firstName
                        if let lastName = userData["lastName"] as? String{
                            fullName = fullName + lastName
                        }
                        UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userName)
                    }
                    if let userNameToShow = userData["userName"] as? String {
                        UserDefaults.standard.setValue(userNameToShow, forKeyPath: AppConstants.UserDefaults.userNameToShow)
                    }
                    
                    if let currency = userData["currency"] as? String{
                        UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
                    }
                    if let currencySymbol = userData["currencySymbol"] as? String{
                        UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
                    }
                    
                    if let isPrivate = userData["private"] as? Int{
                        UserDefaults.standard.set(isPrivate, forKey: AppConstants.UserDefaults.isPrivate)
                    }
                    if let referralCode = userData["referralCode"] as? String{
                        UserDefaults.standard.set(referralCode, forKey: AppConstants.UserDefaults.referralCode)
                    }
                    if let status = userData["socialStatus"] as? String{
                        UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
                    }else {
                        UserDefaults.standard.setValue(AppConstants.defaultStatus, forKeyPath: AppConstants.UserDefaults.userStatus)
                    }
                    
                    if let profilePic = userData["profilePic"] as? String {
                        /*
                         Bug Name :- Add profile pic in tabbar item
                         Fix Date :- 08/04/2021
                         Fixed By :- Jayaram G
                         Description Of Fix :- Downloading image and storing image data from profile pic url
                         */
                        if let imageUrl = URL(string: profilePic) {
                        Helper.downloadImage(from: imageUrl)
                        }
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                    }
                    
                    if let profilePic = userData["profilepic"] as? String {
                        /*
                         Bug Name :- Add profile pic in tabbar item
                         Fix Date :- 08/04/2021
                         Fixed By :- Jayaram G
                         Description Of Fix :- Downloading image and storing image data from profile pic url
                         */
                        if let imageUrl = URL(string: profilePic) {
                        Helper.downloadImage(from: imageUrl)
                        }
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                    }
                    
                    if let userNumber = userData["number"]  as? String {
                        if let countryCode = userData["countryCode"] as? String {
                            UserDefaults.standard.setValue(userNumber.replace(target: countryCode, withString: ""), forKeyPath: AppConstants.UserDefaults.userNumber)
                            
                            UserDefaults.standard.setValue(countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)
                            
                        }
                        
                    }
                    if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                        if let businessEmail = businessProfile.first?["email"]{
                            UserDefaults.standard.set(businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
                        }
                        
                        if let businessPhone = businessProfile.first?["phone"] as? [String:Any] {
                            UserDefaults.standard.set(businessPhone, forKey: AppConstants.UserDefaults.businessMobileNumber)
                        }
                    }
                    if let email = userData["email"] as? String {
                        UserDefaults.standard.setValue(email, forKeyPath: AppConstants.UserDefaults.userEmail)
                    }
                    if (self.userEnteredNumber) != nil{
                        UserDefaults.standard.set(self.userEnteredNumber, forKey: AppConstants.UserDefaults.userNumber)
                    }
                    let couchbase = Couchbase.sharedInstance
                    
                    let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
                    indexDocVMObject.updateIndexDocID(isUserSignedIn: false)
                    
                    let usersDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
                    usersDocVMObject.updateUserDoc(data: userData, withLoginType: "1")
                    
                    indexDocVMObject.updateIndexDocID(isUserSignedIn: true)
                    
                    let userObj = User.init(modelData: userData)
                    UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
                    UserDefaults.standard.synchronize()
                    guard let userToken = userData["token"] as? String else {return}
                    /*
                     Bug Name:- Show full name in chats instead of username
                     Fix Date:- 12/05/2021
                     Fixed By:- Jayaram G
                     Discription of Fix:- Replaced username with fullname
                     */
                    usersDocVMObject.updateUserDoc(withUser: userObj.firstName, lastName: userObj.firstName, userName: userObj.firstName + " " + userObj.lastName, imageUrl: userObj.profilePic, privacy: userObj.isPrivate, loginType: "1", receiverIdentifier: "", docId: userToken, refreshToken: userObj.refreshToken)
                    Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
                    self.updateCallPush()
                    userDefault.synchronize()
                    Utility.setIsGuestUser(status: false)
                    Utility.createMQTTConnection()
                   Utility.creatDocforGroupChat()
                    Helper.hidePI()
                    /*
                     Bug Name :- showed me contact sync page even for login , should show only for signup
                     Fix Date :- 07/04/2021
                     Fixed By :- Jayaram G
                     Description Of Fix :- moving to home screen directly, when user loggedin
                     */
                    Route.setRootController()
                    }
            }, onError : {error in
                self.continueButton.isUserInteractionEnabled = true
                Helper.hidePI()
                Helper.showAlertViewOnWindow("Error".localized, message: error.localizedDescription)
            })
    }
    
    
    func updateCallPush() {
        CallAPI.sendCallpushtoServer(with:"")
        //Update Status in Local
        let statusArr = [AppConstants.defaultStatus,"Available","Busy","At School","At work","Battery about to die","Can't talk, \(AppConstants.AppName) only","In a metting","Sleeping","Urgent calls only"]
        UserDefaults.standard.set("", forKey: AppConstants.UserDefaults.isUserOnchatscreen)
        UserDefaults.standard.set(statusArr, forKey: AppConstants.UserDefaults.statusArr)
        UserDefaults.standard.synchronize()
    }
    
    func signUpUser(data : [String : Any]){
        let signUpViewModel : SignUpViewModel = SignUpViewModel()
        signUpViewModel.signUp(signUpData: self.signUpData)
        signUpViewModel.didUpdateUser = { userObj in
            DispatchQueue.main.async {
                Helper.hidePI()
                self.updateCallPush()
                UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
                Utility.setIsGuestUser(status: false)
                /*
                 Bug Name :- contactSync flow is missing
                 Fix Date :- 23/03/2021
                 Fixed By :- Jayaram G
                 Description Of Fix :- Added navigation to contactSync page
                 */
                let addContactsVC = AddContactsViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Contacts) as AddContactsViewController
                /*
                 Bug Name:- after login or sign up add contact screen is not being displayed appropriatly
                 Fix Date:- 03/04/21
                 Fixed By:- Nikunj C
                 Description of Fix:- hide bottom bar on push
                 */
                addContactsVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(addContactsVC, animated: true)
            }
        }
        signUpViewModel.didError = { error in
            print(error.localizedDescription)
        }
    }
    
    

    
    func didGetSignUpResponse(){
//        loginVM.signUp_Response.subscribe(onNext: { [weak self] success in
//            switch success{
//            case .success:
//                print("Success")
//                self?.dismiss(animated: true, completion: nil)
//            case .error(let errorCode):
//                self?.isVerifying = false
//                print(errorCode)
//            case .errorInDataParsing:
//                fatalError("Error In Data Parsing")
//            }
//        }, onError: { error in
//            print(error)
//        }).disposed(by: loginVM.disposeBag)
    }
    
    func didGetResponse(){
//        loginVM.login_Response.subscribe(onNext: { [weak self] loginResponse in
//            switch loginResponse{
//            case .success:
//                self?.handleSuccessResponse()
//            case .error(let errorCode):
//                self?.isVerifying = false
//                self?.handleErrorResponse(errorCode: errorCode)
//            case .errorInDataParsing:
//                fatalError("Error In Data Parsing")
//            }
//        }, onError: { error in
//            print(error)
//        }).disposed(by: disposeBag)
    }
    
}
