//
//  ProfileViewModel.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 18/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Locksmith
import Alamofire
import CocoaLumberjack

enum ProfileViewType {
    case pPostCollectionView
    case pLikeCollectionView
    case pTagCollectionView
    case pCahnnelTableView
    case pStoryCollectionView
    case pLiveVideosCollectionView
    case pUnLockedPostsCollectionView
    case pBookMarkedCollectionView
}
class ProfileViewModel: NSObject {
    
    /// Variables and Declarations
    let profileApi = SocialAPI()
    var userProfileModel: UserProfileModel?
    var postModelArray = [SocialModel]()
    var unLockedPostModelArray = [SocialModel]()
    var tagModelArray = [SocialModel]()
    var likeModelArray = [SocialModel]()
    var storyModelArray = StoriesModel()
    var liveStreamModelArray = [LiveVideosModel]()
    var allStories:[userStory] = []
    var channelModelArray = [ProfileChannelModel]()
    var bookMarkedArray = [SavedCollectionModel]()
    let couchbaseObj = Couchbase.sharedInstance
    var postOffset: Int = -20
    var bookMarkOffset: Int = -20
    var unLockedPostOffSet:Int = -20
    var tagOffset: Int = -20
    var likeOffset: Int = -20
    var channelOffset: Int = -20
    var storyOffset: Int = -20
    var liveOffset:Int = -20
    var livelimit: Int = 2
    let limit: Int = 20
    var isSelf: Bool = false
    
    
    /// TO ger profile details data from server
    ///
    /// - Parameters:
    ///   - strUrl: String url
    ///   - complitation: complitation after complitation of api
    func userDetailsService(strUrl: String,params:[String:Any]?, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
        let strUrlWithOutSpace = strUrl.replace(target: " ", withString: "%20")
        profileApi.getSocialData(withURL: strUrlWithOutSpace, params: params) { (response, error) in
            if let result = response as? [Any]{
                print("profile user details \(result)")
                let userData = result[0] as! [String : Any]
                if self.isSelf{
                    if let firstName = userData["firstName"] as? String {
                        var fullName = firstName
                        if let lastName = userData["lastName"] as? String{
                            fullName = fullName + " " + lastName
                        }
                        UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userFullName)
                    }
                    if let userNumber = userData["number"]  as? String {
                        if let countryCode = userData["countryCode"] as? String {
                            UserDefaults.standard.setValue(userNumber.replace(target: countryCode, withString: ""), forKeyPath: AppConstants.UserDefaults.userNumber)
                            UserDefaults.standard.setValue(countryCode, forKeyPath: "countryCode")
                        }
                     }
                    
                    
                    if let userNameToShow = userData["userName"] as? String {
                        UserDefaults.standard.setValue(userNameToShow, forKeyPath: AppConstants.UserDefaults.userName)
                    }
                    if let isPrivate = userData["private"] as? Int{
                        UserDefaults.standard.set(isPrivate, forKey: AppConstants.UserDefaults.isPrivate)
                    }
                    
                    if let qrCode = userData["qrCode"] as? String {
                        UserDefaults.standard.setValue(qrCode, forKeyPath: AppConstants.UserDefaults.qrCode)
                    }
                   
                    if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                        if let businessCategoryId = businessProfile.first?["businessCategoryId"] as? String{
                            UserDefaults.standard.set(businessCategoryId, forKey: AppConstants.UserDefaults.businessCategoryID)
                        }
                        
                    }
                    
                    if let isbusinessActive = userData["isActiveBusinessProfile"] as? Int{
                        if isbusinessActive == 1 {
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                            if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                                if let businessUniqueId = businessProfile.first?["businessUniqueId"] as? String{
                                    UserDefaults.standard.set(businessUniqueId, forKey: AppConstants.UserDefaults.businessUniqueId)
                                }
                                if let businessProfileImage = businessProfile.first?["businessProfilePic"]{
                                    UserDefaults.standard.set(businessProfileImage, forKey: AppConstants.UserDefaults.userImage)
                                }
                            }else {
                                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                                if let profilePic = userData["profilePic"] as? String {
                                    UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                                    UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)

                                }
                            }
                        }else {
                            if let profilePic = userData["profilePic"] as? String {
                                UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                                UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                            }
                        }
                    }else {
                        if let profilePic = userData["profilePic"] as? String {
                            UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                            UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                        }
                    }
                    
                    if let isBusinessApproved = userData["isBusinessProfileApproved"] as? Int{
                        if isBusinessApproved == 1{
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isBusinessProfileApproved)
                        }else{
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isBusinessProfileApproved)
                        }
                    }
                    if let status = userData["socialStatus"] as? String{
                        UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
                    }
                    
                    if let status = userData["status"] as? String{
                        UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
                    }else {
                        UserDefaults.standard.setValue(AppConstants.defaultStatus, forKeyPath: AppConstants.UserDefaults.userStatus)
                    }
                    
                    if let currency = userData["currency"] as? String{
                                          UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
                                      }
                                      if let currencySymbol = userData["currencySymbol"] as? String{
                                          UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
                                      }
                    
                    if let email = userData["email"] as? String {
                        UserDefaults.standard.setValue(email, forKeyPath: AppConstants.UserDefaults.userEmail)
                    }
                    if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                        
                        UserDefaults.standard.set(businessProfile, forKey: AppConstants.UserDefaults.businessDetails)
                        
                        if let businessUniqueId = businessProfile.first?["businessUniqueId"] as? String{
                            UserDefaults.standard.set(businessUniqueId, forKey: AppConstants.UserDefaults.businessUniqueId)
                        }
                        
                        if let isVerifiedBusinessProfileApproved = businessProfile.first?["statusText"] as? String {
                            if isVerifiedBusinessProfileApproved  == "approved"{
                                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                            }else {
                                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                            }
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        }
                        
                        if let businessEmail = businessProfile.first?["email"]{
                            UserDefaults.standard.set(businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
                        }
                        if let subscriptionDetails = userData["subscriptionDetails"] as? [String:Any] {
                            UserDefaults.standard.set(subscriptionDetails, forKey: AppConstants.UserDefaults.subscriptionDetails)
                        }
                        
                        if let coinValue = userData["coinValue"] as? String {
                            UserDefaults.standard.set(coinValue, forKey: AppConstants.UserDefaults.coinValue)
                        }
                        
                        if let businessPhone = businessProfile.first?["phone"] as? [String:Any] {
                            UserDefaults.standard.set(businessPhone, forKey: AppConstants.UserDefaults.businessMobileNumber)
                        }
                    }
//                    if let balance = userData["RUCBalance"] as? Double {
//                        UserDefaults.standard.set(balance
//                            , forKey: AppConstants.UserDefaults.walletBalance)
//                    }
                    if let isVerifiedStar = userData["isStar"] as? Int {
                        if isVerifiedStar == 1 {
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                        }
                    }
                    if var verifiedProfileDetails = userData["starRequest"] as? [String:Any] {
                        
                        
                        verifiedProfileDetails["description"] = ""
                        UserDefaults.standard.set(verifiedProfileDetails, forKey: AppConstants.UserDefaults.verifyProfileDetails)
                        
                        if let isVerifiedProfileApproved = verifiedProfileDetails["starUserProfileStatusText"] as? String {
                            if isVerifiedProfileApproved  == "approved"{
                                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                            }else {
                                UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                            }
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
                        }
                    }
                    if let businessProfileActive = userData["isActiveBusinessProfile"] as? Int{
                        if businessProfileActive == 1 {
                             UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isActiveBusinessProfile)
                        }
                     }
                    UserDefaults.standard.synchronize()
                }
                self.setProfileUserData(response: result)
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                complitation(false, error, true)
            }
        }
    }
    
    
    /// To set data in user profile model
    ///
    /// - Parameter response: service response to set data in model
    func setProfileUserData(response: [Any]){
        if response.count > 0{
            guard let result = response[0] as? [String : Any] else {return}
            userProfileModel = UserProfileModel(modelData: result)
            print(userProfileModel as Any)
            print(userProfileModel?.starRequest)
        }
    }
    

    /// To get business status response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getBusinessStatus(strUrl: String,status: Bool,businessCategoryid:String, complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        Helper.showPI()
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":token,"lang": Utility.getSelectedLanguegeCode()]
        let params = ["isActiveBusinessProfile": status,
        "businessCategoryId": businessCategoryid] as [String:Any]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName:strUrl, requestType: .patch, parameters: params, headerParams: HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getSocialResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {response in
            print(response)
            Helper.hidePI()
            guard let userData = response["response"] as? [String:Any] else { return }
            Utility.updateDataAfterSwitchingProfile { (success, error) in
                
                let userDefault = UserDefaults.standard
                guard let userID = userData["userId"] else { return }
                userDefault.setValue(userID, forKeyPath: AppConstants.UserDefaults.userID)
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
                
                if let firstName = userData["firstName"] as? String {
                    var fullName = firstName
                    if let lastName = userData["lastName"] as? String{
                        fullName = fullName + lastName
                    }
                    UserDefaults.standard.setValue(fullName, forKeyPath: AppConstants.UserDefaults.userFullName)
                }
                if let userNameToShow = userData["userName"] as? String {
                    UserDefaults.standard.setValue(userNameToShow, forKeyPath: AppConstants.UserDefaults.userNameToShow)
                    UserDefaults.standard.setValue(userNameToShow, forKeyPath: AppConstants.UserDefaults.userName)
                }
                if let isPrivate = userData["private"] as? Int{
                    UserDefaults.standard.set(isPrivate, forKey: AppConstants.UserDefaults.isPrivate)
                }
                if let referralCode = userData["referralCode"] as? String{
                    UserDefaults.standard.set(referralCode, forKey: AppConstants.UserDefaults.referralCode)
                }
                if let status = userData["socialStatus"] as? String{
                    UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
                }
                
                if let status = userData["status"] as? String{
                    UserDefaults.standard.setValue(status, forKeyPath: AppConstants.UserDefaults.userStatus)
                }else {
                    UserDefaults.standard.setValue(AppConstants.defaultStatus, forKeyPath: AppConstants.UserDefaults.userStatus)
                }
                
                if let subscriptionDetails = userData["subscriptionDetails"] as? [String:Any] {
                    UserDefaults.standard.set(subscriptionDetails, forKey: AppConstants.UserDefaults.subscriptionDetails)
                }
                if let coinValue = userData["coinValue"] as? String {
                    UserDefaults.standard.set(coinValue, forKey: AppConstants.UserDefaults.coinValue)
                }

                if let currency = userData["currency"] as? String{
                    UserDefaults.standard.set(currency, forKey: AppConstants.UserDefaults.currency)
                }
                if let currencySymbol = userData["currencySymbol"] as? String{
                    UserDefaults.standard.set(currencySymbol, forKey: AppConstants.UserDefaults.currencySymbol)
                }
                
                if let qrCode = userData["qrCode"] as? String {
                                      UserDefaults.standard.setValue(qrCode, forKeyPath: AppConstants.UserDefaults.qrCode)
                                  }
                if let isbusinessActive = userData["isActiveBussinessProfile"] as? Int{
                    if isbusinessActive == 1 {
                        if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                            if let businessProfileImage = businessProfile.first?["businessProfilePic"]{
                                UserDefaults.standard.set(businessProfileImage, forKey: AppConstants.UserDefaults.userImage)
                            }
                            if let businessUniqueId = businessProfile.first?["businessUniqueId"] as? String{
                                UserDefaults.standard.set(businessUniqueId, forKey: AppConstants.UserDefaults.businessUniqueId)
                            }
                            /*
                             Bug Name:- follow and subscribe button appear in user's own profile
                             Fix Date:- 03/04/21
                             Fixed By:- Nikunj C
                             Description of Fix:- save userid when switch to personal profile
                             */
                            
                            guard let userID = userData["userId"] else { return }
                            userDefault.setValue(userID, forKeyPath: AppConstants.UserDefaults.userID)
                            do{
                                try Locksmith.deleteDataForUserAccount(userAccount: AppConstants.keyChainAccount)
                            }
                            catch{
                                DDLogDebug("error handel it")
                            }
                        }else {
                            if let profilePic = userData["profilePic"] as? String {
                                UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                                UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                            }
                        }
                    }
                }else {
                    //                                    UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                    if let profilePic = userData["profilePic"] as? String {
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImage)
                        UserDefaults.standard.setValue(profilePic, forKeyPath: AppConstants.UserDefaults.userImageForChats)
                    }
                }
                if let userNumber = userData["number"]  as? String {
                    if let countryCode = userData["countryCode"] as? String {
                        UserDefaults.standard.setValue(userNumber.replace(target: countryCode, withString: ""), forKeyPath: AppConstants.UserDefaults.userNumber)
                        UserDefaults.standard.setValue(countryCode, forKeyPath: "countryCode")
                        UserDefaults.standard.setValue(countryCode, forKeyPath: AppConstants.UserDefaults.countryCode)
                    }
                    
                    
                }
                if let businessProfile = userData["businessProfile"] as? [[String:Any]] {
                    if let businessUniqueId = businessProfile.first?["businessUniqueId"] as? String{
                        UserDefaults.standard.set(businessUniqueId, forKey: AppConstants.UserDefaults.businessUniqueId)
                    }
                    if let businessEmail = businessProfile.first?["email"]{
                        UserDefaults.standard.set(businessEmail, forKey: AppConstants.UserDefaults.businessEmail)
                    }
                    
                    if let businessPhone = businessProfile.first?["phone"] as? [String:Any] {
                        UserDefaults.standard.set(businessPhone, forKey: AppConstants.UserDefaults.businessMobileNumber)
                    }
                    
                    if let isVerifiedBusinessProfileApproved = businessProfile.first?["statusText"] as? String {
                        if isVerifiedBusinessProfileApproved  == "approved"{
                            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        }else {
                            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                        }
                    }else {
                        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaults.isVerifiedBusinessProfile)
                    }
                    
                    
                }
                
                if let email = userData["email"] as? String {
                    UserDefaults.standard.setValue(email, forKeyPath: AppConstants.UserDefaults.userEmail)
                }
                
                
                let couchbase = Couchbase.sharedInstance
              
                let indexDocVMObject = IndexDocumentViewModel(couchbase: couchbase)
                guard let indexID = indexDocVMObject.getIndexValue(withUserSignedIn: false) else { return }
                guard let indexData = Couchbase.sharedInstance.getData(fromDocID: indexID) else { return }
                indexDocVMObject.updateIndexDocID(isUserSignedIn: false)
                
                let usersDocVMObject = UsersDocumentViewModel(couchbase: Couchbase.sharedInstance)
                usersDocVMObject.updateUserDoc(data: userData, withLoginType: "1")
                
                indexDocVMObject.updateIndexDocID(isUserSignedIn: true)
                
                let userObj = User.init(modelData: userData)
                UserDefaults.standard.set(userObj.refreshToken, forKey: AppConstants.UserDefaults.refreshToken)
                
                guard let userToken = userData["token"] as? String else {return}
                /*
                 Bug Name:- Show full name in chats instead of username
                 Fix Date:- 12/05/2021
                 Fixed By:- Jayaram G
                 Discription of Fix:- Replaced username with fullname
                 */
                usersDocVMObject.updateUserDoc(withUser: userObj.firstName, lastName: userObj.firstName, userName: userObj.firstName + " " + userObj.lastName, imageUrl: userObj.profilePic, privacy: userObj.isPrivate, loginType: "1", receiverIdentifier: "", docId: userToken, refreshToken: userObj.refreshToken)
                Helper.setDataInNSUser(userObj, key: AppConstants.UserDefaults.LoggedInUser)
                self.creatDocforGroupChat()
                userDefault.synchronize()
                self.getChatInitially()
                Helper.hidePI()
            }
                complitation(true,nil)
                    }
        , onError: { error in
            complitation(false,error as? CustomErrorStruct)
            Helper.hidePI()
        })
    }
    
    
    func getChatInitially() {
        let couchbaseObj = Couchbase.sharedInstance
        let chatsDocVMObject = ChatsDocumentViewModel(couchbase: couchbaseObj)
        guard let chats = chatsDocVMObject.getChats() else { return }
        //get chatList from api call
        if let userID = Utility.getUserid() {
            MQTTChatManager.sharedInstance.subscribeGetChatTopic(withUserID: userID)
            if chats.count==0 {
                ChatAPI().getChats(withPageNo:"0", withCompletion: { response in
                    print(response)
                })
            }
        }
    }
    
     func creatDocforGroupChat(){
         //Creat FirstTime GroupChatsDocument here
         let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.GroupChatsDocument) as? String
         if documentID ==  nil{
             //            let contactDocID = favObj?.couchbase.createDocument(withProperties: ["GroupChatsDocument":["i":"i"]] as [String : Any])
             let contactDocID =   Couchbase.sharedInstance.createDocument(withProperties: ["GroupChatsDocument":["i":"i"]] as [String : Any])
             UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.GroupChatsDocument)
         }
     }
    
    
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getPostDataService(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
//        Helper.showPI()
        self.postOffset = postOffset + 20
        let url = strUrl + "skip=\(postOffset)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setPostModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                self.postOffset = self.postOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getUnLockedPostDataService(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
//        Helper.showPI()
        self.unLockedPostOffSet = unLockedPostOffSet + 20
        let url = strUrl + "?skip=\(unLockedPostOffSet)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setunLockedPostModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                self.unLockedPostOffSet = self.unLockedPostOffSet - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    
    /// To get tag service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getTagDataService(strUrl: String,params:[String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
   //     Helper.showPI()
        self.tagOffset = tagOffset + 20
        let url = strUrl + "&skip=\(tagOffset)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            DispatchQueue.main.async {
                Helper.hidePI()
            }
            if let result = response as? [Any]{
                print(result)
                self.setTagModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                DispatchQueue.main.async {
                    Helper.hidePI()
                }
                print(error.localizedDescription)
                self.tagOffset = self.tagOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    /// To get tag service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getLikeDataService(strUrl: String,params: [String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
      //  Helper.showPI()
        self.likeOffset = likeOffset + 20
        let url = strUrl + "&skip=\(likeOffset)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: params) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setLikeModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                self.likeOffset = self.likeOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    /// To get tag service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getStoryDataService(strUrl: String,params: [String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
    //    Helper.showPI()
        profileApi.getSocialData(withURL: strUrl, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setStoryModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }

    //MARK:- Block user
    func blockUserApicall(complitation: @escaping(Bool, CustomErrorStruct?)->Void){

        guard let reciverid = userProfileModel?.userId else {return}
        let strBlock = (userProfileModel?.isBlocked)!  ? "unblock" : "block"
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.blockPersonAPI
        let params = ["opponentId" : reciverid,
                      "type": strBlock]
        profileApi.postSocialData(with: strURL, params: params) { (response, error) in
            print("response: \(response)")
            if error == nil{
                Helper.hidePI()
                complitation(true , error)
//                Helper.showAlertViewOnWindow("Message", message: "User Blocked Successfully")
                self.userProfileModel?.isBlocked = !(self.userProfileModel?.isBlocked)!
                self.UpdateBlockStatusInDatabase(isBlock: (self.userProfileModel?.isBlocked)!)
            }
            Helper.hidePI()
        }
    }
    
    
    /// To update user block and unblock status in database
    ///
    /// - Parameter isBlock: user is block or unblok
    func UpdateBlockStatusInDatabase(isBlock: Bool){
        guard let reciveID = self.userProfileModel?.userId else{return}
        self.sendBlockOnmqtt(reciveID: reciveID, isBlock: isBlock)
        guard let docId = self.fetchIndividualChatDoc(withReceiverID: reciveID, andSecretID: "") else{return}
        guard var chatData = couchbaseObj.getData(fromDocID: docId) else{return}
        chatData["isUserBlocked"]  = isBlock
        couchbaseObj.updateData(data: chatData, toDocID: docId)
    }
    
    
    /// To send block status to user
    ///
    /// - Parameters:
    ///   - reciveID: user id to send status
    ///   - isBlock: user status
    func  sendBlockOnmqtt(reciveID: String, isBlock: Bool){
        
        guard let userID = Utility.getUserid() else {return}
        let mqttDict:[String:Any] = ["blocked":isBlock,
                                     "initiatorId":userID,
                                     "type": 6  as Any]
        
        let groupChannel = "\(AppConstants.MQTT.userUpdates)\(reciveID)"
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject:mqttDict , options: .prettyPrinted)
            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: groupChannel, retain: false, withDelivering:  .atLeastOnce)
        }catch  {
            print("\(error.localizedDescription)")
        }
    }
    
    /// For getting chat doc on respected to receiver ID and secret ID.
    ///
    /// - Parameters:
    ///   - receiverID: receiver ID provided by the contact.
    ///   - secretID: secret ID related to the contact.
    /// - Returns: this will return the chat doc ID respected to receiver ID and secret ID.
    func fetchIndividualChatDoc(withReceiverID receiverID:String, andSecretID secretID : String) -> String? {
        guard let userID = Utility.getUserid() else { return nil }
        guard let indexID = getIndexValue(withUserSignedIn: true) else { return  nil }
        guard let indexData = couchbaseObj.getData(fromDocID: indexID) else { return  nil }
        guard let userIDArray = indexData["userIDArray"] as? [String] else { return  nil }
        if userIDArray.contains(userID) {
            guard let userDocArray = indexData["userDocIDArray"] as? [String] else { return nil }
            if let index = userIDArray.index(of: userID) {
                let userDocID = userDocArray[index]
                guard let userDocData = couchbaseObj.getData(fromDocID: userDocID) else { return nil  }
                if let chatDocID = userDocData["chatDocument"] as? String {
                    guard let chatData = couchbaseObj.getData(fromDocID: chatDocID) else { return nil  }
                    guard let receiverUIDArray = chatData["receiverUidArray"] as? [String] else { return nil  }
                    guard let scretIDArray = chatData["secretIdArray"] as? [String] else { return  nil }
                    guard let receiverChatDocIdArray = chatData["receiverDocIdArray"] as? [String] else { return nil  }
                    if !scretIDArray.isEmpty { // For searching the chat doc id.
                        for index in 0 ..< receiverUIDArray.count {
                            let reciverIDL = receiverUIDArray[index]
                            if (receiverID == reciverIDL ) {
                                if scretIDArray[index] == secretID {
                                    return receiverChatDocIdArray[index]
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// Used for getting the index DocID. If its there then return the existing one or else create a new one.
    ///
    /// - Returns: String value of index document ID.
    func getIndexValue(withUserSignedIn isUserSignedIn : Bool) -> String? {
        if let indexDocID = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.indexDocID) as? String {
            if indexDocID.count>1 {
                return indexDocID
            } else {
                return self.createIndexDB(withUserSignedIn: isUserSignedIn)
            }
        } else {
            return self.createIndexDB(withUserSignedIn: isUserSignedIn)
        }
    }
    
    
    /// Used for creating Index DB initially
    ///
    /// - Parameter isUserSignedIn: with Adding value for isUserSignedIn
    /// - Returns: Document ID of created index document.
    private func createIndexDB(withUserSignedIn isUserSignedIn : Bool) -> String? {
        let couchbase = Couchbase.sharedInstance
        let userDocVMObj = UsersDocumentViewModel(couchbase: couchbase)
        let indexDocID = CouchbaseManager.createInitialCouchBase(withUserSignedIn: isUserSignedIn)
        UserDefaults.standard.set(indexDocID, forKey: AppConstants.UserDefaults.indexDocID)
        guard let userID = Utility.getUserid() else { return nil }
        userDocVMObj.getUserDocuments(forUserID: userID)
        UserDefaults.standard.synchronize() //why its fetching ? Need to check here.
        return indexDocID
        
    }

    
//    /// To report user
//    ///
//    /// - Parameter finished: after get api response passing data to view controller
//    func reportUserServiceCall(reasonIndex: Int,finished: @escaping(Bool, Error?)-> Void){
//        guard let oppUserID = userProfileModel?.userId else {return}
//        Helper.showPI(_message: "Loading...")
//        let strURL = AppConstants.reportSpamUserAPI
//        let params: [String : Any] = ["targetUserId":oppUserID]
//        profileApi.postSocialData(with: strURL, params: params) { (response, error) in
//            //print("response: \(response!)")
//            if error == nil{
//                finished(true, nil)
//            }else{
//                finished(false, error)
//            }
//            Helper.hidePI()
//        }
//    }
    
    //MARK:- Set data in modes array
    /// To set data in postModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setPostModelData(response: [Any]){
        if self.postOffset == 0 {
            self.postModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let postModel = SocialModel(modelData: modelData)
            self.postModelArray.append(postModel)
        }
    }
    
    //MARK:- Set data in modes array
    /// To set data in unLockedpostModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setunLockedPostModelData(response: [Any]){
        if self.unLockedPostOffSet == 0 {
            self.unLockedPostModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let postModel = SocialModel(modelData: modelData)
            self.unLockedPostModelArray.append(postModel)
        }
    }
    
    
    
    /// To set data in tagModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setTagModelData(response: [Any]){
        if self.tagOffset == 0{
            self.tagModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let postModel = SocialModel(modelData: modelData)
            self.tagModelArray.append(postModel)
        }
    }
    
    /// To set data in tagModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setLikeModelData(response: [Any]){
        if self.likeOffset == 0 {
            self.likeModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let postModel = SocialModel(modelData: modelData)
            self.likeModelArray.append(postModel)
        }
    }
    
    
    
    /// To set data in tagModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setLiveVideosModelData(response: [Any]){
        if self.liveOffset == 0 || self.liveStreamModelArray.count < 20{
            // self.liveOffset = -20
            self.liveStreamModelArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let liveVideo = LiveVideosModel(modelData: modelData)
            self.liveStreamModelArray.append(liveVideo)
        }
    }
    
    
    
    
    
    /// To set data in tagModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setStoryModelData(response: [Any]){
        if self.storyOffset == 0{
            self.storyModelArray.postModelArray.removeAll()
        }

        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let user = userStory.init(storiesDetails:data as! [String : Any])
            self.allStories.append(user)
            let postModel = StoriesModel(modelData: modelData)
            self.storyModelArray = postModel
        }
    }
    
 
    /// To get channel service response
    ///
    /// - Parameters:
    ///   - strUrl: channel string url
    ///   - complitation: complitation handle
    func getChannelDataService(strUrl: String,params:[String:Any], complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
   //    Helper.showPI()
        self.channelOffset = channelOffset + 20
         let url = strUrl + "skip=\(channelOffset)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: params) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setChannelModelData(response: result)
                complitation(true, nil, false)
            }else if let error = error{
                print(error.localizedDescription)
                self.channelOffset = self.channelOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    
   
    /// To get tag service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getLiveVideosDataService(strUrl: String,params: [String:Any]?, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
      //  Helper.showPI()
        self.liveOffset = liveOffset + 20
        let url = strUrl + "&skip=\(liveOffset)&limit=\(livelimit)"
        profileApi.getSocialData(withURL: url, params: params) { (response, error) in
            Helper.hidePI()
            if let result = response as? [Any]{
                print(result)
                
                self.setLiveVideosModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                self.liveOffset = self.liveOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }
    
    
    
    
    /// To set data in channelModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setChannelModelData(response: [Any]){
        if self.channelOffset == 0 || channelModelArray.count > 0 {
            self.channelModelArray.removeAll()
        }
        
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            print(modelData)
            let channelModel = ProfileChannelModel(modelData: modelData)
            self.channelModelArray.append(channelModel)
        }
    }

    func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
        ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
    }
    
    //MARK:- follow and unfollow update database and Service call
    
    /// To update user follow status in database and server
    ///
    /// - Parameters:
    ///   - contact: contact to be updated
    ///   - isFollow: follow or unfollow
    func QrCodeFollowPeopleService(url: String, peopleId: String,complitation: @escaping(Int,Bool,CustomErrorStruct?)->Void){
//        let strURL =    url + "/\(peopleId)"
        let strURL =    url

        let params = ["followingId" : peopleId]
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headers = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode()]
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: strURL, requestType: .post, parameters: params ,headerParams:HTTPHeaders.init(headers), responseType: AppConstants.resposeType.getContactResponse.rawValue)
        apiCall.subject_response.subscribe(onNext: {dict in
            print("output here \(dict)")
            if let dataArray = dict as? [String:Any]{
                if let privateUser = dataArray["isPrivate"] as? Int ,privateUser == 1{
                    complitation(1,true,nil)
                }else{
                    complitation(0,true, nil)
                }
            }else{
                complitation(0,true, nil)
            }
        }, onError: {error in
            Helper.hidePI()
            complitation(0,false, error as? CustomErrorStruct)
        })
    }

    
//    func likeAndUnlikeService(index: Int, isSelected: Bool){
//        let data = self.postModelArray[index]
//        var strUrl: String = AppConstants.like + "/\(data.postId!)"
//        if isSelected{
//            strUrl = AppConstants.unlike + "/\(data.postId!)"
//        }
//        let params = ["userId" : "\(data.userId!)"]
//        ContactAPI.likeAndUnlike(strURL: strUrl, with: params)
//    }
    
    
    //MARK:- Block user
    func unFriendServiceCall(complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        
        guard let reciverid = userProfileModel?.userId else {return}
    
        Helper.showPI(_message: "Loading".localized + "...")
        let strURL = AppConstants.friend + "?" + "targetUserId=\(reciverid)"
        let params = [String : Any]()
        profileApi.deleteSocialData(with: strURL, params: params) { (response, error) in
            if let result = response{
                print(result)
                complitation(true, nil)
            }else if let error = error{
                complitation(false, error)
            }
            Helper.hidePI()
            }
    }
    
    
    func subscribeAndUnSubscribeApiCall(isSubscribe:Bool,userId: String ,complitation: @escaping(Bool, CustomErrorStruct?)->Void){
        var params = ["userIdToFollow":userId]
        var url = AppConstants.starUsersSubscribe
        if !isSubscribe {
            url = AppConstants.starUsersUnSubscribe
            params = ["beneficiaryId":userId,"reason":"Nothing"]
        }
        self.profileApi.postSocialData(with: url, params: params) { (response, error) in
            if response != nil {
                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.trendingUpdate)
                print(response)
                complitation(true,nil)
            }else{
                complitation(false,error)
            }
        }
    }
    
    
    /// To get post service response
    ///
    /// - Parameters:
    ///   - strUrl: posts string url
    ///   - complitation: complitation handle
    func getBookmarksService(strUrl: String, complitation: @escaping(Bool, CustomErrorStruct?, Bool)->Void){
//        Helper.showPI()
        self.bookMarkOffset = bookMarkOffset + 20
        let url = strUrl + "?skip=\(bookMarkOffset)&limit=\(limit)"
        profileApi.getSocialData(withURL: url, params: [:]) { (response, error) in
            if let result = response as? [Any]{
                print(result)
                self.setBookMarkModelData(response: result)
                let canServiceCall: Bool = (result.count == self.limit) ? true : false
                complitation(true, nil, canServiceCall)
            }else if let error = error{
                print(error.localizedDescription)
                self.bookMarkOffset = self.bookMarkOffset - 20
                if error.code == 204{
                    complitation(false, error, false)
                }else{
                    complitation(false, error, true)
                }
            }
        }
    }

    //MARK:- Set data in modes array
    /// To set data in postModelArray of response comming from api
    ///
    /// - Parameter response: response to set data in model
    func setBookMarkModelData(response: [Any]){
        if self.bookMarkOffset == 0 {
            self.bookMarkedArray.removeAll()
        }
        for data in response{
            guard let modelData = data as? [String : Any] else{continue}
            let bookMarkModel = SavedCollectionModel(modelData: modelData)
            self.bookMarkedArray.append(bookMarkModel)
        }
    }
    
}
