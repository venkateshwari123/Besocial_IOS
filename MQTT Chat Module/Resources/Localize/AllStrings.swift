//
//  AllStrings.swift
//  Starchat
//
//  Created by Rahul Sharma on 5/25/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation

class Strings:NSObject {
    
    
    /// Keys
    static let tokenKey = "token"
    static let authorizationKey = "authorization"
    static let langKey = "lang"
    static let postsViewers = "postsViewers"
    
    
    static let publicAccount = "Public Account".localized
    static let privateAccount = "Private Account".localized
    static let inviteString = "Hey".localized + "! " + "join me on".localized + "\(AppConstants.AppName)," + " " + "This cool new social app".localized + "."
    
    
    static let done = "Done".localized
    static let next = "Next".localized
    static let cancel = "Cancel".localized
    static let pendingStatus = "pending".localized
    static let approvedStatus = "approved".localized
    
    static let save = "Save".localized
    
    // PlaceHolders
    static let email = "Email".localized
    static let phoneNumber = "Phone Number".localized
    static let businessCategory = "Business Category".localized
    static let address = "Address".localized
    static let webSite = "Website".localized
    static let bio = "Bio".localized
    
    static let userName = "User Name".localized
    static let fullName = "Full Name".localized
    static let knownAs = "Known As".localized
    static let enterPassword = "Enter Password".localized
    static let accountHolderName = "Account Holder's Name".localized
    static let ifscCode = "IFSC Code".localized
    static let amount = "Amount".localized
    static let descriptionOptional = "Description (Optional)"
    static let streetAddress = "Street Address".localized
    static let cityTown = "City/Town".localized
    static let zipCode = "Zip Code".localized
    static let viaMobile = "viaMobile".localized
    static let viaEmail = "viaEmail".localized
    
    static let notHaveViewer = "You do not have".localized + " " + "viewers"
    
    // Alerts Messages
    static let message = "Message".localized
    static let requestedSuccessfully1 = "Thank you for submitting your request".localized
    static let requestedSuccessfully2 = "Our review team will go through your application and you will recieve an email to confirm if your profile has been accepted or denied".localized
    static let ok = "Ok".localized
    static let warning = "Warning".localized
    static let error = "Error".localized
    static let enterAllFields = "Address cannot be empty".localized + "," + "please fill all required fields".localized
    static let fullNameShouldbeMoreThanThreeCharacters = "Full name should be More than three characters".localized
    static let pleaseEnterBusinessName = "Please enter".localized + " " + "business name".localized
    static let pleaseEnterBusinessUserName = "Please enter".localized + " " + "business username".localized
    static let pleaseEnterValidEmail = "Please enter".localized + " " + "valid".localized + " " + "email".localized
    static let pleaseChooseDifferentEmail = "Entered".localized + " " + "email".localized + "already exists".localized + "."
    static let pleaseChooseDifferentPhonenumber = "Entered".localized + "phone number".localized + " " + "already exists".localized + "."
    static let pleaseEnterValidPhoneNumber = "Please enter".localized + " " + "valid".localized + " " + "phone number".localized
    static let pleaseSelectCountryCode = "Please select".localized + " " + "country Code"
    static let pleaseEnterBusinessWebsite = "Please enter".localized + " " + "business website".localized + "."
    static let PleaseEnterValidWebsite = "Please enter".localized + " " + "valid".localized + " " + "website".localized + "."
//    static let pleaseChooseAddress = "Please Choose Address"
    static let pleaseChooseStreet = "Please choose".localized + " " + "street".localized
    static let pleaseChooseCity = "Please choose".localized + " " + "city".localized
    static let pleaseChooseZipCode = "Please choose".localized + " " + "zipcode".localized
    static let pleaseSelectBusinessCategory = "Please select".localized + " " + "business category".localized
    static let pleaseEnterBusinessBio = "Please enter".localized + " " + "business bio".localized + "."
    static let pleaseSelectCategory = "Please select".localized + " " + "category".localized + "!"
    static let pleaseChooseFile = "Please upload".localized + " " + "id proof".localized + "!"
    static let alert = "Alert".localized
    static let unBlock = "Unblock".localized
    static let unFriend = "Unfriend".localized
    static let areYouWantToUnBlockThisUser = "Are you sure you want to un-block this user".localized + "?"
    static let oops = "Oops".localized
    static let failedToSendMail = "Failed to send Mail".localized + "!"
    static let mailSent = "Mail sent".localized
    static let somethingWentWrong = "Something Went wrong".localized
    static let pleaseEnterOtp = "Please enter".localized + " " + "correct OTP".localized
    static let updatePhoneNumber = "We have successfully Updated your Phone Number".localized + "!"
    static let updatedEmail = "We have successfully updated your email address".localized + "!"
    static let pleaseEnterCorrectOtp = "Please enter".localized + " " + "Correct Otp".localized
    static let verificationResentMessage = "The verification code has been resent to".localized
    static let requestSentSuccessFully = "Request Sent Successfully".localized
    static let locationServicesDisabled = "Location Service Disabled".localized
    static let reEnableLocationsMessage = "To re-enable".localized + ", " + "please go to Settings and turn on Location Service for this app".localized + "."
    static let profileNeedsToBePublic = "Profile needs to be public for the business setup to happen successfully".localized + "."
    static let reportUser = "Report User".localized
    static let profileDeleted = "This profile has been deleted".localized + "."
    static let otpSuccessfullyVerifyied = "Otp verified succesfully".localized
    static let transferMoney = "your transfer money succesfully".localized
    static let validateMoney = "Please Enter".localized + " " + "correct Amout".localized
    
    // titles
    static let wallet = "Wallet".localized
    static let services = "Citysmart Services"
    static let settings = "Settings".localized
    static let invite = "Invite".localized
    static let about = "About".localized
    static let money = "Money"
    static let withDrawMoney = "Withdraw Money".localized
    static let trancHistory = "Transaction History".localized
    static let paySecurity = "Payment Security".localized
    static let helpCenter = "Help Center".localized
    static let cards = "Cards".localized
    static let debitCardName = "Debit Card".localized
    static let creditCardName = "Credit Card".localized
    static let netBanking = "Net Banking".localized
    
    //Business Titles
    static let businessProfile = "BUSINESS PROFILE".localized
    static let insights = "INSIGHTS".localized
    static let productAndServices = "PRODUCTS".localized + " & " + "SERVICES".localized
    
    
    
    static let getNewContactOptions = "Add a phone number".localized + ", " + "email address or location so that a customer can reach you directly by clicking a button on your profile".localized + "."
    static let learnAboutNewFollowers = "Learn about your followers and get insights on how your posts are performing".localized + "."
    static let postProductsAndServices = "Post products and services and allow your customers to buy them by a simple click".localized + "."
    
    // camera Alert strings
    static let chooseSource = "Choose Source".localized
    static let selectImageSource = "Please select the image Source".localized
    static let camera = "Camera".localized
    static let photoLibrary = "Photo Library".localized
    static let savedAlbum = "Saved Album".localized
    static let channel = "Channel".localized
    
    //Business buttons
    static let businessSelectionAlert = "Please select".localized + " " + "a business button text".localized
    
    
    struct settingsTitles{
        static let balance = "Balance".localized
        static let cards = "Cards".localized
        static let transactionHistory = "Transaction History".localized
        static let requestStarProfile = "Get Verified Profile".localized
        static let starConfiguration = "Star Configuration".localized
        static let businessProfile = "Business Profile".localized
        static let switchToBusinessProfile = "Switch To Business Profile".localized
        static let switchToPersonalProfile = "Switch To Personal Profile".localized
        static let businessConfiguration = "Business Configuration".localized
        static let contacts = "Contacts".localized
        static let subscription = "Subscription Settings".localized
        static let changeLanguage = "Change Language".localized
        static let mySubscriptions = "My Subscriptions".localized
        static let blockedContacts = "Blocked Users".localized
        static let saved = "Saved".localized
        static let inviteContacts = "Invite Contacts".localized
        static let privacyPolicy = "Privacy Policy".localized
        //  static let referralCode = "Referral Code"
        static let terms = "Terms Of Service".localized
        static let general = "General".localized
        static let helpAndFeedback = "Help".localized + " & " + "Feedback".localized
        static let services = "Services".localized
        static let logout = "Logout".localized
        static let verifiedConfiguraion = "Verified Configuration".localized
    }
    
    struct settingsHeaderTitles{
        static let starProfile = "Verify Profile".localized
        static let businessProfile = "Business Profile".localized
        static let account = "Account".localized
        static let support = "Support".localized
        static let theme = "Theme".localized
    }
    
    
    
    
     
    // Sign up
    struct  SignUp {
        static let phone = "Phone".localized
        static let name = "Name".localized
        static let userName = "Username".localized
        static let passWord = "Password".localized
        static let referralCode = "Referral Code".localized
        static let confirmPassWord = "Confirm".localized
        static let firstName = "First Name".localized
        static let lastName = "Last Name".localized
        
        static let enterName = "Enter Your Name".localized + "*"
        static let enterUserName = "Enter User Name".localized + "*"
        static let enterPassWord = "Enter Password".localized + "*"
        static let enterReferralCode = "Enter Referral Cod".localized + "*"
        static let enterEmail = "Enter your email".localized + "*"
        static let enterConfirmPassword = "Confirm your password".localized + "*"
        
        
    }
    
    
    //MARK:- Navigation Titles
    struct NavigationTitles{
        static let withDrawMoney = "Withdraw Money".localized
        static let chooseCurrency = "Choose Currency".localized
        static let wallet = "Wallet".localized
        static let addMoney = "Add Money".localized
        static let citySmartServices = "Citysmart Services"
        static let saved = "Saved".localized
        static let about = "About".localized
        static let privacyPolicy = "Privacy Policy".localized
        static let termsAndConditions = "Terms And Conditions".localized
        static let general = "General".localized
        static let helpAndFeedBack = "Help and Feedback".localized
        static let services = "Services".localized
        static let paymentSecurity = "Payment Security".localized
        static let helpCentre = "Help Center".localized
        static let businessConfiguration = "Business Configuration".localized
        static let verification = "Verification".localized
        static let myQrCode = "My QR Code".localized
        static let businessProfile = "Business Profile".localized
        static let businessProfileContactInfo  = "Setup Business Profile".localized
        static let verifiedConfiguration = "Verified Configuration".localized
        static let selectCategory = "Select Category".localized
        static let verifyProfile = "Verify Profile".localized
        static let createCollection = "Create Collection".localized
        static let editCollection = "Edit Collection".localized
        static let addToCollection = "Add to Collection".localized
        static let chaneCollectionCover = "Change Cover".localized
        static let addLink = "Add Link".localized
        static let addPrice = "Add Price".localized
        static let buttonText = "Action Button".localized
        static let currency = "Choose Currency".localized
    }
    
    
    //MARK:- Image Assests Names
    struct ImageNames {
        static let walletImage = "Wallet icon (png)"
        static let servicesImage = "Citysmart Services icon"
        static let settingsImage = "settings (9)"
        static let inviteImage = "invitation"
        static let aboutImage = "info (1)"
        
        static let moneyImage = "wallet (3)"
        static let cardsImage = "noun_Card_67115"
        static let camera = "camera"
        static let circleCamera = "circlecamera"
        static let createChannel = "create_channel"
        static let defaultImagepng = "defaultImage.png"
        static let defaultBannerpng = "bannerImage.png"
        static let defaultBanner = "bannerImage"
        static let defaultImage = "defaultImage"
        static let followers = "followers"
        static let following = "following"
    }
    
    struct PermissionMessage {
        static let permissionDenied = "Permission denied".localized
        static let cameraPermission = "Please".localized + ", " + "Go to Settings and allow".localized + " " + "camera permission".localized
        static let galleryPermission = "Please".localized + ", " + "Go to Settings and allow".localized + " " + "gallery permission".localized
        static let micPermission = "Please".localized + ", " + "Go to Settings and allow".localized + " " + "microphone permission".localized
        
    }
    
    struct FollowListStrings {
        static let followList = "followList".localized
        static let newMessage = "New Message".localized
        static let secretChat = "Secret Chat".localized
        static let addParticipants = "Add Participants".localized
        static let forwardTo = "Forward To".localized
    }
    
    struct ContactInfoStrings {
        static let reportSuccessMessage = "Thank you for your feedback".localized + ". " + "The user has been successfully reported".localized + "."
    }
    
    
    
    //MARK:- Profile View Controller Strings
    /// Alert Messages
    static let businessPublicAlertMessage = "If you want to Switch to business profile".localized + ", " + "Make sure your account should be public account".localized + "."
    static let createBusinessMessage = "any linked business account".localized + ", " + "please register your business by clicking on the Register Business button".localized + "."
    static let userUnBlockedSuccessFully = "User".localized + " " + "UnBlocked".localized + " " + "Successfully".localized
    static let userUnFriendSuccessFully = "User".localized + " " + "Unfriend".localized + " " + "Successfully".localized
    static let userBlockedSuccessFully = "User".localized + " " + "blocked".localized + " " + "Successfully".localized
    static let block = "Block".localized
    static let success = "Success".localized
    static let yes = "Yes".localized
    static let no = "No".localized
    static let registerNow = "Register Now".localized
    /// UI Texts
    static let switchToPersonal = "Switch To Personal Profile".localized
    static let switchToBusiness = "Switch To Business Profile".localized
    
    /// Keys
    static let maskLayer = "masklayer"
    static let   followers = "Followers"
    static let following = "Following"
    static let emailId = "emailId"
    
    
    //MARK:- Edit Profile ViewController Strings
    /// UI Texts
    static let editProfile = "Edit Profile".localized
    static let emailPhone = "Email".localized + ", " + "Phone".localized
    static let businessBio = "Business Bio".localized
    static let emailAddress = "Email Address".localized
    static let contactNumber = "Contact Number".localized
    
    /// Alert Message
    static let takePhoto = "Take Photo".localized
    static let choosePhoto = "Choose Photo".localized
    static let removePhoto = "Remove Photo".localized
    static let pleaseEnterYourName = "Please enter".localized + " " + "your Name".localized
    static let yourDeviceNotSupportCamera = "Your device doesn't support Camera".localized + "." + "Please select".localized + " " + "other option".localized + "."
    static let businessPrivateAccoutMessage = "If you switch to the private account".localized + "," + "your business account would no longer be active".localized + "."
    static let businessBioCannotBeEmpty = "Business bio cannot be empty".localized + "s."
    
    
    /// All Keys
    static let number = "number"
    static let mobile = "mobile"
    static let countryCode = "countryCode"
    static let id = "id"
    static let profilePic = "profilePic"
    static let firstName = "firstName"
    static let starUserKnownBy = "starUserKnownBy"
    static let lastName = "lastName"
    static let userNameKey = "userName"
    static let status = "status"
    static let emailKey  = "email"
    static let privacy = "private"
    static let profilCoverImage = "profileCoverImage"
    static let businessNameKey = "businessName"
    static let businessUserNameKey = "businessUserName"
    static let businessAddress = "businessAddress"
    static let businessWebsite = "businessWebsite"
    static let businessEmail = "businessEmail"
    static let businessPhone = "bussinessPhone"
    static let businessCountryCode = "bussinessCountryCode"
    static let businessCategoryId = "bussinessCategoryId"
    static let businessBioKey = "businessBio"
    static let businessProfilePic = "businessProfilePic"
    static let businessProfileCoverImage = "businessProfileCoverImage"
    static let profileCoverImage = "profileCoverImage"
    static let businessUniqueId = "businessUniqueId"
    
    
    
    //MARK:- BusinessEditContactOptionsViewController Strings

    /// UI Texts
    static let contactOptions = "Contact Options".localized
    
    /// Keys
    static let callingCodes = "CallingCodes"
    static let dialCode = "dial_code"
    static let plist = "plist"
    static let code = "code"
    static let isVisible = "isVisible"

    
    //MARK:- FollowViewController Strings
    static let noUserIsFollowing = "No user is following you".localized + "."
    static let yourNotFollowingAnyUser = "You are not following any user".localized + "."
    static let notHaveSubscriber = "You have not any subscribers".localized + "."
    static let searchFollowing = "Search".localized + " " + "following".localized
    static let searchFollowers = "Search".localized + " " + "followers".localized
    static let searchPeople = "Search".localized + " " + "People".localized
    
    
    //MARK:- UpdateStatusViewController Strings
    
    

    
    
    //MARK:- CreateChannelViewController

    
    /// UI Text
    static let editChannel = "Edit Channel"
    
    /// Alert messages
    static let pleaseSelectImage = "Please select image"
    static let uploading = "Uploading".localized + "..."
    
    
    /// Keys
    static let channelNameKey = "channelName"
    static let channelImageUrlKey =  "channelImageUrl"
    static let categoryIdKey = "categoryId"
    static let descriptionKey = "description"
    static let privateKey = "private"
    static let isPrivateKey = "isPrivate"


    //MARK:- SwitchToBusinessViewController
    /// UI Texts
    static let aboutBusiness = "About Business".localized
    static let webSiteUrl = "Website URL".localized
    static let businessName = "Business Name".localized
    static let contactInfo = "Contact Information".localized
    static let businessDetails = "Business Details".localized
    /// Keys
    static let newNumberWithOutCountryCode = "newNumberWithOutCountryCode"
    static let couuntryCodekey = "countryCode"
    static let deviceIdKey = "deviceId"
    static let deviceNameKey = "deviceName"
    static let deviceOsKey = "deviceOs"
    static let modelNumberKey = "modelNumber"
    static let deviceTypeKey = "deviceType"
    static let appVersionKey = "appVersion"
    /// Alert strings
    static let checkInternetConnection  = "Check Internet Connection".localized
    static let yourPhoneNumberisINCorrect = "Your phone number is not correct".localized
    static let okay = "Okay".localized
    static let phoneNumberIsTooLong = "Phone number is too long".localized + "."

    //MARK:- EditNumberVarificationViewController Strings
    
    /// UI Texts
    static let ididntGetCode = "I didn't get code".localized
 
    /// Alert Strings
    static let verifying = "Verifying".localized + "..."
    static let thisNumberTakenByAnotherUser = "This number is taken by other user please try again with different number".localized + "."
    static let numberChanged = "Number Changed".localized
    static let yourMobileNumberChangedSuccessFully =  "Your mobile number has been changed successfully".localized + "."
    static let sending = "Sending".localized + "..."
    static let otpKey =  "otp".localized

    
    //MARK:- UpdateEmailViewController Strings
    
    /// UI Texts
    static let emailVeirfication = "Email Address".localized

    static let pleaseEnterValidEmailId = "Please enter".localized + " " + "valid".localized + "email id".localized
    

    
    //MARK:- View Model Texts
    
    static let updating = "Updating".localized + "..."


    //MARK:- Setting
    static let logingOut = "Logging Out".localized
    static let deleteAccount = "Deleting".localized
    static let logOutMessage = "Are you sure you want to log out".localized + "?"
    static let deleteAccoutMessage = "Are you sure you want to delete Account".localized + "?"
    static let changeLangMessage = "Are you sure you want to change language".localized + "?"


    
    
    
    //MARK:- Create Post Strings
    static let businessPostType = "Post type".localized
    static let businessLink = "Link".localized
    static let productPrice = "Price".localized
    static let buttonText = "Action button".localized
    
    
    static let pleaseEnterValidUrl = "Please enter".localized + " " + "valid".localized + " " + "url".localized + "."
    static let buyNow = "Buy Now".localized
    static let shopNow = "Shop Now".localized
    static let book = "Book".localized
    
    
    static let productType = "Product Type".localized
    
    //MARK:- Transfer message
    struct PaymentStatus {
        static let pending = "Payment pending".localized
        static let accepted = "Payment accepted".localized
        static let denied = "Payment denied".localized
        static let canceled = "Payment canceled".localized
        static let timeout = "Payment timeout".localized
    }
    
    struct TransferConfirmationMessage {
        static let cancel = "Are you sure want to".localized + " " + "cancel".localized + "this transaction".localized
        static let accept = "Are you sure want to".localized + " " + "accept".localized + " " + "this transaction".localized
        static let decline = "Are you sure want to".localized + " " + "reject".localized + " " + "this transaction".localized
    }
    
    //Social
    static let deletePostPopUp = "Are you sure want to".localized + " " + "delete".localized + " " + "this post".localized + "?"
}
