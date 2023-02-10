//
//  AddCardViewModel.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 22/12/19.
//  Copyright © 2019 stripe. All rights reserved.


import Foundation
import Stripe
import RxSwift

class AddCardViewModel {
    
    /// Dispose Bag
    var disposeBag = DisposeBag()
    
    /// This is used to inform ViewController that card is added successfully or not
    let card = PublishSubject<APIResponse>()
    
    
    /// Set up client secrete intent to Add card
    fileprivate var setupIntentClientSecret: String?
    
    /// User Id. This is unique identification for user
    fileprivate var userId: String?
    
    /// Set user id
    /// - Parameter id: userId
    func setUserId(_ id: String) {
        userId = id
    }
    
    /// Get user id
    func getUserId() -> String? {
        if let userId = userId {
            return userId
        }
        return ""
    }
    
    /// Get cleint secrete Intent to add card process
    func getSetupIntentClientSecret() -> String? {
        return setupIntentClientSecret
    }
    
    // MARK:- API Methods -
    func setUpIntent() {
        let stripeAPI = StripeAPI()
        if !stripeAPI.intent.hasObservers {
            stripeAPI.intent.subscribe(onNext: { [weak self] (response) in
                guard let self = self else { return }
                if let data = response.response["data"]  as? [String: Any],
                    let clientSecret = data["clientSecret"] as? String,
                    let stripePublishableKey = data["publicKey"] as? String {
                    // Store client secret Intent value locally
                    self.setupIntentClientSecret = clientSecret
                    // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
                    Stripe.setDefaultPublishableKey(stripePublishableKey)
                }
                }, onError: { (error) in
                    // Logging error of setupIntent in DDLog file
                    print("Got an error on SetUpIntent and error is \(error.localizedDescription)")
            }) {
                //Logging dispose event of stripeAPI.intent in DDLog file
                print("stripeAPI.intent completed")
            }.disposed(by: disposeBag)
        }
        // API call to create client secret key
        stripeAPI.setUpPaymentIntent()
    }
    
    /// Add card using payment id
    /// - Parameter paymentId: paymentId is generated by Stripe SDK
    func addCard(_ paymentId: String) {
        if let userId = getUserId() {
            let stripeAPI = StripeAPI()
            if !stripeAPI.card.hasObservers {
                stripeAPI.card.subscribe(onNext: { [weak self] (response) in
                    guard let self = self else { return }
                    // Update new card response to ViewControll
                    // So viewController can pass that to other ViewController
                    Helper.hidePI()
                    self.card.onNext(response)
                    }, onError: { (error) in
                        // Logging error of Add card in DDLog file
                        print("Got an error on SetUpIntent and error is \(error.localizedDescription)")
                }) {
                    //Logging dispose event of stripeAPI.card in DDLog file
                    print("stripeAPI.card completed")
                }.disposed(by: disposeBag)
            }
            // Call API to add new card
            stripeAPI.addCard(userId, and: paymentId)
        }
    }
}