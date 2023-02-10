//
//  APIEndTails.swift
//  Yelo
//
//  Created by 3Embed on 09/08/19.
//  Copyright © 2019 rahulSharma. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import CocoaLumberjack
import Alamofire




class APIEndTails {
    
    fileprivate static var obj : APIEndTails!
    private init(){
    }
    public static func getInstance()-> APIEndTails{
        if obj == nil{
            obj = APIEndTails()
        }
        return obj
    }
    private static let BaseURL             = AppConstants.constantURL
    private static let walletBaseURL             = AppConstants.constantURL
    // login signup
    let Login                              = BaseURL + "login"                    // Post type
    let GuestLogin                         = BaseURL + "guestLogin"               // Post type
    let SignUP                             = BaseURL + "signUp"                   // Post type
    let ValidateEmail                      = BaseURL + "validateEmail"            // Post type
    let ValidatePhoneNumber                = BaseURL + "validatePhoneNumber"      // Post type
    let UserName                           = BaseURL + "userName"                 // Post type
    let ValidateVerificationCode           = BaseURL + "validateVerificationCode" // Post type
    let SendVerificationCode               = BaseURL + "sendVerificationCode"
    let ResendVerificationCode             = BaseURL + "resendVerificationCode"   // Post type
    let RecoverPassword                    = BaseURL + "forgotPassword"           // Post type
    let RecoverUsername                    = BaseURL + "forgotUsername"           // Post type
    
    // post
    let AssetType                          = BaseURL + "assetType"                // Get Type
    let SubAssetType                       = BaseURL + "assetSubtype"             // Get Type
    let SubSubAssetType                    = BaseURL + "assetSubSubtype"          // Get Type
    let AttributesGroups                   = BaseURL + "getAttributesGroups"         // Post Type
    
    let AttributesGroup                     = BaseURL + "attributesGroups" // get Type
    
    // edit profile
    let Profile                            = BaseURL + "profile"                  // Get Type / Patch type
    let Email                              = BaseURL + "email"                    // patch Type
    let Password                           = BaseURL + "password"                 // Patch Type
    // home
    let PostProduct                        = BaseURL + "asset"                    // Post Type
    let currencies                         = BaseURL + "currencies"               // Get Type
    let GetProducts                        = BaseURL + "asset"                    // Get Type
    let NewPassword                        = BaseURL + "resetPassword"              // Post Type
    
    let Models                             = BaseURL + "models"                   //Get Type
    let searchByUserId                     = BaseURL + " asset/searchByUserId"
    
    let Users                              = BaseURL + "asset/users"
    
    let Like                               = BaseURL + "like"                     // Post Type
    let sighOut                            = BaseURL + "signOut"                  // Post Type
    
    let promotion                          = BaseURL + "promotionPlan"            //Get Type
    let assest                             = BaseURL + "python/assets/"           //Get Type
    let reActivate                          = BaseURL + "assets/activate/"          //PATCH Type
    
    let PostDetails                        = BaseURL + "python/assetDetails/"     // Get Type
    let assetSuggestion                      = BaseURL + "python/assetSuggestion/" // Get Type
    let deleteAsset                         = BaseURL + "python/assets"     //Delete Type
    let likeDislike                         = BaseURL + "likesDislikeAsset/"
    
    let views                               = BaseURL + "assets/views/"  //viewers
    let comments                            = BaseURL + "comments/" // comments
    let refreshToken                        = BaseURL + "refreshToken" //refreshToken
    let notification                        = BaseURL + "notifications/" // notification
    let userAccount                         = BaseURL + "userAccount" // for delete
    let languageList                        = BaseURL + "languages/"
    let reasons                                = BaseURL + "reasons"
    let promoteAds                             = BaseURL + "promoteAds/plan" //GET Type
    let buyPromotion                           = BaseURL + "promoteAds" //POST Type
    let report                                  = BaseURL + "report"
    let faq                                     = BaseURL + "faq"
    let promoter                                = BaseURL + "promoter"//POST Type
    let pin                                     = BaseURL + "pin" //GET Type
    let follow                                  = BaseURL + "follow" // POST Type
    let getFollowees                            = BaseURL + "follow/followees" //GET Type
    let getFollowers                            = BaseURL + "follow/followers" //GET Type
    let followRequest                           = BaseURL + "followRequest" // GET Type && POST Type
    let unfollow                                = BaseURL + "unfollow" //POST Request
    let recentSearch                            = BaseURL + "assets/recentSearch/" //GET Type
    let sold                                    = BaseURL + "assets/sold/" // patch Type
    let countries                               = BaseURL + "countries" // GET Type
    let validateReferralCode                    = BaseURL + "validateReferralCode" //GET Type
    let validateFacebookEmail                   = BaseURL + "socialVerify" //POST
    let sendContacts                            = BaseURL + "contactSync/" //POST
    let insights                                = BaseURL + "assets/insights/" //GET
    let address                                 = BaseURL + "address" //POST
    let defaultAddress                          = BaseURL + "address/default"
    
    
    //Stripe
    let connectAccount                           = BaseURL + "connectAccount"
    let createCharge                             = BaseURL + "createCharge"
    
    //Wallet
    let wallet                                   = walletBaseURL + "wallet"
    let transactions                             = walletBaseURL + "walletTransaction"
    let externalAccount                          = BaseURL + "externalAccount"
    let withdrawMoney                            = walletBaseURL + "withdraw/money"
    let withdrawAmt                            = walletBaseURL + "withdraw/withdrawAmt"
    let withdrowMethods                          = walletBaseURL + "country/link"
    let estimateAmount                           = walletBaseURL + "walletTransaction/estimate"
    let withdrawLog                              = walletBaseURL + "withdraw"
    let withdrawlDetails                         = walletBaseURL + "withdraw/details"
    let recharge                                 = BaseURL + "createChargeFromApp"
    let walletRecharge                                 = BaseURL + "wallet/recharge"
 
    //Review
    let userRating                               = BaseURL + "userRating"
    let userReview                               = BaseURL + "userReview"    
}







