//
//  ApiHelper.swift
//  Yelo
//
//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import UIKit
import Messages
import Firebase

class ApiHelper{
 
    let apiManager = ApiManager()
    static let shared = ApiHelper()
//
    fileprivate func showSomethingWrongError() {
        Helper.showAlert(head: "Oops".localized + "!", message:"Something went wrong".localized + "." )
    }
//
//    //MARK:- Get Profile API
//    ///Provide User Profile Details.
//    func getProfileDetail(userId: String? = nil, searchTag: String? = nil,success:((Profile)-> Void)? = nil){
//        var params = [String:String]()
//        if userId != nil{
//            params["userId"] = userId
//        }
//
//        if searchTag != nil && searchTag != "" {
//            params["searchTag"] = searchTag
//        }
//
//        apiManager.getRequest(params.stringFromHttpParameters(url:APIEndTails.getInstance().Profile), success: { (response) in
//
//
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let data = response["data"] as? [String: Any]{
//                        if userId == nil{
//                            UserProfile.shared.profile = Profile(modelData: data)
//                            success?(Profile(modelData: data))
//                        }else{
//                            success?(Profile(modelData: data))
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg,APIEndTails.getInstance().Profile)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//
//        }) { (error) in
//            print(error)
//            print("#### GET PROFILE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    enum productSortBy: String{
//        case recency_desc = "recency_desc"
//        case price_asc = "price_asc"
//        case price_desc = "price_desc"
//    }
//
//    //MARK:- Get Products API
//    //sort  recency_desc ,price_asc,price_desc
//    ///Provide products for as per Param.
//    func getAssets(userId: String? = nil, query : String? = nil, status: String? = nil, sort: productSortBy? = nil , assetTypeId : String? = nil , isLoaderEnable : Bool = true , isHighlited:Bool = false, isUregentToSell:Bool = false , page: String?, limit: String = "10" ,filterParams : [String : String]? = nil ,inSection: String? = nil, isExpired: Bool = false, isSold: Bool = false, failed: ((Bool) -> Void)? = nil ,success: @escaping([ProductModel],String)-> Void ) {
//
//        var params = [String:String]()
//
//        if userId != nil{
//            params["userId"] = userId
//        }
//
//        if assetTypeId != nil {
//            params["assetTypeId"] = assetTypeId
//        }
//
//        if query != nil{
//            params["q"] = query //for query
//        }
//
//        if status != nil{
//            params["status"] = status
//        }
//
//        if sort != nil{
//            params["sort"] = sort?.rawValue
//        }
//
//        if isHighlited{
//            params["promoted"] = "1" // for highlited
//        }
//
//        if isUregentToSell{
//            params["promoted"] = "2" // for isUrgentToSell
//        }
//
//        if inSection != nil && inSection != ""{
//            params["inSection"] = inSection
//        }
//
//        if isExpired{
//            params["expired"] = Date().timeStamp()
//        }
//
//        if isSold{
//            params["sold"] = "1"
//        }
//
//        if let _params = filterParams{
//            params = _params
//        }
//
//        params["limit"] = limit
//        params["page"] = page
//
//
//        print(">>>>>>>>>>>>>>> GET ASSESET >>>>>>>>")
//        print(params.stringFromHttpParameters(url: APIEndTails.getInstance().assest))
//        print("-------------------------------------")
//
//        let url = params.stringFromHttpParameters(url: APIEndTails.getInstance().assest)
//
//        apiManager.getRequest( url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url, isLoaderEnable: isLoaderEnable  , success: { (response) in
//            var totalCount = ""
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["result"] as? [[String: Any]]{
//                            if let count = response["Totalcount"] as? Int {
//                                totalCount = String(count)
//                            }
//                            var productArray = [ProductModel]()
//                            for productData in data{
//                                productArray.append(ProductModel(data: productData))
//                            }
//                            failed?(false)
//                            success(productArray, totalCount)
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        failed?(true)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//
//        }) { (error) in
//            failed?(true)
//            print(error)
//            print("#### GET PRODUCTS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func getUserRating(userId: String, linkedWith: String, failed: ((Bool) -> Void)? = nil, success: @escaping ([ReviewModel])->Void){
//
//        var params = [String: String]()
//        params["userId"] = userId
//        params["linkedWith"] = linkedWith
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().userRating), isLoaderEnable: true, success: { (response) in
//            var userRating = [ReviewModel]()
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let rating = response["data"] as? [String: Any]{
//                        userRating.append(ReviewModel(data: rating))
//                        success(userRating)
//                    }
//                    else if let rating = response["data"] as? [[String: Any]]{
//                        for data in rating{
//                            userRating.append(ReviewModel(data: data))
//                        }
//                        success(userRating)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                    failed?(true)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET USER RATING ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func getUserReview(userId: String, sortBy: String, linkedWith: String, offset: String, limit: String, fromDate: String, toDate: String, failed: ((Bool) -> Void)? = nil, success: @escaping ([ReviewModel])->Void){
//
//        var params = [String: String]()
////        viemodel.prodile.userid
//        params["userId"] = userId
//        params["linkedWith"] = linkedWith
//
//        if sortBy != ""{
//            params["sortBy"] = sortBy
//        }
//
//        if offset != ""{
//            params["offset"] = offset
//        }
//
//        if limit != ""{
//            params["limit"] = limit
//        }
//
//        if fromDate != ""{
//            params["fromDate"] = fromDate
//        }
//
//        if toDate != ""{
//            params["toDate"] = toDate
//        }
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().userReview), isLoaderEnable: true, success: { (response) in
//            var userRating = [ReviewModel]()
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let data = response["data"] as? [String: Any]{
//                        if let userReviews = data["userReviews"] as? [[String:Any]]{
//                            for rating in userReviews{
//                            userRating.append(ReviewModel(data: rating))
//                            }
//                            success(userRating)
//                        }
//                    }
//                }else{
//                    failed?(true) //for pagination: no more data found
//                }
//            }else{
//                if let msg = response["message"] as? String{
//                    print(msg)
//                    Helper.showAlert(head: "Oops!", message: msg )
//                    success(userRating)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET USER REVIEW ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    //MARK:- Validate Email
//    /// Validate Email if it is already in use with other account
//    /// - Parameters:
//    ///   - email: email string
//    ///   - success: respone True or False
//    func validateEmail(email: String, success: @escaping ([String:Any]) -> Void){
//        var params = [String : String]()
//        params["email"] = email
//
//        apiManager.postRequest(APIEndTails.getInstance().ValidateEmail, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST VALIDATE_EMAIL ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    //MARK:- Update Email
//    func updateEmail( newEmail:String, success:@escaping(Bool)-> Void){
//        var params = [String : String]()
//        params["newEmail"] = newEmail
//
//        apiManager.patchRequest(APIEndTails.getInstance().Email, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST UPDATE_EMAIL ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    //MARK:- Change Password
//    func changePassword(currentPassword: String , newPassword: String, res: @escaping(String) -> Void){
//
//        var params = [String : String]()
//        params["currentPassword"] = currentPassword
//        params["newPassword"] = newPassword
//
//        apiManager.patchRequest(APIEndTails.getInstance().Password, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        res(msg)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST CHANGE_PASSWORD ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    //MARK:- Validate Phone
//    /// Validate Phone API
//    /// - Parameters:
//    ///   - phone: phon no
//    ///   - countryCode: dial code
//    ///   - success: respone True or False
//    func validatePhone(phone: String, countryCode: String, success: @escaping ([String: Any])->Void){
//        var params = [String : String]()
//        params["phoneNumber"] = phone
//        params["countryCode"] = countryCode
//        apiManager.postRequest(APIEndTails.getInstance().ValidatePhoneNumber, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST VALIDATE_PHONE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//
//
//
//
//    //MARK:- ReSend OTP to Phone or email
//    /// Send OTP to Phone or email
//    /// - Parameters:
//    ///   - emailOrPhone: phonNo or emailAddress
//    ///   - type: 1- phone , 2- email
//    ///   - countryCode: ony require  for validate phon no
//    ///   - trigger: 1 - Register,2 - Forgot Password, 3-change number, 4-login with phone OTP, 5 - email varification
//    ///   - success: response of api
//    func reSendOTP(emailOrPhone: String,type: String, countryCode: String = "",trigger: Int, userId: String, success: @escaping ([String:Any])-> Void){
//
//        var params = [String : Any]()
//        params["emailOrPhone"] = emailOrPhone
//        params["type"] = type
//        if countryCode != ""{
//            params["countryCode"] = countryCode
//        }
//        params["trigger"] = trigger
//        params["userId"] = userId
//
//        apiManager.postRequest(APIEndTails.getInstance().ResendVerificationCode, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any]{
//                        success(data)
//                    }
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//
//                    if let data = response["data"] as? [String: Any]{
//                        success(data)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST SEND_OTP_PHONE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    //MARK:- Send OTP to Phone
//    /// Send OTP to Phone or email
//    /// - Parameters:
//    ///   - phoneNumber: phonNo
//    ///   - countryCode: ony require  for validate phon no
//    ///   - trigger: 1-Register ,3-Change number
//    ///   - success: response of api
//    func sendOTP(phoneNumber: String, countryCode: String,trigger: Int, success: @escaping ([String:Any])-> Void){
//
//        var params = [String : Any]()
//        params["phoneNumber"] = phoneNumber
//        params["countryCode"] = countryCode
//        params["trigger"] = trigger
//        params["userId"] = Utility.getUserid() ?? ""
//
//        apiManager.postRequest(APIEndTails.getInstance().SendVerificationCode, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any]{
//                        success(data)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST SEND_OTP_PHONE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    //MARK:- Forgot Password
//
//    /// forgot Password API
//    /// - Parameters:
//    ///   - emailOrPhone: value of email or phone
//    ///   - countryCode: country code
//    ///   - type: Type 1 - Phone , 2 - email
//    ///   - success: response with verification ID
//    func forgotPassword(emailOrPhone: String, countryCode: String,type: String, success: @escaping ([String:Any])-> Void, failure: ((Bool)->Void)?){
//
//        var params = [String : Any]()
//        params["emailOrPhone"] = emailOrPhone
//        params["type"] = type
//        params["countryCode"] = countryCode
//
//
//        apiManager.postRequest(APIEndTails.getInstance().RecoverPassword, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any]{
//                        success(data)
//                        failure?(false)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                        failure?(true)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST SEND_OTP_PHONE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    //MARK - Pratch Profile
//    func updateProfileDetail(updatedValues:[String: String], success: @escaping (Bool)-> Void){
//
//        var params = [String : String]()
//
//        if let firstName = updatedValues[editProfilePlaceHolder.name.title] {
//            params["firstName"] = firstName
//        }
//
//        if let lastName = updatedValues[editProfilePlaceHolder.surname.title]{
//            params["lastName"] = lastName
//        }
//
//        if let phonNumber = updatedValues[editProfilePlaceHolder.phone.title] {
//            params["phoneNumber"] = phonNumber
//        }
//
//        if let dateOfBirth = updatedValues[editProfilePlaceHolder.dateOfBirth.title] {
//            params["dateOfBirth"] = dateOfBirth
//        }
//
//        if let country = updatedValues[editProfilePlaceHolder.country.title] {
//            params["country"] = country
//        }
//
//        if let bio = updatedValues[editProfilePlaceHolder.bio.title] {
//            params["bio"] = bio
//        }
//
//        if let image = updatedValues[editProfilePlaceHolder.profilePic.title] {
//            params["profilePic"] = image
//        }
//
//        if let website = updatedValues[editProfilePlaceHolder.website.title] {
//            params["website"] = website
//        }
//
//        if let fbId = updatedValues["facebookId"]{
//            params["facebookId"] = fbId
//        }
//
//        if let googleId = updatedValues["googleId"]{
//            params["googleId"] = googleId
//        }
//
//        if let din = updatedValues["DIN"]{
//            params["din"] = din
//        }
//
//        apiManager.patchRequest(APIEndTails.getInstance().Profile, params: params, success: { (response) in
//            print(response)
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST PATCH_PROFILE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    //MARK:- Sign Out API
//
//    func signOutAPI(success: @escaping(Bool) -> Void, failed:((Bool)->Void)?){
//
//        let params = [  APIRequestParams.getInstance().DeviceID :Utility.DeviceId , APIResponseParams.getInstance().refreshToken : KeychainHelper.sharedInstance.getRefreshToken() ]
//
//        apiManager.postRequest(APIEndTails.getInstance().sighOut, params: params, success: { (response) in
//
//
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        // Disconnect MQTT and clear DB
//                        let fcmTopic:String = "/topics/" + UserProfile.shared.profile.fcmTopic
//                        Messaging.messaging().unsubscribe(fromTopic: fcmTopic) { error in
//                            if error != nil{
//                                print(error!.localizedDescription)
//                            }
//                        }
//                        Messaging.messaging().unsubscribe(fromTopic: "/topics/sendToAll") { error in
//                            if error != nil{
//                                print(error!.localizedDescription)
//                            }
//                        }
//                        MQTT.sharedInstance.disconnectMQTTConnection()
//                        MQTT.sharedInstance.manager = nil
//                        MQTTChatManager.sharedInstance.unsubscribeAllTopics()
//                        RealmManager.sharedInstance.deleteData()
//                        //clear data from keychain and do guestLogin
//                        KeychainHelper.sharedInstance.clearKeychain()
//                        SplashViewModel().guestLogin()
//                        let url:String = "/topics/" + UserProfile.shared.profile.fcmTopic
//                        Messaging.messaging().unsubscribe(fromTopic:url)
//                        UserProfile.shared.profile = Profile(modelData: ["_id":"logged out"])
//                        success(true)
//
//
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                        KeychainHelper.sharedInstance.clearKeychain()
//                        SplashViewModel().guestLogin()
//                        UserProfile.shared.profile = Profile(modelData: ["_id":"logged out"])
//                        failed?(false)
//
//                    }
//                }
//            }
//
//
//        }) { (Error) in
//            print(Error)
//            print("#### POST SIGN OUT ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    func deleteAsset(assetId: String, success: @escaping ([String:Any])-> Void){
//        var params = [String:Any]()
//        params["assetId"] = [assetId]
//        params["status"] = "4" ///4 - delete
//        apiManager.deleteRequest( APIEndTails.getInstance().deleteAsset , params: params, success: { (response) in
//            print(response)
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### DELETE ASSET ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    //MARK:- Get Asset Category
//    ///status code - 1 for active categories
//    func getAssetCategotories(categories:@escaping ([AssetCategory])->Void){
//        let params = [APIRequestParams.getInstance().statusCode : "1"]
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().AssetType), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        categories(AssetCategories(data: response).assetCategories)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET CATEGORY ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    //Product like and dislike
//    func likeDislike(assetId:String, isLike: Bool, success:((Bool) -> Void)? = nil){
//        var params = [String:Any]()
//        params["assetid"] = assetId
//        params["like"] = isLike
//        params["userId"] = Utility.getUserid() ?? ""
//        params["skip"] = "0"
//        params["limit"] = "10"
//        apiManager.postRequest(APIEndTails.getInstance().likeDislike, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg,isLike)
//                        success?(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST LIKE_DISLIKE ERROR ####")
//            self.showSomethingWrongError()
//        }
//        //
//    }
//
//
//    /// Get likers of the Asset
//    /// - Parameters:
//    ///   - assetId: Asset Id
//    ///   - skip: skip
//    ///   - limit: page limit
//    ///   - success: get list of users who liked asset with AssetID
//    func getLikersOfAsseet( _ assetId:String, skip: String, limit: String, searchText: String? = nil, success: @escaping ([Profile]?) -> Void)  {
//
//        var params = [String: String]()
//        params["assetId"] = assetId
//        params["skip"] = skip
//        params["limit"] = limit
//
//        if searchText != "" {
//            params["search"] = searchText
//        }
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().likeDislike), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let users = response["result"] as? [[String: Any]]{
//                        var likedUsers = [Profile]()
//                        for userData in users{
//                            likedUsers.append( Profile(modelData: userData))
//                        }
//                        success(likedUsers)
//                    }
//                }else{
//                    success(nil)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET LIKE_DISLIKE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//
//    /// Get Viewers of the Asset
//    /// - Parameters:
//    ///   - assetId: Asset Id
//    ///   - skip: skip
//    ///   - limit: page limit
//    ///   - success: get list of users who Viewed asset with AssetID
//    func getViewersOfAsseet( _ assetId:String, skip: String, limit: String, searchText: String? = nil, success: @escaping ([Profile]?) -> Void)  {
//
//        var params = [String: String]()
//        params["assetId"] = assetId
//        params["skip"] = skip
//        params["limit"] = limit
//
//        if searchText != "" {
//            params["search"] = searchText
//        }
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().views), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let users = response["data"] as? [[String: Any]]{
//                        var likedUsers = [Profile]()
//                        for userData in users{
//                            likedUsers.append( Profile(modelData: userData))
//                        }
//                        success(likedUsers)
//                    }
//                }else{
//                    success(nil)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET VIEWERS ERROR ####")
//            self.showSomethingWrongError()
//        }
//
//    }
//
//
//
//
//    /// Get Favourite Assets of User
//    /// - Parameters:
//    ///   - userId: userId
//    ///   - success: get array of Assets
//    func getFavouriteAssetsOfUser(_ userId: String, skip: String, limit: String, failed: ((Bool) -> Void)? = nil, success: @escaping (([ProductModel]) -> Void)){
//        var params = [String: String]()
//        params["userId"] = userId
//        params["skip"] = skip
//        params["limit"] = limit
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().likeDislike), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let likedAssetsData = response["result"] as? [[String:Any]]{
//                        if likedAssetsData.count == 0{
//                            failed?(true)
//                        }
//                        var likedAssets = [ProductModel]()
//                        for assetdata in likedAssetsData{
//                            likedAssets.append(ProductModel(data: assetdata))
//                        }
//                        success(likedAssets)
//
//                    }
//                    else{
//                        failed?(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                        failed?(true)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET FAVOURITES ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Post a comment on the assest
//    /// - Parameters:
//    ///   - assetId: assestId
//    ///   - comment: comment text
//    ///   - success: resposne
//    func postComment(assetId: String, comment: String, success: @escaping (Bool)->Void){
//        var params = [String : String]()
//        params["assetId"] = assetId
//        params["comments"] = comment
//
//        apiManager.postRequest(APIEndTails.getInstance().comments, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST COMMENT ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    func getComments(assetId: String, skip: String, limit: String, success: @escaping ([Comment])-> Void){
//        var params = [String: String]()
//        params["assetId"] = assetId
//        params["skip"] = skip
//        params["limit"] = limit
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().comments), success: { (response) in
//            print(response)
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["data"] as? [[String: Any]]{
//                            var comments = [Comment]()
//                            for comment in data{
//                                comments.append(Comment(data: comment))
//                            }
//                            success(comments)
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET COMMENTS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    /// Get new refreshed Token for current User
//    func refteshToken(){
//
//        var params = [String : String]()
//        params["refreshToken"] = KeychainHelper.sharedInstance.getRefreshToken()
//        params["accessToken"] = KeychainHelper.sharedInstance.getAuthorizationKey()
//
//        apiManager.postRequest(APIEndTails.getInstance().refreshToken, params: params, success: { (response) in
//            print(response)
//            //todo - save new token in keychain
//        }) { (Error) in
//            print(Error)
//            print("#### POST REFRESH_TOKEN ERROR ####")
//        }
//    }
//
//
//
//    /// get all notifications
//    func getNotification(startPosition: Int, limit: Int, success:@escaping ([AppNotification])-> Void){
//
//        var params = [String:String]()
//        params["skip"] = String(startPosition)
//        params["limit"] = String(limit)
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().notification), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["data"] as? [[String: Any]]{
//                            var notifications = [AppNotification]()
//                            for notification in data{
//                                notifications.append(AppNotification(data: notification))
//                            }
//                            success(notifications)
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET NOTIFICATION ERROR ####")
//            self.showSomethingWrongError()
//        }
//
//    }
//
//
//
//    //MARK:- get delete Account Reasons
//    /// get reasons for delet account
//    func getReasons(type:String, success: @escaping ([Reason])-> Void){
//
//        var params = [String: String]()
//        params["type"] = type
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().reasons) , success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["data"] as? [[String: Any]]{
//                            var deteteProfileReasons = [Reason]()
//                            deteteProfileReasons.removeAll()
//                            for deletProfileReasonData in data{
//                                deteteProfileReasons.append(Reason(data: deletProfileReasonData))
//                            }
//                            success(deteteProfileReasons)
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET DELETE ACCOUNT REASONS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    func deleteProfile(reason:String, success: @escaping ([String: Any])-> Void){
//        var params = [String:String]()
//        params["id"] = Utility.getUserid() ?? ""
//        params["deleteConfirmation"] = "false"
//        params["reason"] = reason
//        apiManager.deleteRequest( params.stringFromHttpParameters(url: APIEndTails.getInstance().userAccount), params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(response)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET DELETE PROFILE ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    /// get active promotion of the asset
//    /// - Parameters:
//    ///   - assetId: asset id
//    ///   - planType: 1 - urgentToSell , 2 - Highlight
//    ///   - success: response as promotion array
//    func
//
//        getPromotionPlan(assetId: String , success: @escaping (_ plans: [Promotion], _ maxRadius: Int, _ unit: String)-> Void){
//        var params = [String:String]()
//        params["assetId"] = assetId
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().promoteAds), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let data = response["data"] as? [String: Any] {
//                        var promotions = [Promotion]()
//                        var maxhighlitRadius = 0
//                        var unit = "Kilometer"
//                        if let promotionsData = data["planData"] as? [[String:Any]]{
//                            for promotionData in promotionsData{
//                                promotions.append(Promotion(data: promotionData))
//                            }
//                        }
//
//                        if let maxhighlitRadiusData = data["maxHighlightRedius"] as? [String: Any] {
//                            if let radius = maxhighlitRadiusData["value"] as? Int {
//                                maxhighlitRadius = radius
//                            }
//
//                            if let tempUnit = maxhighlitRadiusData["unit"] as? String{
//                                unit = tempUnit
//                            }
//                        }
//                        success(promotions, maxhighlitRadius, unit)
//
//
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg, statusCode)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET PROMOTION ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    /// get Others promotion for the asset
//    /// - Parameters:
//    ///   - assetId: asset id
//    ///   - success: response as promotion array
//    func getOtherPromotionPlan(assetId: String, planType:String,offset: String, limit:String,  success: @escaping ([Promotion])-> Void){
//        var params = [String:String]()
//        params["assetId"] = assetId
//        params["planType"] = planType//Plan type 1 - urgentSale,2 - highlight
//        params["offset"] = offset
//        params["limit"] = limit
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().promoteAds), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let data = response["data"] as? [String: [[String:Any]]] {
//                        var promotions = [Promotion]()
//
//                        for values in data.values {
//                            for promotionData in values{
//                                promotions.append(Promotion(data: promotionData))
//                            }
//                        }
//                        success(promotions)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg, statusCode)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET OTHER PROMOTION ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func buyPromotion(assetId: String, planId: String,coverageScope: String? = nil, coverage: String? = nil, countryName: String? = nil, radius: String? = nil , pgTxnId: String, pgName: String, addressId: String, success:@escaping([String:Any])->Void){
//        var params = [String: String]()
//        params["assetId"] = assetId
//        params["planId"] = planId
//        params["pgTxnId"] = pgTxnId
//        params["pgName"] = pgName
//        params["addressId"] = addressId
//        params["triggerBy"] = "User"
//
//        if coverageScope != nil && coverageScope != ""{
//            params["coverageScope"] = coverageScope
//        }
//
//        if coverage != nil && coverage != "" {
//            params["coverage"] = coverage
//        }
//
//        if countryName != nil && countryName != "" {
//            params["countryName"] = countryName
//            if coverage == "" || coverage == nil{
//                params["coverage"] = countryName
//            }
//        }
//
//        if radius != nil && radius != "", Int(radius ?? "0") ?? 0 > 0{
//            params["radius"] = radius
//        }
//
//
//
//        apiManager.postRequest(APIEndTails.getInstance().buyPromotion, params: params, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST BUY_PROMOTION ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Report User or Asset
//    /// - Parameters:
//    ///   - reportType: asset or users
//    ///   - reportTypeId: id of the user or asset
//    ///   - commentReason: reson for report
//    ///   - success: response
//    ///   - reportReasonId: id of selected reasons
//    ///   - reason: comment
//    ///   - city: city
//    ///   - country: country
//    ///   - lat: lat
//    ///   - long: long
//    ///   - reportedId: id of user and asset
//    func report(reportType: String, reportReasonId: String, reason:String, city: String,country: String,lat:String,long:String,reportedId: String, success: @escaping (Bool)->Void){
//        var params = [String: String]()
//        params["reportType"] = reportType
//        params["reportReasonId"] = reportReasonId
//        params["reason"] = reason
//        params["city"] = city
//        params["country"] = country
//        params["lat"] = lat
//        params["long"] = long
//        params["reportedId"] = reportedId
//
//        apiManager.postRequest(APIEndTails.getInstance().report, params: params, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST REPORT_USER_ASSET ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//    /// Get Asser Detail API
//    /// - Parameters:
//    ///   - assetId: asset Id
//    ///   - success: response
//    func getAssetDetail(assetId: String, success:@escaping (ProductModel)->Void){
//        var params = [String:String]()
//        params["assetId"] = assetId
//        params["statusCode"] = "1"
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().PostDetails), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if  let data = response["result"] as? [String : Any]{
//                        success(ProductModel(data: data))
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST GET_ASSET_DETAILS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    func patchProcuct(params:[String:Any] , success: @escaping ([String: Any]) -> Void){
//
//        apiManager.patchRequest(APIEndTails.getInstance().assest, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 201 || statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### PATCH PRODUCT ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    func getFAQs(parentId: String = "" ,success:@escaping ([FAQ])->Void){
//
//        var params = [String:String]()
//        if parentId != ""{
//            params["parentId"] = parentId
//        }
//        apiManager.getRequest(params.stringFromHttpParameters(url:APIEndTails.getInstance().faq), success: { (response) in
//
//
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let faqsData = response["data"] as? [[String:Any]]{
//                        var faqsArray = [FAQ]()
//                        for faqdata in faqsData{
//                            faqsArray.append(FAQ(data: faqdata))
//                        }
//                        success(faqsArray)
//                    }
//
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg,APIEndTails.getInstance().Profile)
//
//                    }
//                }
//            }
//
//        }) { (error) in
//            print(error)
//            print("#### GET FAQs ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Register User as Promoter
//    /// - Parameters:
//    ///   - promoterId: UserId
//    ///   - pin: 5 digit unique pin
//    ///   - address: address of user //object with fields line1 , line2, Area, City, state, postCode, Country,addressName required
//    ///   - dob: date of birth of user
//    ///   - refCode: referal code
//    ///   - success: response
//    func registerAsPromoter(promoterId: String, pin: String, address: SearchedAddress, dob: String, refCode: String, name: String, surname: String  ,success: @escaping (_ success:Bool,_ msg:String)->Void){
//
//        var params = [String:Any]()
//        params["promoterId"] = promoterId
//        params["Pin"] = pin
//        params["Address"] = address.getDataFromModel()
//        if dob != ""{
//            params["dateOfBirth"] = dob
//        }
//        params["name"] = name
//        params["surname"] = surname
//        if refCode != "" {
//            params["sponsorCode"] = refCode
//        }
//
//        apiManager.postRequest(APIEndTails.getInstance().promoter, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if  let msg = response["message"] as? String{
//                        //                        print(data)
//                        success(true,msg)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        //                        Helper.showAlert(head: "Oops!", message: msg )
//                        success(false,msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST BECOME_A_PROMOTER ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Check for unique PIN
//    /// - Parameters:
//    ///   - pin: 5 digit pin
//    ///   - success: response
//    func checkPIN(pin:String, success: @escaping (Bool) -> Void){
//        var params = [String:String]()
//        params["pin"] = pin
//
//        apiManager.getRequest(params.stringFromHttpParameters(url:APIEndTails.getInstance().pin), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    success(true)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }else{
//                    success(false)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET PIN ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//
//    /// Follow API
//    /// - Parameters:
//    ///   - followingId: user id to whom follow
//    ///   - success: response
//    func follow(followingId:String, success: @escaping (Bool)->Void){
//        var params = [String:String]()
//        params["followingId"] = followingId
//        apiManager.postRequest(APIEndTails.getInstance().follow, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    success(true)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }else{
//                    success(false)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST FOLLOW ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// getFollowees API
//    /// - Parameters:
//    ///   - userId: user id of whom want to get followees
//    ///   - offset: offset
//    ///   - limit: page limit
//    ///   - success: respone
//    func getFollowing( offset: String, limit: String, searchText: String? = nil, userId: String? = nil, success: @escaping ([Profile]?) -> Void){
//        var params = [String:String]()
//
//        params["offset"] = offset
//        params["limit"] = limit
//
//        if let userId = userId, !userId.isEmpty {
//            params["userId"] = userId
//        }
//
//
//        if searchText != "" {
//            params["searchText"] = searchText
//        }
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().getFollowees), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any], let followeeData = data["followeeData"] as? [[String:Any]]{
//                        var followees = [Profile]()
//                        for userData in followeeData{
//                            followees.append(Profile(modelData: userData))
//                        }
//                        success(followees)
//                    }
//                }else{
//                    success(nil)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET FOLLOWEES ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    /// getFollowers API
//    /// - Parameters:
//    ///   - userId: user id of whom want to get followees
//    ///   - offset: offset
//    ///   - limit: page limit
//    ///   - success: respone
//    func getFollowers( offset: String, limit: String, searchText: String? = nil, userId: String? = nil, success: @escaping ([Profile]?) -> Void){
//        var params = [String:String]()
//
//        params["offset"] = offset
//        params["limit"] = limit
//
//        if let userId = userId, !userId.isEmpty {
//            params["userId"] = userId
//        }
//
//        if searchText != "" {
//            params["searchText"] = searchText
//        }
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().getFollowers), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any], let followeeData = data["followeeData"] as? [[String:Any]]{
//                        var followers = [Profile]()
//                        for userData in followeeData{
//                            followers.append(Profile(modelData: userData))
//                        }
//                        success(followers)
//                    }
//                }else{
//                    success(nil)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET FOLLOWEES ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    /// Get follow request of own user
//    /// - Parameters:
//    ///   - offset: page offset
//    ///   - limit: page limit
//    ///   - success: response
//    func getFollowReques(offset: String, limit: String, success: @escaping ([Profile]) -> Void){
//        var params = [String:String]()
//
//        params["offset"] = offset
//        params["limit"] = limit
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().followRequest), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let data = response["data"] as? [String: Any], let followRequestData = data["followRequestData"] as? [[String:Any]]{
//                        var followeRequest = [Profile]()
//                        for userData in followRequestData{
//                            followeRequest.append(Profile(modelData: userData))
//                        }
//                        success(followeRequest)
//                    }
//                }else{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET FOLLOW REQUEST ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    /// postFollowRequest APi
//    /// - Parameters:
//    ///   - targetId: Request Id
//    ///   - status: status of follow request 1 : ACCEPT , 2 : DENY Ex : 1
//    func postFollowRequest(targetId: String,status: String, success: @escaping (Bool) -> Void ){
//        var params = [String:String]()
//        params["targetId"] = targetId
//        params["status"] = status
//        apiManager.postRequest(APIEndTails.getInstance().followRequest, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    success(true)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }else{
//                    success(false)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST FOLLOW_REQUEST ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//
//
//    /// Unfollow API
//    /// - Parameters:
//    ///   - followingId: userId
//    ///   - success: response
//    func unfollow(followingId: String, success: @escaping (Bool) -> Void){
//        var params = [String:String]()
//        params["followingId"] = followingId
//        apiManager.postRequest(APIEndTails.getInstance().unfollow, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    success(true)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }else{
//                    success(false)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST UNFOLLOW ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Get Recent Search API
//    /// - Parameter success: list of recentPost, list of receentUser
//    func getRecentSearch(success: @escaping ([String],[Profile]) -> Void){
//        apiManager.getRequest(APIEndTails.getInstance().recentSearch,isLoaderEnable : false, success: { (response) in
//            var postStrings = [String]()
//            var userStrings = [Profile]()
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let resData = response["data"] as? [String:Any], let searchData = resData["data"] as? [[String:Any]], let userData = resData["user"] as? [[String:Any]]{
//
//                        for string in searchData{
//                            if let str = string["searchText"] as? String{
//                                postStrings.append(str)
//                            }
//                        }
//
//                        for user in userData{
//                            userStrings.append(Profile(modelData: user))
//                        }
//
//                        success(postStrings,userStrings)
//                    }
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(postStrings,userStrings)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(postStrings,userStrings)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET RECENT_SEARCH ####")
//        }
//    }
//
//    /// Get Suggested Items
//    /// - Parameters:
//    ///   - text: search String
//    ///   - success: list of string as per search text
//    func getAssetSuggestion(text: String, success: @escaping ([Item],[Profile]) -> Void){
//        var params = [String: String]()
//        params["searchItem"] = text
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().assetSuggestion),isLoaderEnable : false, success: { (response) in
//            var postArray = [Item]()
//            var userArray = [Profile]()
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let postData = response["data"] as? [[String:Any]]{
//                        for tempData in postData{
//                            postArray.append(Item(data: tempData))
//                        }
//                    }
//                    if let userData = response["users"] as? [[String:Any]]{
//                        for tempData in userData{
//                            userArray.append(Profile(modelData: tempData))
//                        }
//                    }
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//
//                    success(postArray,userArray)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(postArray,userArray)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET ASSET_SUGGESTION ####")
//        }
//    }
//
//
//    /// Validate userName API to check if username is already register or not
//    /// - Parameters:
//    ///   - userName: username to check
//    ///   - trigger: 1- signup,2- login
//    func validateUserName(userName: String,trigger: String, success: @escaping (Bool)-> Void){
//        var params = [String: String]()
//        params["username"] = userName
//        //        params["trigger"] = trigger
//        apiManager.postRequest( params.stringFromHttpParameters(url: APIEndTails.getInstance().UserName), params: nil, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(true)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(false)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST VALIDATE_USERNAME ####")
//            success(false)
//        }
//    }
//
//
//
//    func signUp(params:[String: Any], success: @escaping (Bool)-> Void){
//        apiManager.postRequest(APIEndTails.getInstance().SignUP, params: params, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    let keychainHelper = KeychainHelper.sharedInstance
//                    keychainHelper.storeData(data: response)
//                    self.getProfileDetail()
//                    keychainHelper.keychain.set(true, forKey: APIResponseParams.getInstance().firstTimeLogin)
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(true)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(false)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST SIGN_UP ####")
//            self.showSomethingWrongError()
//            success(false)
//        }
//    }
//
//
//
//    /// Verify OTP API
//    /// - Parameters:
//    ///   - code: OTP Code
//    ///   - countryCode: country code
//    ///   - phoneNumber: phone no
//    ///   - verificationId: verification Id
//    ///   - trigger: 1-register, 2-forgotpassword, 3-change number, 4-login
//    func verifyOTP(code: String, countryCode: String, phoneNumber: String, verificationId: String, trigger: Int, success: @escaping (Bool)-> Void){
//
//        var params = [String: Any]()
//        params["code"] = code
//        params["countryCode"] = countryCode
//        params["phoneNumber"] = phoneNumber
//        params["verificationId"] = verificationId
//        params["trigger"] = trigger
//        apiManager.postRequest(APIEndTails.getInstance().ValidateVerificationCode, params: params, success: { response in
//            print("111123421432")
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(true)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                    success(false)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST SIGN_UP ####")
//            self.showSomethingWrongError()
//            success(false)
//        }
//    }
//
//
//    /// Mark As Sold API
//    /// - Parameters:
//    ///   - assetId: id of asset
//    ///   - soldReason: selected reason text
//    ///   - success: response
//    func markAsSold(assetId: String, soldReason: String, success: @escaping (String)->Void){
//        var params = [String: Any]()
//        params["assetId"] = assetId
//        params["soldReason"] = soldReason
//
//        apiManager.patchRequest(APIEndTails.getInstance().sold, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(msg)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### PATCH MARK_AS_SOLD ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//
//    func getCategories(success: @escaping ([Category])-> Void){
//        var params = [String: String]()
//        params[APIRequestParams.getInstance().statusCode] = "1"
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().AssetType), isLoaderEnable: true, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//
//                    if let data = response["data"] as? [[String:Any]]{
//                        var categories = [Category]()
//                        for categorydata in data{
//                            categories.append(Category(data: categorydata))
//                        }
//                        success(categories)
//                    }
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET_CATEGORIES ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    /// Get Currency API
//    /// - Parameter success: array of currency
//    func getCurrency(success: @escaping ([Currency]) -> Void) {
//        apiManager.getRequest(APIEndTails.getInstance().currencies, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//
//                    if let data = response["data"] as? [[String:Any]]{
//                        var currencyArray = [Currency]()
//                        currencyArray.removeAll()
//
//                        for item in data{
//                            let tempItem = Currency(data: item)
//                            currencyArray.append(tempItem)
//                        }
//                        success(currencyArray)
//                    }
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET_COUNTRY ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// get attributes api
//    /// - Parameters:
//    ///   - param: attributes id
//    ///   - success: array of attributes group
//    func getAttributesGroups(params: [String: String], success: @escaping ([AttributesGroups]?)-> Void){
//
//        apiManager.getRequest(params.stringFromHttpParameters(url:  APIEndTails.getInstance().AttributesGroup), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    if let attributedGroups = AttributesGroupsCollection(response: response).attributesGroups{
//                        success(attributedGroups)
//                    }else{
//                        print("Attributed Groups Not found")
//                    }
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                    success(nil)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET_ATTRIBUTES_GROUP ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Post product
//    /// - Parameters:
//    ///   - param: params
//    ///   - success: response
//    func postProduct(param: [String: Any], success: @escaping([String:Any])-> Void){
//        apiManager.postRequest(APIEndTails.getInstance().assest, params: param, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 201 || statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST_PRODUCT ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    /// Get Country API
//    /// - Parameters:
//    ///   - searchText: searched Text
//    ///   - skip: skip items
//    ///   - limit: limit of page
//    ///   - success: list of countrys
//    func getCountries(searchText: String, skip: String, limit: String ,success: @escaping ([Country]?)->Void){
//
//        var params = [String:String]()
//        if searchText != "" {
//            params["searchText"] = searchText
//        }
//
//        params["skip"] = skip
//        params["limit"] = limit
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().countries), success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    var countryArray = [Country]()
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//
//                    if let data = response["data"] as? [String:Any]{
//
//                        if let countriesData = data["countries"] as? [[String: Any]]{
//                            for countryData in countriesData{
//                                countryArray.append(Country(data: countryData))
//                            }
//                            success(countryArray)
//                        }
//                    }else{
//                        success(nil)
//                        //                        Helper.showAlert(head: "Oops!", message: "No data found.")
//                    }
//                }else{
//                    success(nil)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET_COUNTRIES ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    func validateReferralCode(referralCode:String,success:@escaping (Bool)->Void){
//        var params = [String:String]()
//        params["referralCode"] = referralCode
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().validateReferralCode),isLoaderEnable: false, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if   statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(true)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(false)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET_VALIDATE_REFERRAL_CODE ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    //MARK:- Reactive Ad API
//    func reActiveAdAPI(productId: String,success:@escaping([String:Any])->Void){
//        var params = [String:String]()
//        params["assetId"] = productId
//        apiManager.patchRequest(APIEndTails.getInstance().reActivate, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if   statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### PATCH_REACTIVATE_AD ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    //MARK:- check fb email
//    func SocialVerify(email: String,trigger: String,success:@escaping([String:Any])->Void){
//        var param = [String:Any]()
//        param["id"] = email
//        param["trigger"] = trigger
//        apiManager.postRequest(APIEndTails.getInstance().validateFacebookEmail, params: param,success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if   statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(response)
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### EMAIL_IS_ALREADY_IN_USE ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func sendContacts(contacts: [[String:Any]],success:@escaping([Profile],[String])->Void){
//        var param = [String:Any]()
//        param["contacts"] =  contacts
//        Helper.showPI(string: StringConstants.getInstance().ProgressIndicator())
//
//        apiManager.postRequest(APIEndTails.getInstance().sendContacts, params: param, success: { (response) in
//            Helper.hidePI()
//            if let statusCode = response["statusCode"] as? Int {
//                if   statusCode == 200 {
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    var appUsers = [Profile]()
//                    var nonAppUser = [String]()
//                    if let contacts = response["contacts"] as? [[String:Any]]{
//
//                        for contactData in contacts{
//                            appUsers.append(Profile(modelData: contactData))
//                        }
//
//                    }
//                    if let otherContacts = response["otherContact"] as? [String]{
//                        nonAppUser = otherContacts
//                    }
//
//                    success(appUsers,nonAppUser)
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg)
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### Send Contacts ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func getInsights(assetId: String, filter: String, trigger: String?, country: String?, success:@escaping ([Insights])-> Void){
//
//        var params = [String:String]()
//        params["filter"] = filter
//        params["assetId"] = assetId
//        params["trigger"] = trigger
//        params["countryName"] = country
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().insights), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["data"] as? [[String: Any]]{
//                            var insights = [Insights]()
//                            for insight in data{
//                                insights.append(Insights(data: insight))
//                            }
//                            success(insights)
//                        }
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET NOTIFICATION ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func addAddress(address: String, area: String?, city: String,state: String, country: String, zipCode: String, lat: Double, long: Double, success:@escaping (Bool)-> Void){
//
//        var params = [String:String]()
//        params["address"] = address
//        params["area"] = area
//        params["city"] = city
//        params["state"] = state
//        params["country"] = country
//        params["zipCode"] = zipCode
//        params["lat"] = String(lat)
//        params["long"] = String(long)
//
//        apiManager.postRequest(APIEndTails.getInstance().address, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### POST ADD ADDRESS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func getAddress(addressId: String?, success:@escaping ([SearchedAddress])-> Void){
//
//        var params = [String:String]()
//        params["addressId"] = addressId
//
//        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().address), success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    var selectedLocation = [SearchedAddress]()
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        if let data = response["data"] as? [[String: Any]]{
//                            for data in data{
//                                selectedLocation.append(SearchedAddress(data: data))
//                            }
//                        }
//                    }
//                    success(selectedLocation)
//                }else{
//                    let selectedLocation = [SearchedAddress]()
//                    success(selectedLocation)
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### GET ADDRESS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func editAddress(addressId: String, address: String, area: String?, city: String,state: String, country: String, zipCode: String, lat: Double, long: Double, success: @escaping (Bool)-> Void) {
//
//        var params = [String:String]()
//        params["addressId"] = addressId
//        params["address"] = address
//        params["area"] = area
//        params["city"] = city
//        params["state"] = state
//        params["country"] = country
//        params["zipCode"] = zipCode
//        params["lat"] = String(lat)
//        params["long"] = String(long)
//
//        apiManager.patchRequest( APIEndTails.getInstance().address, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### PATCH ADDRESS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//    func deleteAddress(addressId: String, success: @escaping (Bool)-> Void) {
//
//        var params = [String:String]()
//        params["addressId"] = addressId
//
//        apiManager.deleteRequest(params.stringFromHttpParameters(url:APIEndTails.getInstance().address) , params: nil, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### DELETE ADDRESS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
//    func setDefaultAddress(addressId: String, success: @escaping (Bool)-> Void) {
//
//        var params = [String:String]()
//        params["addressId"] = addressId
//
//        apiManager.patchRequest( APIEndTails.getInstance().defaultAddress, params: params, success: { (response) in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        success(true)
//                        ApiHelper.shared.getProfileDetail()
//                    }
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### DEFAULT ADDRESS ERROR ####")
//            self.showSomethingWrongError()
//        }
//    }
//
//
    
//    //Stripe Sign Up API
    func stripeSignUp(params: [String:Any], success:@escaping (Bool)-> Void){

        apiManager.postRequest(APIEndTails.getInstance().connectAccount, params: params, success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200{
                    if let msg = response["message"] as? String{
                        print(msg)
                    }
                    success(true)
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                }
            }
        }) { (Error) in
            print(Error)
            print("#### STRIPE SIGNUP ####")
            self.showSomethingWrongError()
        }
    }
//
//
//
//    //Create Wallet
//    func createWallet(userId: String, success: @escaping (Bool)->Void){
//        var params = [String: Any]()
//        params["userId"] = userId
//        params["userType"] = "user"
//        params["currency"] = "USD" // temp
//        apiManager.postRequest(APIEndTails.getInstance().wallet, params: params, success: { response in
//            if let statusCode = response["statusCode"] as? Int {
//                if statusCode == 200{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                    }
//                    success(true)
//                }else{
//                    if let msg = response["message"] as? String{
//                        print(msg)
//                        Helper.showAlert(head: "Oops!", message: msg )
//                    }
//                    success(false)
//                }
//            }
//        }) { (Error) in
//            print(Error)
//            print("#### CREATE WALLET ERROR ####")
//            self.showSomethingWrongError()
//        }
//
//    }
//
//    //Create Wallet
    func getWallet(userId: String, success: @escaping (Bool)->Void){
        var params = [String:String]()
        params["userId"] = userId
        params["userType"] = "user"

        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().wallet), success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    if let data = response["data"] as? [String:Any]{
                        if let walletData = data["walletData"] as? [[String:Any]] {
                            for firstData in walletData {
                                if let currency = firstData["currency"] as? String, currency == Utility.getWalletCurreny() {
                                    if let walletId = firstData["walletid"] as? String{
                                        KeychainHelper.sharedInstance.setWalletId(id: walletId)
                                    }

                                    if let balance = firstData["balance"] as? String{
                                        KeychainHelper.sharedInstance.setWalletBalance(balance: balance)
                                        UserDefaults.standard.set(balance, forKey: AppConstants.UserDefaults.walletBalance)
                                    }
                                    if let walletCurrencySymbol = firstData["currency_symbol"] as? String {
                                        UserDefaults.standard.set(walletCurrencySymbol, forKey: AppConstants.UserDefaults.walletCurrecnySymbol)
                                    }
                                    if let walletCurrency = firstData["currency"] as? String {
                                        UserDefaults.standard.set(walletCurrency, forKey: AppConstants.UserDefaults.walletCurrency)
                                    }
                                }
                                
                                if let currency = firstData["currency"] as? String, currency == "COIN" {
                                    if let walletId = firstData["walletid"] as? String{
                                        KeychainHelper.sharedInstance.setCoinWalletId(id: walletId)
                                    }
                                    
                                    if let balance = firstData["balance"] as? String{
                                        KeychainHelper.sharedInstance.setCoinWalletBalance(balance: balance)
                                        if AppConstants.appType == .picoadda {
                                            UserDefaults.standard.set(balance, forKey: "picoaddacoinwalletbalance")
                                        }else{
                                            UserDefaults.standard.set(balance, forKey: "dublycoinwalletbalance")
                                        }
                                        
                                    }
                                }
                            }
                        }
                        if let walletEarningData = data["walletEarningData"] as? [[String:Any]] ,let firstData = walletEarningData.first  {
                            if let walletId = firstData["walletearningid"] as? String{
                                KeychainHelper.sharedInstance.setEarningWalletId(id: walletId)
                            }

                            if let balance = firstData["balance"] as? String{
                                KeychainHelper.sharedInstance.setEarningWalletBalance(balance: balance)
//                                UserDefaults.standard.set(balance, forKey: AppConstants.UserDefaults.walletBalance)
                            }
                        }
                    }
                    success(true)
                }else{
                    // if Wallet not created or error
                    KeychainHelper.sharedInstance.setWalletBalance(balance: "0")
                    UserDefaults.standard.set("0", forKey: AppConstants.UserDefaults.walletBalance)
                    success(false)
                }
            }
        }) { (Error) in
            print(Error)
            print("#### GET WALLET ERROR ####")
            self.showSomethingWrongError()
        }
    }
 
    //    //GetTransactions API
    func geTransactions(walletId: String, txnType: String, pageState: String,fetchSize: String, success: @escaping ([Transaction],String) -> Void){
        var params = [String:String]()
        params["txnType"] = txnType
        if !pageState.isEmpty{
            params["pageState"] = pageState
        }
        params["fetchSize"] = fetchSize
        params["walletId"] = walletId
        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().transactions), success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    if let data = response as? [String:Any] {
                        print("*******\(data)")
                        var transactions = [Transaction]()
                        transactions.removeAll()
                        var pageState = ""

                        if let tempPageState = data["pageState"] as? String, !tempPageState.contains("null"){
                            pageState = tempPageState
                        }

                        if let transactionsData = data["data"] as? [[String:Any]]{
                            for trans in transactionsData{
                                transactions.append(Transaction(data: trans))
                            }
                            success(transactions,pageState)
                        }
                    }
                }else{
                    success([Transaction](),"")
                }
            }
        }) { (Error) in
            print(Error)
            print("#### GET WALLET ERROR ####")
            self.showSomethingWrongError()
        }

    }
//
//    //Get stripeConnectAccount
    func getStripeConnectAccount(success: @escaping (String,String,[Bank])->Void){
        Helper.showPI(string: "")
        let params = ["userId": Utility.getUserid() ?? ""]
        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().connectAccount), success: { response in
            Helper.hidePI()
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    var status = ""
                    var id = ""
                    var banks = [Bank]()
                    if let data = response["data"] as? [String:Any] {
                        if let tempId = data["id"] as? String{
                            id = tempId
                        }
                        if let individuals = data["individual"] as? [String: Any], let verification = individuals["verification"] as? [String:Any] {
                            if let tempStatus = verification["status"] as? String{
                                status = tempStatus
                            }
                        }
                        
                        if let externamAccunt = data["external_accounts"] as? [String:Any], let data = externamAccunt["data"] as? [[String: Any]]{
                            for accountData in data{
                                banks.append(Bank(data: accountData))
                            }
                        }
                        success(id,status,banks)
                    }
                }else{
                    success("","Create Account",[Bank]())
                }
            }
        }){ (Error) in
            Helper.hidePI()
            print(Error)
            print("#### GET STRIPE CONNECT ERROR ####")
            self.showSomethingWrongError()
        }
    }
//
//
//
//    //Add Bank Account to Stripe
    func addBankAccountToStripe(accountHolderName:String,routingNumber:String,account_number:String, success: @escaping (Bool)->Void){
        var params = [String:Any]()
        params["email"] = Utility.getUserEmail()
        params["account_number"] = account_number
        params["routing_number"] =  routingNumber//temp static value
        params["account_holder_type"] = "individual" //temp static value
        params["account_holder_name"] = accountHolderName
        params["country"] = "us" //temp static value
        params["currency"] = "USD" // for dynamic //temp static value

        Helper.showPI(_message: "")
        apiManager.postRequest(APIEndTails.getInstance().externalAccount, params: params, success: { (response) in
            Helper.hidePI()
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    print(response)
                    success(true)
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops".localized + "!", message: msg )
                    }
                }
            }
        }) { (Error) in
            print(Error)
            print("#### POST STRIPE BANK ACCOUNT ####")
            self.showSomethingWrongError()
        }
    }
 
    ///   recharge wallet API
    /// - Parameters:
    ///   - amount: amount
    ///   - trigger: wallet recharge,payment
    ///   - description: description
    ///   - notes: notes
    ///   - txnType: 1-CREDIT,2-DEBIT
    func rechargeWallet(params: [String:Any], success: @escaping  (Transaction?)->Void){


        apiManager.postRequest(APIEndTails.getInstance().walletRecharge, params: params, success: { response in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    if let data = response["data"] as? [String:Any]{
                        var transactionDetails: Transaction?
                        transactionDetails = Transaction(data: data)
                        success(transactionDetails ?? nil)
                    }
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                }
            }

        }) { (Error) in
            print(Error)
            print("#### POST RECHARGE WALLET ####")
            self.showSomethingWrongError()
        }
    }
 
    /// create charge in stripe
    /// - Parameters:
    ///   - params: params
    ///   - success: response as bool
    func creatChargeFromStripe( params: [String:Any],success: @escaping  (Bool)-> Void){

        apiManager.postRequest(APIEndTails.getInstance().createCharge, params: params, success: { response in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    print(response)
                    success(true)

                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                    success(false)
                }
            }

        }) { (Error) in
            print(Error)
            print("#### POST CREATE CHARGE ####")
            self.showSomethingWrongError()
        }
    }
//
//
//
    /// withdraw money api
    /// - Parameters:
    ///   - params: params
    ///   - success: response as bool
    func withdrawMoney(params: [String:Any],success: @escaping  (Transaction?)-> Void){

        apiManager.postRequest(APIEndTails.getInstance().withdrawMoney, params: params, success: { response in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    if let data = response["data"] as? [String:Any]{
                        var transactionDetails: Transaction?
                        transactionDetails = Transaction(data: data)
                        success(transactionDetails ?? nil)
                    }
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                }
            }

        }) { (Error) in
            print(Error)
            print("#### POST WITHDRAW MONEY ####")
            self.showSomethingWrongError()
        }
    }
    
    /// withdraw money api
    /// - Parameters:
    ///   - params: params
    ///   - success: response as bool
    func withDrawAmount(params: [String:String], success: @escaping (WithdrawAmountDetails)->Void){
        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().withdrawAmt), success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                var transaction: WithdrawAmountDetails?
                if statusCode == 200 {
                    if let data = response["data"] as? [String:Any]{
                                success(WithdrawAmountDetails(data: data))
                    }
                    
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                }
            }
        }) { (Error) in
            print(Error)
            print("#### GET WITHDRAW LOGS ####")
            self.showSomethingWrongError()
        }
    }
    
//
    /// withdraw money api
    /// - Parameters:
    ///   - params: params
    ///   - success: response
    func getEstimateAmount( params: [String:Any],success: @escaping  (String)-> Void){

        apiManager.postRequest(APIEndTails.getInstance().estimateAmount, params: params, success: { response in
            print(response["statusCode"])
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    print(response)
                    success("")
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                    success("")
                }
            }

        }) { (Error) in
            print(Error)
            print("#### GET ESTIMATE AMOUNT ####")
            self.showSomethingWrongError()
        }
    }
//
//
    func getWithdrawLogs(pageState: String,fetchSize:String, success: @escaping ([Transaction],String)->()){
        var params = [String:String]()
        if pageState != "" {
            params["pageState"] = pageState
        }
        params["userId"] = Utility.getUserid() ?? ""
        params["fetchSize"] = fetchSize
        params["userType"] = "user"
        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().withdrawLog), success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                var pageState = ""
                var txns = [Transaction]()
                if statusCode == 200 {
                    print(response)
                    if let data = response["data"] as? [String:Any]{


                        if let txnData = data["data"] as? [[String: Any]]{
                            for tempTxnData in txnData{
                                txns.append(Transaction(data: tempTxnData))
                            }
                        }
                        if let tempPageState = data["pageState"] as? String, !pageState.contains("null"){
                            pageState = tempPageState
                        }
                        success(txns,pageState)
                    }

                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                    success(txns,pageState)
                }
            }
        }) { (Error) in
            print(Error)
            print("#### GET WITHDRAW LOGS ####")
            self.showSomethingWrongError()
        }
    }
//
    
    // get payment methods as per country
        /// - Parameters:
        ///   - countryCode: country code
        ///   - offset: page no
        ///   - limit: page count
        func getWithdrowMethods(countryCode: String, offset: String, limit: String, success: @escaping ([WithdrawOption])->()){
            
            var params = [String: String]()
            params["countryCode"] = "IN"
            params["offset"] = offset
            params["limit"] = limit
            
            apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().withdrowMethods), success: { response in
                var withdarwOptions = [WithdrawOption]()
                if let statusCode = response["statusCode"] as? Int {
                    if statusCode == 200 {
                        if let data = response["data"] as? [String:Any], let tempData = data["data"] as? [[String: Any]]{
                            for withdrawOptionData in tempData{
                                withdarwOptions.append(WithdrawOption(data: withdrawOptionData))
                            }
                            success(withdarwOptions)
                        }
                    }else{
                        if let msg = response["message"] as? String{
                            print(msg)
                        }
                        success(withdarwOptions)
                    }
                }
            }) { (Error) in
                print(Error)
                print("#### POST WITHDRAW OPTIONS  ####")
                self.showSomethingWrongError()
            }
        }
    
//
    func deleteBank(bankId: String, success:@escaping (Bool)->Void){
        var params = [String: String]()
        params["accountId"] = bankId
        apiManager.deleteRequest(APIEndTails.getInstance().externalAccount, params: params, success: { response in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                    print(response)
                    success(true)
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                    success(false)
                }
            }

        }) { (Error) in
            print(Error)
            print("#### DELETE EXTERNAL ACCOUNT ####")
            self.showSomethingWrongError()
        }
    }

    func getWithdrawDetails(withdrawId:String, success: @escaping (Transaction)->Void){
        var params = [String:String]()
        params["withdrawId"] = withdrawId
        apiManager.getRequest(params.stringFromHttpParameters(url: APIEndTails.getInstance().withdrawlDetails), success: { (response) in
            if let statusCode = response["statusCode"] as? Int {
                if statusCode == 200 {
                        if let tranData = response["data"] as? [String: Any]{
                            let data = Transaction(data: tranData)
                            success(data)
                        }
                }else{
                    if let msg = response["message"] as? String{
                        print(msg)
                        Helper.showAlert(head: "Oops!", message: msg )
                    }
                }
            }
        }) { (Error) in
            print(Error)
            print("#### GET WITHDRAW LOGS ####")
            self.showSomethingWrongError()
        }
    }
}

extension Dictionary where Key : CustomStringConvertible, Value : CustomStringConvertible {
    
    /// function used to create query string
    ///
    /// - Parameter url: pass API end point (base url and API End tails
    /// - Returns: query String
    func stringFromHttpParameters(url : String ) -> String {
        var parametersString = url
        for  ( offset: i, element: (key: key, value: value)) in self.enumerated() {
            i == 0 ? (parametersString += "?" + key.description + "=" + value.description.replacingOccurrences(of: " ", with: "%20")  ) : ( parametersString += "&" + key.description + "=" + value.description.replacingOccurrences(of: " ", with: "%20") )
        }
        parametersString = parametersString.replacingOccurrences(of: "|", with: "%7C")
        return parametersString
    }
}

