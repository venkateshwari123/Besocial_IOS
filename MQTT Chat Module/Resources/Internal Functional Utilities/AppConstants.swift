//
//  AppConstants.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 19/07/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import Foundation
enum AppType :Int{
    case dubly = 2
    case picoadda = 1
}
class AppConstants {
 
    static var appType = AppType.picoadda
    static let baseUrl : String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "Base_Url") as? String else {
            fatalError("Missing key")
        }
        return url
    }()
    
    static let AppName : String = {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "App_Name") as? String else {
            fatalError("Missing key")
        }
        return appName
    }()
    
    static let socketUrl : String = {
        guard let socketUrl = Bundle.main.object(forInfoDictionaryKey: "Socket_Url") as? String else {
            fatalError("Missing key")
        }
        return socketUrl
    }()

    static let pythonURL : String = {
        guard let pythonURL = Bundle.main.object(forInfoDictionaryKey: "Python_Url") as? String else {
            fatalError("Missing key")
        }
        return pythonURL
    }()

    static let constantURL : String = {
        guard let constantURL = Bundle.main.object(forInfoDictionaryKey: "Constant_Url") as? String else {
            fatalError("Missing key")
        }
        return constantURL
    }()
    
    static let streamBaseUrl : String = {
        guard let streamBaseUrl = Bundle.main.object(forInfoDictionaryKey: "StreamBase_Url") as? String else {
            fatalError("Missing key")
        }
        return streamBaseUrl
    }()
    
    static let callUrl : String = {
        guard let callUrl = Bundle.main.object(forInfoDictionaryKey: "Call_Url") as? String else {
            fatalError("Missing key")
        }
        return callUrl
    }()
    
    static let StreamUrl : String = {
        guard let StreamUrl = Bundle.main.object(forInfoDictionaryKey: "Stream_Url") as? String else {
            fatalError("Missing key")
        }
        return StreamUrl
    }()
    
    static let termsConditionUrl : String = {
        guard let termsConditionUrl = Bundle.main.object(forInfoDictionaryKey: "TermsConditionUrl") as? String else {
            fatalError("Missing key")
        }
        return termsConditionUrl
    }()
    
    static let oneSignalAppID : String = {
        guard let oneSignalAppID = Bundle.main.object(forInfoDictionaryKey: "OneSignalAppID") as? String else {
            fatalError("Missing key")
        }
        return oneSignalAppID
    }()
    
    static let starTermsConditions : String = {
        guard let starTermsConditions = Bundle.main.object(forInfoDictionaryKey: "StarTermsConditions") as? String else {
            fatalError("Missing key")
        }
        return starTermsConditions
    }()
    
    
    static let AppUrl : String = {
        guard let appUrl = Bundle.main.object(forInfoDictionaryKey: "AppUrl") as? String else {
            fatalError("Missing key")
        }
        return appUrl
    }()
    
    static let AppMailId : String = {
        guard let appMailId = Bundle.main.object(forInfoDictionaryKey: "AppMailId") as? String else {
            fatalError("Missing key")
        }
        return appMailId
    }()
    
    
    
    static let About : String = {
        guard let about = Bundle.main.object(forInfoDictionaryKey: "About") as? String else {
            fatalError("Missing key")
        }
        return about
    }()
    
    static let PrivacyPolicy: String = {
        guard let privacyPolicy = Bundle.main.object(forInfoDictionaryKey: "PrivacyPolicy") as? String else {
            fatalError("Missing key")
        }
        return privacyPolicy
    }()
 
    static let general : String = {
        guard let general = Bundle.main.object(forInfoDictionaryKey: "General") as? String else {
            fatalError("Missing key")
        }
        return general
    }()
    
    static let helpAndFeedback : String = {
        guard let helpAndFeedback = Bundle.main.object(forInfoDictionaryKey: "General") as? String else {
            fatalError("Missing key")
        }
        return helpAndFeedback
    }()
    
    static let servicesUrl : String = {
        guard let servicesUrl = Bundle.main.object(forInfoDictionaryKey: "ServicesUrl") as? String else {
            fatalError("Missing key")
        }
        return servicesUrl
    }()
    
    static let paymentSecurity : String = {
        guard let paymentSecurity = Bundle.main.object(forInfoDictionaryKey: "PaymentSecurity") as? String else {
            fatalError("Missing key")
        }
        return paymentSecurity
    }()
    
    static let paymentHelpCenter : String = {
        guard let paymentHelpCenter = Bundle.main.object(forInfoDictionaryKey: "PaymentHelpCenter") as? String else {
            fatalError("Missing key")
        }
        return paymentHelpCenter
    }()
    
    
    //APP details
    static let iOSBundleId : String = {
        guard let iOSBundleId = Bundle.main.object(forInfoDictionaryKey: "iOSBundleId") as? String else {
            fatalError("Missing key")
        }
        return iOSBundleId
    }()
    
    static let AndroidPackageName : String = {
        guard let androidPackageName = Bundle.main.object(forInfoDictionaryKey: "AndroidPackageName") as? String else {
            fatalError("Missing key")
        }
        return androidPackageName
    }()
    
    static let DynamicLinkUrlForPost : String = {
        guard let dynamicLinkUrlForPost = Bundle.main.object(forInfoDictionaryKey: "DynamicLinkUrlForPost") as? String else {
            fatalError("Missing key")
        }
        return dynamicLinkUrlForPost
    }()
    
    static let DynamicLinkUrlForProfile : String = {
        guard let dynamicLinkUrlForProfile = Bundle.main.object(forInfoDictionaryKey: "DynamicLinkUrlForProfile") as? String else {
            fatalError("Missing key")
        }
        return dynamicLinkUrlForProfile
    }()
    

     
     struct DeepLinking {
         static let CUSTOM_URL_SCHEME : String = {
            guard let CUSTOM_URL_SCHEME = Bundle.main.object(forInfoDictionaryKey: "CUSTOM_URL_SCHEME") as? String else {
                fatalError("Missing key")
            }
            return CUSTOM_URL_SCHEME
        }()
     }
    
    
    static let StreamNamePrefix     = "stream-"
    static let uploadMultimediaURL =  "https://upload.dubly.xyz/"
    static let uploadImageURLExtension = "https://fetchfile.dubly.xyz/chatDoc"
    static let uploadedVideoExtension =  "https://fetchfile.dubly.xyz/chatDoc"
    static let uploadedAudioExtension =  "https://fetchfile.dubly.xyz/chatDoc"
    static let uploadedDocumetExtension = "\(uploadedAudioExtension)"
    static let videoExtension = "\(uploadedAudioExtension)"
    static let authorization = "KMajNKHPqGt6kXwUbFN3dU46PjThSNTtrEnPZUefdasdfghsaderf1234567890ghfghsdfghjfghjkswdefrtgyhdfghj"
  
    static let permissionMsg = "Please enable the phone contact permissions for".localized + " \(AppConstants.AppName) " + "at the following path".localized + " " + "Settings".localized + " ->" + " \(AppConstants.AppName) " + "-> " + "Enable contact sharing".localized
    static let cameraPermissionMsg = "Please provide Camera permission".localized + ". " + "Goto" + "-> " + "Setting".localized + " ->" + " \(AppConstants.AppName) " + "-> " + "give Camera permission".localized
    static let audioPermissionMsg = "Please provide Audio permission".localized + ". " + "Goto".localized + "-> " + "Setting".localized + " ->" + " \(AppConstants.AppName) " + "-> ".localized + "give Audio permission".localized
    static let googleMapKey = "AIzaSyAhU6vM2GjstMONHAJDP7OukpfdXDrWx7o"
    static let mGoogleLegaceyServerKey = "key=AIzaSyAhU6vM2GjstMONHAJDP7OukpfdXDrWx7o"
    
    
    //Login Apis
    static let loginAPI = "login" //post
    static let guestToken = "guestToken"
    static let verifyEmail = "verifyEmail" //post
    static let isEmailExists = "isExists/emailId"
    static let signup = "signUp" //post
    static let refreshUserToken = "accessToken"
    static let getUsers = "getUsers" //post
    static let uploadPhoto = "upload" //post 
    static let uploadProfilePic = "upload/profile"
    static let uploadChatImage = "upload"
    static let uploadVideos = "upload"
    static let requestOTP = "RequestOTP" //post
    static let isRegisteredNumber = "isRegisteredNumber"
    static let verifysignup = "verifySignUp" //post
    static let newPassword = "newPassword"
    static let requestChangeNumber = "requestChangeNumber" //Post
    static let verifyChangeNumber = "verifyChangeNumber" //Post
    static let verifyOTP = "verifyOtp" //post
    static let profile = "profile" //put
    static let signature = "cloudinarySignature" //Post
    static let getContacts = "contactSync/"  //Post
    static let verifyStarNumber = "verifyStarNumber"
    static let collections = "collections"
    static let collection = "collection"
    static let bookmark = "bookmark"
    static let createCollection = "collection"
    static let editCollection = "collection"
    static let addToCollection = "addToCollection"
    static let deleteCollection = "collection"
    static let bookmarkById = "bookmarkById"
    static let friend = "friend"
    static let isRegisteredEmail = "isExists/emailId"
    static let profileEmailPhoneSend = "profile/emailPhoneSend"
    static let profileEmailPhoneVerify = "profile/emailPhoneVerify"
    static let chooseLanguage = "languages/profile"
    
    // Ice Sever API
    static let iceServer = "iceServers"
    
    //Chats Api
    static let callLogs = "CallLogs"  ///Get
    static let callpush = "iosPush"  //POST
    static let updateStatus = "User/SocialStatus"   //POST
    static let pendingCalls = "calls" //Get
    static let blockPersonAPI = "User/Block" //POST
    static let reportSpamUserAPI = "userReportReasons" //POST
    static let muteNotificationAPI = "inactiveNotification" //POST
    static let getChats = "Chats" //get
    static let getMessages = "Messages" //get
    static let transfer = "Transfer" //Post
    static let transferAction = "ReceiversResponseToTransfer" //Post
    static let cancelTransfer = "cancelTransfer" //Post
    static let messageDetails = "messageDetails" //Get
    
    //stories API
    static let story = "story" //"story"
    static let myStory = "myStory"
    static let postStory = "story"
    static let storyViewersList = "story/viewList"
    
    //Star Request Api
    static let starRequest = "StarRequest"
    static let starCategory = "starCategories"
    
    // star Configuration
    static let requestEmailVerification = "requestEmailVerification"
    static let requestMobileVerification = "RequestOTP"
    static let verifyOTPByEmail = "verifyOTPByEmail"
    static let bussinessPhoneVerification = "businessPhoneVerification"
    static let bussinessEmailVerification = "businessEmailVerification"
    static let bussinessPhoneOptVerify = "businessPhoneOtpVerify"
    static let bussinessEmailOptVerify = "businessEmailOtpVerify"
    static let follow = "follow" //post
    static let unfollow = "unfollow" //post
    static let followAll = "follow/all" //post
    static let like = "like"//POST
    static let unlike = "unlike" //POST
    static let comment = "comment" //GET
    
    
    //Post Details
    static let post = "post" //GET
    
    //Social API
    static let home = "home" //GET
    static let guestUserAPI = "guestPosts/" //get
    static let services = "services"
    static let popularUser = "popularUser/" //get
    
    static let postedByHashTag = "postsByHashTag" //GET
    static let postedByChannel = "postsByChannel" //GET
    static let postsByCategory = "postsByCategory" //GET
    static let trendingPosts = "trendingPosts/" //GET
    static let postsByMusic = "postsByMusic" //GET
    static let postsByPlace = "postsByPlace" //GET
    static let favouriteMusic = "favouriteMusic" //GET && POST
    static let postsByHashtags = "postsByHashtags/" // python
    
    
    
    static let subscribeChannel = "subscribeChannel" //PUT
    static let unSubscribeChannel = "unSubscribeChannel" //PUT
    
    //Search API
    static let searchPeople = "search/people" //GET
    static let hashTagList = "hashTagList" //GET
    static let channelList = "channelList" //GET
    static let starUsers = "starUsers"
    
    //Trending API(Python API)
    static let getCategory = "categories/" //GET
    static let trending = "trendingHashTags/" //POST
    static let getTrendingUsers = "getTrendingUsers/"
    static let getXclusivePosts = "xclusivePosts/"
    static let getTrendingPosts = "trendingPosts/"

    
    //Profile API
    static let userProfile = "profile/users" //GET
    static let profilePost = "profile/posts" //GET
    static let profileTag = "profile/users/mention" //GET
    static let MyLikedPost = "MyLikedPost" //GET
    static let storyHistory = "storyHistory"
    static let memberProfile = "profile/member" //GET
    static let memberPost = "profile/memberPosts" //GET
    static let profileChannels = "profile/channel" //GET
    static let channels = "profile/channels" //GET
    static let reportReasons = "reportReasons" //GET & POST
    
    //Categorys
    static let category = "category" //GET
    static let giftCategories = "giftCategories" /// GET
    
    //Channel
    static let channel = "channel" //GET && POST
    static let channelEdit = "channel"
    static let block = "blocks" //GET
    static let unblock = "unblock" //POST
    static let getFollowers = "follow/followers" //GET
    static let getFollowees = "follow/followees"//GET
    static let searchFollowees = "followees"
    static let searchFollowers = "followers"
    static let getPostViews = "postViews" //GET
    static let getLikedUserList = "likedUserList" //GET
    static let starStatus = "starStatus"
    static let walletTransaction = "WalletStatement" // GET
    static let qrCode = "qrCode"
    
    // For Friend flow in chat
    // static let followersFollowee = "friend" //GET
    
    static let cognitoToken = "cognitoToken"
    
    // For Followers flow in chat
    static let followersFollowee = "followersFollowee" //GET
    
    //Following API
    static let followingActivity = "followingAcitivty" //GET
    static let activity = "activity" //GET
    static let followRequest = "followRequest" //GET & POST
    static let RequestedChannels = "RequestedChannels" //GET & POST
    static let friendRequest = "friendRequest"
    
    static let friendRequestResponse = "friendRequestResponce"
    
    //inviteContacts POST Api
    static let inviteContacts = "contactSync/"
    
    //Wallet APIS
    static let walletBalance = "WalletBalance"
    
    
    //Subscription
    static let subscription = "subscription"
    static let subscribersList = "starUsers/subscribe"
    
    //Wallet userdetails API
    static let userDetail = "userDetail"
    static var transctionUrl = "walletTransaction"
    static var walletBlance = "wallet"
    static var paymetGetway = "paymentGateways"
    static var qrScanner = "follow"
    static var matchPassword = "isPasswordMatch"
    static var transferMoney =  "user/transfer"  // "walletTransaction/transfer"
    static var transferValidate = "transfer/validate"
    static let verificationStatus = "verificationStatus"
    static let userTransferDetail = "user/transfer/detail"
    
    static let walletCheck = "wallet/check"
    //document list API
    static let documentList = "documentList"
    
    //withdraw api
    
    static let withdraw = "withdraw"
    static let withdrawMoney = "withdraw/money"
    
    //bank api
     static let bankField = "bankFields"
    static let bank = "bank"
    
    // Buy Post
    static let buyPost = "buyPost"
    static let coinAmount = "coinAmount"
    static let tipAmount = "tipAmount"
    static let coinTransfer = "coinTransfer"
    static let buyCoins = "buyCoins"
    static let purchaseCoins = "purchaseCoins"
    static let coinPlans = "coinPlans"
    
    //Subscribe
    static let starUsersSubscribe = "starUsers/subscribe"
    static let starUsersUnSubscribe = "starUsers/unSubscribe"
    static let starUserssubscriberList = "starUsers/subscriberList"
    
    //passoword API
    static let appPassword = "isPasswordMatch"
    
    // Business Apis
    static let businessCategory = "businessCategories"
    static let businessRequest = "BusinessRequest"
    static let bussinessProfile = "businessProfile"  // GET
    static let business = "business"
    static let businessProductType = "businessProductType"
    static let bizButtons = "bizButtons"
    static let businessPhoneEmailValidate1 = "Business/emailPhoneVerification"
    static let businessPhoneEmailValidate = "business/emailPhoneExists"
    static let businessEmailPhoneSend = "business/emailPhoneSend" // POST
    static let businessEmailPhoneVerify = "business/emailPhoneVerify" //POST
    static let isExistUserName = "isExists/userName"
    
    //GroupChat API
    static let creatgroupChat  = "GroupChat" //POST
    static let addMemberToGroupChat = "GroupChat/Member" //POST
    static let makeAdminOfGropChat = "GroupChat/Member" //PUT
    static let leaveGroupChat = "GroupChat/Member" //DELETE
    static let getAllmembersofGroup = "GroupChat/Member" //GET
    static let removeFromGroup  = "GroupChat/Member" //DELETE
    static let removeFromGroupByMember  = "GroupChat/ByMember" //DELETE
    static let deleteGroup = "GroupChat" //DELETE
    static let GroupMessageStatus = "GroupChat" //GET
    
    //Logout
    static let logout = "logout" //POST
    static let deleteAccount = "profile/users" //DELETE
    
    //Live stream
    static let stream                    = "stream"
    static let giftTransfer              = "giftTransfer"
    static let PostStartStream           = "stream"
    static let PostcommentStream         = "stream/chat"
    static let getCommentsHistory        = "stream/chat"
    static let GetStreamData             = "stream/live"
    static let PostSubStream             = "stream/subscribe"
    static let GetStreamStats            = "streams/stats"
    static let EndStream                 = "endStream"
    static let getSubscribers            = "stream/subscribers"
    static let GetGifts                  = "giftsWithCategories"
    static let postGifts                 = "stream/likeOrGift/" //streamid
    static let streamHistory             = "streamHistory"
    static let gifts                     = "gifts"
    static let endStream                 = "endStream"
    
    static let starUserChat = "starUserChat"
    static let businessChat = "businessChat"

  
    static let googleUrl = "https://www.google.com/"
    
    static let keyChainAccount : String = {
        guard let keyChainAccount = Bundle.main.object(forInfoDictionaryKey: "keyChainAccount") as? String else {
            fatalError("Missing key")
        }
        return keyChainAccount
    }()
    

    static let currency = "currency"
    
    
    struct CouchbaseConstant {
        static let dbName = "mqttchatdb"
    }
    
    struct BasicAuth {
        static let userName = "3embed"
        static let passWord = "007$"
    }
    
  
    
    struct  UserDefaults {
        static let isDarkModeEnable = "isDarkModeEnable"
        static let isGuestLogin = "isGuestLogin"
        static let token = "token"
        static let randomScore = "randomScore"
        static let LoggedInUser = "LoggedInUser"
        static let currentLang = "currentLang"
        static let userID = "userID"
        static let isUserBlockStatusChanged = "isUserBlockStatusChanged"
        static let refreshToken = "refreshToken"
        static let likeUpdate = "likeUpdate"
        static let profileUpdate = "profileUpdate"
        static let postUpdate = "postUpdate"
        static let trendingUpdate = "trendingUpdate"
        static let walletUpdate = "walletUpdate"
        static let businessUniqueId = "businessUniqueId"
        static let bookMarkUpdate = "bookMarkUpdate"
        static let userImageData = "userImageData"
        static let channelUpdate = "channelUpdate"
        static let isFromTabProfile = "isFromTabProfile"
        static let indexDocID = "indexDocID"
        static let userName = "userName"
        static let guestToken = "guestToken"
        static let postsViewersDocId = "postsViewersDocId"
        static let currencycountryCodeName = "countryCodeName"
        static let userImageForChats = "userImageForChats"
        static let userFullName = "userFullName"
        static let userEmail = "userEmail"
        static let isProfileSet = "isProfileset"
        static let userNameToShow = "userNameToShow"
        static let isPrivate = "isPrivate"
        static let userImage = "userImage"
        static let countryCode = "countryCode"
        static let coverImage = "coverImage"
        static let sessionToken = "token"
        static let qrCode = "qrCode"
        static let pushToken = "pushToken"
        static let callPushToken = "callpushToken"
        static let rechabilityNotificationKey = "rechabilityNotification"
        static let userNumber = "userNumber"
        static let userStatus = "userStatus"
        static let colourKey = "colourKeys"
        static let statusArr = "statusarray"
        static let receiverIdentifier = "receiverIdentifier"
        static let isUserOnchatscreen = "userIsnoChatscreen"
        static let contactDocumentID = "contactDocumentID"
        static let followDocumentId = "followDocumentId"
        static let CallHistryDocumentID = "CallHistryDocumentID"
        static let GroupChatsDocument = "GroupChatsDocument"
        static let locationDocumentId = "locationDocumentId"
        static let categoryId = "categoryID"
        static let categoryName = "categoryName"
        static let referralCode = "referralCode"
        static let isFromFindFriendsAction = "isFromFindFriendsAction"
        static let walletBalance = "walletBalance"
        static let userIdProofImageUrl = "userIdProofImageUrl"
        static let isVerifiedUserProfile = "isVerifiedUserProfile"
        static let isVerifiedBusinessProfile = "isVerifiedBusinessProfile"
        static let isActiveBusinessProfile = "isActiveBusinessProfile"
        static let isBusinessProfileApproved = "isBusinessProfileApproved"
        static let starknownAs = "starknownAs"
        static let starEmail = "starEmail"
        static let starMobileNumber = "starMobileNumber"
        static let businessMobileNumber = "businessMobileNumber"
        static let businessEmail = "businessEmail"
        static let selectedCategoryRowIndex = "categoryRow"
        static let selectedBusinessCategoryRowIndex = "selectedBusinessCategoryRowIndex"
        static let managingProfileViewBackAction = "managingProfileViewBackAction"
        static let verifyProfileDetails = "verifyProfileDetails"
        static let currency = "currency"
        static let walletCurrecnySymbol = "WalletCurrencySymbol"
        static let walletCurrency = "WalletCurrency"
        static let currencySymbol = "currencySymbol"
        static let subscriptionDetails = "subscriptionDetails"
        static let coinValue = "coinValue"
        static let isWalletVerified = "isWalletVerified"

        //permission user defaults
        static let isAppRequestedVideo = "isAppRequestedVideo"
        static let isAppRequestedAudio = "isAppRequestedAudio"
        static let isAppRequestedGallery = "isAppRequestedGallery"
        
        static let streetAddress = "streetAddress"
        static let placeAddress = "placeAddress"
        static let zipCode = "zipCode"
        static let businessDetails = "businessDetails"
        static let businessCategoryID = "businessCategoryID"
        
        static let streamID = "streamID"
        static let activeStreamId = "activeStreamId"
        static let streamThumbnailImage = "streamThumbnailImage"
        static let streamName = "streamName"
        
        static let fcmToken = "fcmToken"
        static let iceServers = "IceServers"
        static let iceServerUserName = "iceServerUserName"
        static let iceServerCreds = "iceServerCreds"
        static let isTokenRefreshed = "isTokenRefreshed"
        static let oneSignalId = "oneSignalId"
    }
    
    enum notificationCenterName: String {
        case streamNow = "streamNow"
        case subscribeStream = "subscribeStream"
        case streamChat = "streamChat"
        case streamGift = "streamGift"
        case streamLike = "streamLike"
    }
    
    struct indexDocumentConstants {
        static let userIDArray = "userIDArray"
        static let userDocIDArray = "userDocIDArray"
        static let chatDocument = "chatDocument"
    }
    
    struct MQTT {
        static let messagesTopicName = "Message/"
        static let acknowledgementTopicName = "Acknowledgement/"
        static let onlineStatus = "OnlineStatus/"
        static let typing = "Typ/"
        static let contactSync = "ContactSync/"
        static let userUpdates = "UserUpdate/"
        static let callsAvailability = "CallsAvailability/"
        static let calls  = "Calls/"
        static let getChats = "GetChats/"
        static let getMessages = "GetMessages/"
        static let groupChats = "GroupChats/"
        static let groupChat = "GroupChat/"
        ///Streaming tomics
        static let subscribe = "stream-subscribe/"
        static let like = "stream-like/"
        static let gift = "stream-gift/"
        static let chat = "stream-chat/"
        static let streamNow = "stream-now/"
        static let lastWill = "last-will"
    }
    
  
    struct segueIdentifiers {
        static let chatController = "segueToChatViewController"
        static let followSegue = "followSegue"
        static let settingSegue = "settingSegue"
        static let editNumberVarificationSegue = "editNumberVarificationSegue"
        
    }
    
    struct CallTypes {
        static let audioCall = "0"
        static let videoCall = "1"
    }
    
    static let resposeTypeKey = "resposeType"
    
    public enum resposeType:String {
        case  callHistoryResponse = "callHistory"
        case  requestOtp  = "requestOTP"
        case  refreshToken = "accessToken"
        case  verifyOTP = "VerifyOTP"
        case requestChangeNumber = "requestChangeNumber"
        case verifyChangeNumber = "verifyChangeNumber"
        case profileResponse = "Profile"
        case getContactResponse = "GetContects"
        case getChats  = "Chats"
        case iosPush = "iosPush"
        case callLogs = "callLogs"
        case loginApi = "login"
        case verifyEmail = "veryEmail"
        case statusResponse = "statusresponse"
        case pendingCalls = "pendingCalls"
        case endStream = "endStream"
        case creatGroupAPI = "creatGroupApi"
        case removeFromGroupAPI = "removeFromGroup"
        case makeAnAdminAPI = "makeAnAdmin"
        case leaveGroupAPI = "LeaveGroup"
        case changeGPpicAPI = "changeGroupPic"
        case addGroupmemberAPI = "addgroupMem"
        case blockUser = "blockUser"
        case getAllgpMembers = "getAllgpMembers"
        case deleteMessage = "deleteAllMessage"
        case groupMessageStatus = "groupMessageStatus"
        case reportUser = "spamUser"
        case muteNotification = "muteNotification"
        case getSocialResponse = "getSocialResponse"
        case postTrendingResponse = "postTrendingResponse"
        case getTrendingResponse = "getTrendingResponse"
        case walletCheck = "WalletCheck"
        case coinWallet = "CoinWallet"
    }
    
    static let refreshHistoryNotification = "refreshCallHistory"
    static let defaultStatus = "Hey".localized + "! " + "I'm using".localized + " \(AppConstants.AppName)"
    static let removeFromadmin = "non_admin"
    static let makeAdmin = "admin"
    static let noInternetMsg = "The Internet connection appears to be offline."
    
    enum groupType:Int {
        case creatGroup
        case addInGroup
        case removeFromGroup
        case makeGroupadmin
        case groupNameChange
        case groupImagechange
        case leaveGroup
    }
    
    enum iphoneX:CGFloat{
        case height = 812
        case width = 375
    }

    
    //MARK:- StotyBoard Ids
    struct StoryBoardIds {
        static let Services = "Services"
        static let Main = "Main"
        static let instaHome = "InstaHome"
        static let Settings = "Settings"
        static let Activity = "Activity"
        static let postedBy = "PostedBy"
        static let chat = "Chat"
        static let live = "Live"
        static let Profile = "Profile"
        static let Trending = "TrendingFlow"
        static let WalletKyc = "WalletKyc"
        static let qrCode = "QrCode"
        static let CountryPicker = "CountryPicker"
        static let CreatePost = "CreatePost"
        static let Contacts = "Contacts"
        static let ShareToSocial = "ShareSocialMedia"
    }
    
    //MARK:- View Controller Ids
    struct viewControllerIds {
        // services  story board Vcs
        static let LoginVC = "LoginViewControllerId"
        static let SignUpVC = "SignUpViewControllerId"
        static let TabBarVC = "tabBarController"
        static let newFriendsViewControllerVcId = "NewFriendsViewControllerVcId"
        static let AcceptOrRejectFriendRequestControllerVcId = "AcceptOrRejectFriendRequestControllerVcId"
        static let businessBioViewControllerVcId = "businessBioViewControllerVcId"

        static let FriendRequestVC = "FriendRequestViewController"
        static let newEditProfileVewController = "newEditProfileVewController"
        static let UpdateEmailPhoneViewController = "updateEmailPhoneViewController"
        static let ForgotPasswordVC = "ForgotPasswordViewController"
        static let PostDetailsViewController = "PostDetailsViewController"
        static let NewAddContactsViewControllerVcId = "NewAddContactsViewControllerVcId"
        static let VerifyOTPVC = "VerifyOTPViewController"
        static let CategoryListViewController = "CategoryListViewController"
        static let toUserProfileSegue = "toUserProfileSegue"
        static let postedByController = "PostedByViewController"
        static let ExploreStarPagesViewControllerVcId = "ExploreStarPagesViewControllerVcId"
        static let changeCurrencyVcId = "ChangeCurrencyVcId"
        static let TopStarsViewControllerVcId = "TopStarsViewControllerVcId"
        static let withdrawVcId = "WithDrawVcId"
        static let walletVcId = "WalletVcId"
        static let citySmartServiceVcId = "CitySmartServicesVcId"
        static let settingVcId = "SettingsVcId"
        static let aboutVcId = "AboutVcId"
        static let referralVcId = "ReferralCodeViewControllerId"
        static let profileViewControllerId = "ProfileViewController"
        static let moneyVcId = "MoneyVcId"
        static let addMoneyVcId = "AddMoneyVcId"
        static let cardsVcId = "CardsVcId"
        static let transactionVcId = "TransactionVcId"
        static let addMoneyOptionsVcId = "AddMoneyOptionsVcId"
        static let businessMobileConfigurationViewControllerId =   "BusinessMobileConfigurationViewControllerId"
        static let businessEmailConfigurationViewControllerId = "BusinessEmailConfigurationViewControllerId"
        static let businessVerificationViewControllerId = "BusinessVerificationViewControllerId"
        static let qrScannerViewControllerVcId = "QrScannerViewControllerVcId"
        static let businessContactInfoViewControllerId = "BusinessContactInfoViewControllerId"
        static let businessCategoryViewControllerId = "BusinessCategoryViewControllerId"
        static let businessAddressViewControllerId = "BusinessAddressViewControllerId"
        static let SettingsVcId = "SettingsVcId"
        static let emailConfigurationViewControllerId = "EmailConfigurationViewControllerId"
        static let mobileConfigurationViewControllerId = "MobileConfigurationViewControllerId"
        static let verificationViewControllerId = "VerificationViewControllerId"
        static let verifyUserMobileConfigurationViewControllerId = "VerifyUserMobileConfigurationViewControllerId"
        static let verifyUserEmailViewControllerId = "verifyUserEmailViewControllerId"
        static let requestStarCategoryViewControllerId = "RequestStarCategoryViewControllerId"
        static let searchLocationViewControllerId = "SearchLocationViewController"
        static let DiscoverPeopleStoryboard = "DiscoverPeopleStoryboard"
        static let SavedCollectionsViewController = "SavedCollectionsViewController"
        static let DocumentViewerViewController = "DocumentViewerViewController"
        static let BeforeSignUpNavigationController = "BeforeSignUpNavigationController"
        static let RequestStarProfileViewController = "RequestStarProfileViewControllerId"
        static let helpCentreId = "AboutVcId"
        static let starConfigurationViewControllerId = "StarConfigurationViewControllerId"
        static let inviteContactsViewControllerId = "InviteContactsViewControllerId"
        static let contactsVcId = "favouritViewController"
        static let createBusinessProfileVcId = "CreateBusinessProfileVcId"
        static let businessConfigurationCellId = "BusinessConfigurationCellId"
        static let businessConfigurationVcId = "BusinessConfigurationViewControllerId"
        static let favouritViewController = "favouritViewController"
        static let CreateChannelViewController = "CreateChannelViewController"
        static let VideoPreviewViewController = "VideoPreviewViewController"
        static let customOptionsAlertViewControllerId = "CustomOptionsAlertViewControllerId"
        static let SocialViewControllerId = "SocialViewController"
        static let FollowListViewController = "FollowListViewController"
        static let CreatnewGroupViewController = "CreatnewGroupViewController"
        
        
        /*
         Bug Name:- Crashing on location page
         Fix Date:- 08/06/21
         Fix By  :- Jayaram G
         Description of Fix:- Changed viewcontroller ID
         */
        static let postLocationViewController = "PostsLocationViewController"
        static let PostedByViewController = "postedByController"
        static let businessEditContactOptionsVcId = "BusinessEditContactOptionsVcId"
        static let businessPhoneNumberEditViewControllerId = "BusinessPhoneNumberEditViewControllerId"
        static let editProfileVewController = "editProfileVewController"
        static let settingsVcId = "SettingsVcId"
        static let transactionVc = "TransactionVcId"
        static let qrCodeVc = "QrCodeViewControllerVcId"
        static let SwitchToBusinessVcId = "SwitchToBusinessAccountVcId"
        static let updateStatusListViewController = "updateStatusListViewController"
        static let editNumberStoryboardId = "editNumberStoryboardId"
        static let updateEmailVc = "UpdateEmailViewController"
        static let UpdateStatusViewController = "UpdateStatusViewController"
        static let businessBioViewContrllerVcId = "businessBioViewControllerVcId"
        static let addLinkViewControllerVcId = "AddLinkViewControllerVcId"
        static let addPriceViewControllerVcId = "AddPriceViewControllerVcId"
        static let businessButtonTextViewControllerVcId = "BusinessButtonTextViewControllerVcId"
        static let currencyViewControllerVcId = "CurrencyViewControllerVcId"
        static let businessProductTypeListViewControllerVcId = "BusinessProductTypeListViewControllerVcId"
        static let TransferInfoViewController = "TransferInfoViewController"
        static let ChatViewController = "ChatViewController"
        static let DetailsTrendingViewControllerVcId = "DetailsTrendingViewControllerVcId"
        static let EntertainmentPostsViewControllerVcId = "EntertainmentPostsViewControllerVcId"
        static let ProfileChannelsViewController = "ProfileChannelsViewController"

        
        //live streaming
        static let StreamHistoryVideosControllerVcId = "StreamHistoryVideosControllerVcId"
        static let OnGoingStreamVC = "OnGoingStreamVC"
        
        //Stories
        static let StoryListViewController = "StoryListViewController"
        static let SubscriptionVC = "SubscriptionVC"
        
        //CoinWallet
        static let CoinWallet = "CoinWallet"
        static let CoinTransaction = "CoinTransactionVC"
        
    }
    
    //MARK:- Cell Ids
    struct CellIds{
        static let categoryCollectionCell = "categoryCollectionCell"
        static let StatusTextTableViewCell = "StatusTextTableViewCell"
        static let trendingCollectionViewCellId = "TrendingCollectionViewCellId"
        static let cellId  = "ServiceCell"
        static let BusinessContactInfoAddressTextviewCellId = "BusinessContactInfoAddressTextviewCellId"
        static let changeCurrencyCellId = "ChangeCurrencyCellId"
        static let walletCellId = "WalletCellId"
        static let addMoneyCardCellId = "AddMoneyCardCellId"
        static let addMoneyOptionsCellId = "AddMoneyOptionsCellId"
        static let addOptionsFooterCellId = "AddOptionsFooterCellId"
        static let withDrawMoneyCellId = "WithDrawMoneyCellId"
        static let proceedButtonCellId = "ProceedButtonCellId"
        static let citySmartServiceCellId = "CitySmartCellId"
        static let BusinessConfigurationCellId = "BusinessConfigurationCellId"
        static let createBusinessCellId = "CreateBusinessCollectionViewCellId"
        static let businessContactInfoTextCellId = "BusinessContactInfoTextCellId"
        static let businessContactInfoHeaderCellId = "BusinessContactInfoHeaderCellId"
        static let businessContactInfoDetailsTextCellId = "BusinessContactInfoDetailsTextCellId"
        static let businessContactInfoPrivateAccountCellId = "BusinessContactInfoPrivateAccountCellId"
        static let starConfigurationCellId = "StarConfigurationCellId"
        static let FriendRequestCellTableViewCellId = "FriendRequestCellTableViewCellId"
        static let invisibleChatCelllId = "InvisibleChatCelllId"
        static let requestStarProfileTextCellId = "RequestStarProfileTextCellId"
        static let requestStarProfileCategoryCellId = "RequestStarProfileCategoryCellId"
        static let requestStarProfileFooterViewCellId = "RequestStarProfileFooterViewCellId"
        static let requestStarProfileChooseFileViewCellId = "RequestStarProfileChooseFileViewCellId"
        static let businessAddressCellId = "BusinessAddressCellId"
        static let businessAddressTextViewCellId = "BusinessAddressTextViewCellId"
        static let placesCellId = "PlacesCellId"
        static let requestCategoryTypesCellId = "RequestCategoryTypesCellId"
        static let categoryRequestCellId = "CategoryRequestCellId"
        static let BlockedUserTableViewCell = "BlockedUserTableViewCell"
        static let SettingVersionTableViewCell = "SettingVersionTableViewCell"
        static let SettingsTitleViewCellId = "SettingsTitleViewCellId"
        static let settingAppModeTableViewCell = "SettingAppModeTableViewCell"
        static let SettingsHeaderViewCellId = "SettingHeaderViewCellId"
        static let businessEditContactOptionsCell = "BusinessEditContactOptionsCell"
        static let userProfileTableViewCell = "userProfileTableViewCell"
        static let profileHeaderTableViewCell = "profileHeaderTableViewCell"
        static let UserProfileHeaderTableViewCell = "UserProfileHeaderTableViewCell"
        static let EditProfileSwitchToBusinessAccountCell = "EditProfileSwitchToBusinessAccountCell"
        static let EditProfileTextTableViewCell = "EditProfileTextTableViewCell"
        static let EditProfileImageTableViewCell = "EditProfileImageTableViewCell"
        static let EditProfileStatusTableViewCell = "EditProfileStatusTableViewCell"
        static let EditProfileHeaderTableViewCell = "EditProfileHeaderTableViewCell"
        static let EditPrivateAccountCellId = "EditPrivateAccountCellId"
        static let EditProfileBusinessProfileInfoTableViewCellId = "EditProfileBusinessProfileInfoTableViewCellId"
        static let followTableViewCell = "followTableViewCell"
        static let profileViewController = "ProfileViewController"
        static let CategoryListTableViewCell = "CategoryListTableViewCell"
        static let SwitchToBusinessTitleCellId = "SwitchToBusinessTitleCellId"
        static let SwitchToBusinessHeaderViewCellId = "SwitchToBusinessHeaderViewCell"
        static let SwitchToBusinessTextViewCellId = "SwitchToBusinessTextViewCell"
        static let SwitchToBusinessDescriptionCellId = "SwitchToBusinessDescriptionCell"
        static let countryPickerController = "countryPickerController"
        static let businessAddressEditViewCellId = "BusinessAddressEditViewCellId"
        static let businessContactTextViewCellId = "BusinessContactTextViewCellId"
        static let mainCollectionViewCellId = "MainCollectionViewCellId"
        static let treadingCollectionCell = "treadingCollectionCell"
        static let businessPostingTableViewCellId = "BusinessPostingTableViewCellId"
        static let businessButtonTextCellId = "BusinessButtonTextCellId"
        static let currencyListCellTableViewCellId = "CurrencyListCellTableViewCellId"
        static let businessProductTypeListCellId = "BusinessProductTypeListCellId"
        static let editBusinessBioTextCellId = "EditBusinessBioTextCellId"
        static let StarUsersCellId = "StarUsersCellId"
        static let TopStarsCellId = "TopStarsCellId"
        static let ChatStoriesCollectionViewCellId = "ChatStoriesCollectionViewCellId"
        static let ChatStoryListsCollectionViewCell = "ChatStoryListsCollectionViewCell"
        static let ExploreStarPagesCellId = "ExploreStarPagesCellId"
    }
    
    struct notificationObserverKeys {
        static let refreshHomeScreen = "RefreshHomeScreen"
        static let refreshProfileData = "RefreshProfileData"
        static let refreshUserDetails = "RefreshUserDetails"
        static let updatingBlockedUsers   = "updatingBlockedUsers"
        static let refreshLikedPosts = "RefreshLikedPosts"
    }
    
    // ErrorMessages
    struct ErrorMessages {
        static let MsgErrPhoneNumber = "Enter valid phone number"
        static let MsgErrName = "Please enter your name"
        static let MsgErrFirstName = "Please enter your first name"
        static let MsgErrLastName = "Please enter your last name"
        static let MsgErrUserName = "Please enter username"
        static let MsgErrEmail = "Please enter email"
        static let MsgErrValidEmail = "Please enter valid email"
        static let MsgErrExistEmail = "Email address is already exists"
        static let MsgErrExistNumber = "Phone number is already exists"
        static let MsgErrPassword = "Please enter password"
        static let MsgErrConfirmPassword = "Please confirm your password"
        static let MsgErrPasswordDonotMatch = "Password and Confirm password does not match"
        static let MsgErrRefCode = "Please enter referal code"
        static let MsgErrStarChatId = "Please enter \(AppConstants.AppName)ID"
        static let MsgErrTermsAndConditions = "Please accept terms and conditions"
    }
    
    
    struct PlaceHolders {
        static let MsgPhoneNumber = "Enter Phone Number"
        static let MsgLoginViaId = "Login via \(AppConstants.AppName)ID"
        static let MsgPassword = "Enter Password"
        static let MsgLoginViaOTP = "Login via OTP"
        static let MsgLoginViaPswd = "Login via Password"
        static let MsgVerificationCode = "Enter Verification Code"
        static let MsgStarChatId = "\(AppConstants.AppName) ID/UserName"
        static let MsgLoginViaMobile = "Login via Phone Number"
    }
    
    struct Labels {
        static let lblPhone = "Phone"
        static let lblPassword = "Password"
        static let lblSmsCode = "SMS Code"
        static let lblAccount = "Account"
    }
    
    
    struct MapsConstant {
        static let googleMaps = "Open in Google Maps"
        static let maps = "Open in Maps"
    }
}
