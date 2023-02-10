import UIKit

class StringConstants {
    
    fileprivate static var obj : StringConstants!
    private init(){
    }
    
    public static func getInstance()-> StringConstants{
        if obj == nil{
            obj = StringConstants()
        }
        return obj
    }
    
    
    
    let avalLanguage = {
        return OSLocalizedString(" Available Languages ", comment: "")
    }
    
    
    
    // acceptable Strings for text fields
    
    let key = "key"
    let value = "value"
    let ACCEPTABLE_STRING = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'"
    let ACCEPTABLE_NUMBER = "1234567890"
    let digitsCount = "digitsCount"
    
    let filterResetTitle = {
        return  OSLocalizedString("Confirmation", comment: "")
    }
    
    let postedWithinOptions = [OSLocalizedString("All Listing", comment: "") ,
                               OSLocalizedString("Last 24h", comment: ""),
                               OSLocalizedString("Last 7 Days", comment: ""),
                               OSLocalizedString("Last 30 Days", comment: ""),
                               OSLocalizedString("Last 6 Months", comment: "")
        
    ]
    
    
    let filterResetMSG = {
        return  OSLocalizedString("Reset Filters , Are you sure you want to proceed?", comment: "")
        
    }
    
    let selectImageError = {
        return  OSLocalizedString("Please select any image", comment: "Please select any image")
    }
    
    let mandatoryFieldsError = {
        return  OSLocalizedString("Please fill mandatory fields", comment: "Please fill mandatory fields")
    }
    
    let postedWithin = {
        return  OSLocalizedString("Posted Within", comment: "Posted Within")
    }
    
    let mandatory = {
        return OSLocalizedString(" is mandatory", comment: " is mandatory")
    }
    
    let homeSearchText = {
        return OSLocalizedString("Search In PicoAdda", comment: "Search In PicoAdda")
    }
    
    let connect = {
        return OSLocalizedString("Connectivity", comment: "Connectivity")
    }
    
    let noInternet = {
        return OSLocalizedString("Check you internet connectivity", comment: "Check you internet connectivity")
    }
    
    let ProgressIndicator = {
        return OSLocalizedString("", comment: "")
    }
    
    let ProgressIndicatorForPosting = {
           return OSLocalizedString("Uploading advertisement", comment: "Uploading advertisement")
       }
    
    let Success = {
        return OSLocalizedString("Success", comment: "Success")
    }
    let Error = {
        return OSLocalizedString("Error", comment: "Error")
    }
    
    let textFieldErrorText       = {
        return OSLocalizedString("This field is required", comment: "This field is required")
    }
    
    
    let Done       = {
        return OSLocalizedString("Done", comment: "Done")
    } 
    
    // Login strings
    
    let logINHeading = {
        return OSLocalizedString("Login Now", comment: "")
    }
    
    let logINHeader = {
        return OSLocalizedString("Login in ", comment: "Login in ")
    }
    
    let logINHeading2 = {
        return OSLocalizedString("Please login to continue using PicoAdda", comment: "")
    }
    
    
    let logINAccess = {
        return OSLocalizedString("Access", comment: "Access")
    }
    
    
    let logINRecoverPswrd = {
        return OSLocalizedString("Recover Password", comment: "Recover Password")
    }
    
    let logINRecoverUsername = {
        return OSLocalizedString("Recover Username", comment: "Recover Username")
    }
    
    let loginText = {
        return OSLocalizedString("Don't have an account?", comment: "Don't have an account?")
    }
    
    let submitText = {
        return OSLocalizedString("Submit", comment: "")
    }
    
    let logINsignUP = {
        return OSLocalizedString("Signup now", comment: "Signup now")
    }
    
    // signup Strings
    let signUPHeading = {
        return OSLocalizedString("Register Now", comment: "Register Now")
    }
    
    let signUPHeader = {
        return OSLocalizedString("Register in ", comment: "Register in ")
    }
    
    let passwordAlert = {
        return OSLocalizedString( " Password should be more then 4 characters ", comment: "")
        
    }
    
    let signUPSubText = {
        return OSLocalizedString("PicoAdda", comment: "PicoAdda")
    }
    
    
    let signUPHeading2 = {
        return OSLocalizedString("Register with \(AppConstants.AppName) and start selling", comment: "")
    }
    
    let signUPWhoInvitedU = {
        return OSLocalizedString("Who invited you?", comment: "Who invited you?")
    }
    
    let signUPText = {
        return OSLocalizedString("Already have an account?", comment: "")
    }
    let signUPLoginNow = {
        return OSLocalizedString("Login now", comment: "")
    }
    
    
    let signUPRegisterText = {
        return OSLocalizedString("Register", comment: "Register")
    }
    
    let signUPlogin = {
        return OSLocalizedString("Log in", comment: "Log in")
    }
    let signUPTnC1 = {
        return OSLocalizedString("By registering you accept our", comment: "By registering you accept our")
    }
    let signUPTnC2 = {
        return OSLocalizedString("Term of use and privacy policy", comment: "Term of use and privacy policy")
    }
    
    let signUPTnC3 = {
        return OSLocalizedString("By registering you accept our Terms of use and Privacy Policy", comment: "By registering you accept our Terms of use and Privacy Policy")
    }
    
    let signUPTnC4 = {
        return OSLocalizedString("By registering you accept our", comment: "By registering you accept our")
    }
    
    let signUPInviteDetails = {
        return OSLocalizedString("You are invited by what I put, if you know to someone you know already register in PicoAdda, look fot your username in this field and you can register inviter", comment: "You are invited by what I put, if you know to someone you know already register in PicoAdda, look fot your username in this field and you can register inviter")
    }
    
    
    let signUpReferralCode = {
        return OSLocalizedString("Referral code", comment: "Referral code")
    }
    
    let signUPName = {
        return OSLocalizedString("Name", comment: "Name")
    }
    
    let signUPSurname = {
        return OSLocalizedString("Surname", comment: "Surname")
    }
    
    let signUPUsername = {
        return OSLocalizedString("Username", comment: "Username")
    }
    let signUPPhoneNumber = {
        return OSLocalizedString("Phone Number", comment: "Phone Number")
    }
    let signUPDOB = {
        return OSLocalizedString("Date Of Birth(MM-DD-YYYY)", comment: "Date Of Birth(MM-DD-YYYY)")
    }
    let signUPCountry = {
        return OSLocalizedString("Country", comment: "Country")
    }
    let signUPEmail = {
        return OSLocalizedString("Email", comment: "Email")
    }
    
    let signUPPassword = {
        return OSLocalizedString("Password", comment: "Password")
    }
    let signUPVarified = {
        return OSLocalizedString("Varified", comment: "Varified")
    }
    let signUPCPassword = {
        return OSLocalizedString("Confirm Password", comment: "Confirm Password")
    }
    
    // profile VC Strings
    
    let profileOnSale = {
        return OSLocalizedString("On sale", comment: "On sale")
    }
    
    
    let profileHighlights = {
        return OSLocalizedString("Highlights", comment: "Highlights")
    }
    
    let profileUrgntSell = {
        return OSLocalizedString("Urgent", comment: "Urgent")
    }
    
    let profileSold = {
        return OSLocalizedString("Sold", comment: "Sold")
    }
    
    let profileExchanges = {
        return OSLocalizedString("Exchanges", comment: "Exchanges")
    }
    
    let profileReview = {
        return OSLocalizedString("Reviews", comment: "Reviews")
    }
    
    let profileFavourites = {
        return OSLocalizedString("Favourites", comment: "Favourites")
    }
    
    let profileComment = {
        return OSLocalizedString("Comment", comment: "Comment")
    }
    
    let profileArchived = {
        return OSLocalizedString("Archived", comment: "Archived")
    }
    
    let profileMore = {
        return OSLocalizedString("More", comment: "More")
    }
    
    
    let phone = {
        return OSLocalizedString("Phone", comment: "Phone")
    }
    
    let din = {
        return OSLocalizedString("DIN", comment: "DIN")
    }
    
    let dateOfBirth = {
        return OSLocalizedString("Date Of Birth", comment: "Date Of Birth")
    }
    
    let website = {
        return OSLocalizedString("Website", comment: "Website")
    }
    
    let bio = {
        return OSLocalizedString("Bio", comment: "Bio")
    }
    
    let country = {
        return OSLocalizedString("Country", comment: "Country")
    }
    
    let province = {
        return OSLocalizedString("Province", comment: "Province")
    }
    
    let city = {
        return OSLocalizedString("City", comment: "City")
    }
    
    let postalCode = {
        return OSLocalizedString("PostalCode", comment: "PostalCode")
    }
    
    let address = {
        return OSLocalizedString("Address", comment: "Address")
    }
    
    let password = {
        return OSLocalizedString("Password", comment: "Password")
    }
    
    let profilePic = {
        return OSLocalizedString("profilePic", comment: "profilePic")
    }
    // VerifyCode VC Strings
    
    let VFCodeHP1 = {
        return OSLocalizedString(" Please Enter 4 Digits Verification Code sent To Your Phone Number ", comment: "Please Enter 4 Digits Verification Code sent To Your Phone Number ")
    }
    
    let createNewPswdMSG = {
        return  OSLocalizedString("You can now login using your new password.", comment: "")
        
    }
    
    let resendOTP = {
        //        return  OSLocalizedString("Resend OTP", comment: "Resend OTP")
        return  OSLocalizedString("Retry", comment: "Retry")
    }
    let verifyCodeVerified = {
        return OSLocalizedString("Verify Code", comment: "Verify Code")
    }
    
    let verifyCodeAccountCreated = {
        return OSLocalizedString(" Your account has been cearted. We have sent you  email with a link to confirm your email access ", comment: " Your account has been cearted. We have sent you  email with a link to confirm your email access ")
    }
    let verifyCodeOTPExpire = {
        return OSLocalizedString(" OTP has been expired ", comment: " OTP has been expired ")
    }
    
    // PasswordRecovery VC Strings
    let  PRSubHeading1 = {
        return OSLocalizedString("have you forgotten ", comment: "have you forgotten ")
    }
    let  PRpassword = {
        return OSLocalizedString("your password?", comment: "your password?")
    }
    let  PRusername = {
        return OSLocalizedString("your username?", comment: "your username?")
    }
    
    
    let  PRHeading3 = {
        return OSLocalizedString(" Enter Your Phone Number ", comment: " Enter Your Phone Number ")
        //return OSLocalizedString(" write your email here ", comment: " write your email here ")
    }
    
    let  PRHeading2 = {
        return OSLocalizedString(" Enter Your Email ", comment: " Enter Your Email ")
        //return OSLocalizedString(" write your email here ", comment: " write your email here ")
    }
    
    let  PRsubHeading = {
        
        return OSLocalizedString(" Please Enter Your Valid Email Address To Get A Verification Code ", comment: " Please Enter Your Valid Email Address To Get A Verification Code ")
        //return OSLocalizedString(" write your email here ", comment: " write your email here ")
    }
    
    let  PRsubHeading1 = {
        return OSLocalizedString(" Please Enter Your Valid Mobile Number To Get A Verification Code ", comment: "  Please Enter Your Valid Mobile Number To Get A Verification Code ")
        //return OSLocalizedString(" write your email here ", comment: " write your email here ")
    }
    
    
    let  PRsubHeading2 = {
        return OSLocalizedString(" Enter your email we will send your username  directly to your email. ", comment: "  Enter your email we will send your username  directly to your email. ")
        //return OSLocalizedString(" write your email here ", comment: " write your email here ")
    }
    
    
    let sendCode = {
        return OSLocalizedString(" Send Code ", comment: " Send Code ")
    }
    
    let sendEmail = {
        return OSLocalizedString(" Send Email ", comment: " Send Email ")
    }
    
    let CategoryVCHeading = {
        return OSLocalizedString(" Select a category ", comment: " Select a category ")
    }
    
    let SubCategorySubHeading = {
        return OSLocalizedString(" what kind of ad are you going to publish? ", comment: " what kind of ad are you going to publish? ")
    }
    
 
    
    let menuItemOrderHistory = {
        return OSLocalizedString("Order History", comment: "Order History")
    }
    
    let menuItemchat = {
        return OSLocalizedString("Chat", comment: "Chat")
    }
    
 
    let menuItemPaymentMethod = {
        return OSLocalizedString("Payment Method", comment: "Payment Method")
    }
    
    let menuItemWallet = {
        return OSLocalizedString("Wallet", comment: "Wallet")
    }
    
    let menuItemNotifications = {
        return OSLocalizedString("Notifications", comment: "Notifications")
    }
    
    let menuItemMyAddresses = {
        return OSLocalizedString("My Addresses", comment: "My Addresses")
    }
    
    let manuItemRecommends = {
        return OSLocalizedString("Recommends PicoAdda", comment: "Recommends PicoAdda")
    }
    
    let manuItemBusiness = {
        return OSLocalizedString("\(AppConstants.AppName) business", comment: "\(AppConstants.AppName) business")
    }
    
    let menuItemLanguage = {
        return OSLocalizedString("Languages", comment: "Languages")
    }
    
    let manuItemHelp = {
        return OSLocalizedString("Help", comment: "Help")
    }
    
    let menuItemFAQs = {
        return OSLocalizedString("FAQs", comment: "FAQs")
    }
    
    let manuItemSignOff = {
        return OSLocalizedString("SignOff", comment: "SignOff")
    }
    
    //  edit profile
    
    let editProfileDNI = {
        return OSLocalizedString(" DNI ", comment: " DNI ")
    }
    
    let editProfileGender = {
        return OSLocalizedString(" Gender ", comment: " Gender ")
    }
    
    let editProfileAddress = {
        return OSLocalizedString(" Address ", comment: " Address ")
    }
    let editProfileCity = {
        return OSLocalizedString(" City ", comment: " City ")
    }
    let editProfileState = {
        return OSLocalizedString(" State ", comment: " State ")
    }
    
    let editProfileSaveChanges = {
        return OSLocalizedString(" Save Changes ", comment: " Save Changes ")
    }
    let unsubscribe = {
        return OSLocalizedString(" Unsubscribe ", comment: " Unsubscribe ")
    }
    
    let becomeTrustedSman = {
        return OSLocalizedString(" Become a trusted salesman ", comment: " Become a trusted salesman ")
    }
    
    let editProfilePno = {
        return OSLocalizedString(" Phone number ", comment: " Phone number ")
    }
    
    let editProfilePnoVerify = {
        return OSLocalizedString(" Verify your phone ", comment: " Verify your phone ")
    }
    
    let editProfileFBAccount = {
        return OSLocalizedString(" Facebook account ", comment: " Facebook account ")
    }
    
    let editProfileFBVerify = {
        return OSLocalizedString(" Verify your Facebook account ", comment: " Verify your Facebook account ")
    }
    
    // reportVC
    
    let reportHeader = {
        return OSLocalizedString(" Why do you report this item? ", comment: " Why do you report this item? ")
    }
    
    let reportOption1 = {
        return OSLocalizedString(" It’s prohibited on \(AppConstants.AppName) ", comment: " ")
    }
    
    let reportOption2 = {
        return OSLocalizedString(" It’s offensive to me ", comment: "")
    }
    
    let reportOption3 = {
        return OSLocalizedString(" It’s not a real post ", comment: " ")
    }
    
    let reportOption4 = {
        return OSLocalizedString(" It’s a duplicate post ", comment: " ")
    }
    
    let reportOption5 = {
        return OSLocalizedString("  It may be spam ", comment: " ")
    }
    
    let reportOption6 = {
        return OSLocalizedString("  Other ", comment: " ")
    }
    
    let adUpdate = {
        return OSLocalizedString("Ad Update", comment: "")
    }
    
    let brand = {
        return OSLocalizedString("Brand", comment: "")
    }
    
    let model = {
        return OSLocalizedString("Model", comment: "")
    }
    
    
    
    let AddressLane1 = {
        return OSLocalizedString("Address Lane 1*", comment: "")
    }
    
    let AddressLine2 = {
        return OSLocalizedString("Address Line 2", comment: "")
    }
    
    let Area = {
        return OSLocalizedString("Area", comment: "")
    }
    
    
    let City = {
        return OSLocalizedString("City*", comment: "")
    }
    
    
    let Country = {
        return OSLocalizedString("Country*", comment: "")
    }
    
    
    let Landmark = {
        return OSLocalizedString("Landmark", comment: "")
    }
    
    let pinCode = {
        return OSLocalizedString("Pincode", comment: "")
    }
    
    //SettingVC
    let followPeople = {
        return OSLocalizedString("Follow People", comment: "Follow People")
    }
    
    let account = {
        return OSLocalizedString("Account", comment: "Account")
    }
    let payments = {
        return OSLocalizedString("Payments", comment: "Payments")
    }
    let support = {
        return OSLocalizedString("Support", comment: "Support")
    }
    let about = {
        return OSLocalizedString("About", comment: "About")
    }
    
    let connectToContacts = {
        return OSLocalizedString("Connect To Contacts", comment: "Connect To Contacts")
    }
    
    let editProfile = {
        return OSLocalizedString("Edit profile", comment: "Edit profile")
    }
    
    let myAddresses = {
        return OSLocalizedString("My Addresses", comment: "My Addresses")
    }
    
    let myPayments = {
        return OSLocalizedString("My payments", comment: "My payments")
    }
    let reportAProblem = {
        return OSLocalizedString("Report A Problem", comment: "Report A Problem")
    }
    let privacy = {
        return OSLocalizedString("Privacy", comment: "Privacy")
    }
    let termsAndCondition = {
        return OSLocalizedString("Terms And Condition", comment: "Terms And Condition")
    }
    
    let version = {
        return OSLocalizedString("Version", comment: "Version")
    }
    
    let manuItemSignOut = {
        return OSLocalizedString("Sign Out", comment: "Sign Out")
    }
    
    let deactivateAccount = {
        return OSLocalizedString("Deactivate Account", comment: "Deactivate Account")
    }
    
    //product update
    let markAsSold = {
        return OSLocalizedString("Mark As Sold", comment: "Mark As Sold")
    }
    
    let edit = {
        return OSLocalizedString("Edit", comment: "Edit")
    }
    
    let rePost = {
        return OSLocalizedString("RePost", comment: "RePost")
    }
    
    let sellUrgently = {
        return OSLocalizedString("Sell Urgently", comment: "Sell Urgently")
    }
    
    let insights = {
        return OSLocalizedString("Insights", comment: "Insights")
    }
    
    let deleteAd = {
        return OSLocalizedString("Delete Ad", comment: "Delete Ad")
    }
    
    let goToHome = {
        return OSLocalizedString("Go To Home", comment: "")
    }
    
    let emailVerificationTitle = {
        return OSLocalizedString("Enter Your Email", comment: "Enter Your Email")
    }
    
    let emailVerificationSubTitle = {
        return OSLocalizedString("Please Enter Your Email Address To Verify", comment: "Please Enter Your Email Address To Verify")
    }
    
    let emailAddress = {
        return OSLocalizedString("Email Address:", comment: "Email Address:")
    }
    
    let addAddress = {
        return OSLocalizedString("Add Address", comment: "Add Address")
    }
    
    let addCard = {
        return OSLocalizedString("Add Card", comment: "Add Card")
    }
    
    let confirm = {
        return OSLocalizedString("Confirm", comment: "Confirm")
    }
    
    let save = {
        return OSLocalizedString("Save", comment: "Save")
    }
    
    let continueString = {
        return OSLocalizedString("Continue", comment: "Continue")
    }
}

public func OSLocalizedString(_ key: String, comment: String) -> String {
    return key
}
