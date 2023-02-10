//
//  StripeAPI.swift
//  Save Card Without Payment (Swift)
//
//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 stripe. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

class StripeAPI {
    
    /// Dispose  bag
    let disposeBag = DisposeBag()
    
    /// Intent PublishSubject object to send response from API is called
    let intent = PublishSubject<APIResponse>()
    
    /// Cards PublishSubject object to send response from API is called
    let cards = PublishSubject<APIResponse>()
    
    /// Cards PublishSubject object to send response from API is called
    let card = PublishSubject<APIResponse>()
    
    /// DeleteCard PublishSubject object to send response from API is called
    let deleteCard = PublishSubject<APIResponse>()
    
    /// UpdateCard PublishSubject object to send response from API is called
    let updateCard = PublishSubject<APIResponse>()
    
    /// Apple Pay Charge PublishSubject object to send response from API is called
    let applePay = PublishSubject<APIResponse>()
    
    
    /// Base URL of Application
    let baseURL = AppChangables.getInstance().appBaseURL
    
    
    /// Setup Add Card Payment intent
    func setUpPaymentIntent() {
        // Create API url
        let strURL = baseURL + "setupIntent"
        // Create Header
        let header: HTTPHeaders = APIUtility.getHeaderForPost()
        // Create URLComponent object
        guard let urlComponents = URLComponents(string: strURL) else { return }
        
        RxAlamofire.requestJSON(.get,
                                urlComponents,
                                parameters: nil,
                                headers: header)
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    // API response need to update viewModel
                    self.intent.onNext(apiResponse)
                }
            }, onError: { (error) in
                // Update viewModel that API response has received an error
                self.intent.onError(error)
                // Logging error of SetUpIntent in DDLog file
                print("Got an error in SetUpIntent as \(error)")
            }) {
                // Logging dispose event of SetUpIntent in DDLog file
                print("SetUpIntent Disposed")
        }.disposed(by: disposeBag)
    }
    
    
    func addCard(_ userId: String, and paymentId: String) {
        // Create API url
        let strURL = baseURL + "customer"
        // Create Header
        let header: HTTPHeaders = APIUtility.getHeaderForPost()
        // Create params
        let params = ["userId" : userId,
                      "paymentMethod" : paymentId]
        
        RxAlamofire.requestJSON(.post,
                                strURL,
                                parameters: params,
                                encoding: JSONEncoding.default,
                                headers: header)
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    // API response need to update viewModel
                    Helper.hidePI()
                    self.card.onNext(apiResponse)
                }
            }, onError: { (error) in
                // Update viewModel that API response has received an error
                self.card.onError(error)
                // Logging error of Add Card in DDLog file
                print("Got an error in Add Card as \(error.localizedDescription)")
            }) {
                // Logging dispose event of Add Card in DDLog file
                print("Add Card Disposed")
        }.disposed(by: disposeBag)
    }
    
    /// Get all Cards from server
    /// - Parameter userId: user unique identifation
    func getCards(_ userId: String) {
        // Create API url
        let strURL = baseURL + "customer"
        // Create Header
        let header: HTTPHeaders = APIUtility.getHeaderForPost()
        // Create URLComponent object
        guard var urlComponents = URLComponents(string: strURL) else { return }
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        
        RxAlamofire.requestJSON(.get,
                                urlComponents,
                                parameters: nil,
                                encoding: JSONEncoding.default,
                                headers: header)
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    // API response need to update viewModel
                    self.cards.onNext(apiResponse)
                }
            }, onError: { (error) in
                // Update viewModel that API response has received an error
                self.cards.onError(error)
                // Logging error of Get Cards in DDLog file
                print("Got an error in Get Cards as \(error.localizedDescription)")
            }) {
                // Logging dispose event of Get Cards in DDLog file
                print("Get Cards Disposed")
        }.disposed(by: disposeBag)
    }
    
    
    func updateCard(_ userId: String, and cardId: String) {
        // Create API url
        let strURL = baseURL + "customer"
        // Create Header
        let header: HTTPHeaders = APIUtility.getHeaderForPost()
        // Create URLComponent object
        guard var urlComponents = URLComponents(string: strURL) else { return }
        urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId),
                                    URLQueryItem(name: "paymentMethod", value: cardId)]
        
        RxAlamofire.requestJSON(.patch,
                                urlComponents,
                                parameters: nil,
                                encoding: JSONEncoding.default,
                                headers: header)
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    // API response need to update viewModel
                    self.updateCard.onNext(apiResponse)
                }
            }, onError: { (error) in
                // Update viewModel that API response has received an error
                self.updateCard.onError(error)
                // Logging error of Update Card in DDLog file
                print("Got an error in Update Card as \(error.localizedDescription)")
            }) {
                // Logging dispose event of Update Card in DDLog file
                print("Update Card Disposed")
        }.disposed(by: disposeBag)
    }
    
    
    func deleteCard(_ cardId: String) {
        // Create API url
        let strURL = baseURL + "paymentMethod"
        // Create Header
        let header: HTTPHeaders = APIUtility.getHeaderForPost()
        // Create URLComponent object
        guard var urlComponents = URLComponents(string: strURL) else { return }
        urlComponents.queryItems = [URLQueryItem(name: "paymentMethod", value: cardId)]
        
        RxAlamofire.requestJSON(.delete,
                                urlComponents,
                                parameters: nil,
                                encoding: JSONEncoding.default,
                                headers: header)
            .subscribe(onNext: { (status, response) in
                if let response = response as? [String:Any] {
                    let apiResponse = APIResponse(response, with: status)
                    // API response need to update viewModel
                    self.deleteCard.onNext(apiResponse)
                }
            }, onError: { (error) in
                // Update viewModel that API response has received an error
                self.deleteCard.onError(error)
                // Logging error of Delete Cards in DDLog file
                print("Got an error in Delete Card as \(error.localizedDescription)")
            }) {
                // Logging dispose event of Deleete Card in DDLog file
                print("Delete card Disposed")
        }.disposed(by: disposeBag)
    }
    
    
//    func chargeApplePay(for userId: String, and paymentId: String, with applePay: ApplePay) {
//        // Create API url
//        let strURL = baseURL + "charge"
//        // Create Header
//        let header: HTTPHeaders = ["lan" : "en"]
//        // Create params
//        let params = ["userId" : userId,
//                      "paymentMethod" : paymentId,
//                      "amount": applePay.payAmount,
//                      "currency": applePay.currencyCode,
//                      "capture": true] as [String:Any]
//
//        RxAlamofire.requestJSON(.post,
//                                strURL,
//                                parameters: params,
//                                encoding: JSONEncoding.default,
//                                headers: header)
//            .subscribe(onNext: { (status, response) in
//                if let response = response as? [String:Any] {
//                    let apiResponse = APIResponse(response, with: status)
//                    // API response need to update viewModel
//                    self.applePay.onNext(apiResponse)
//                }
//            }, onError: { (error) in
//                // Update viewModel that API response has received an error
//                self.applePay.onError(error)
//                // Logging error of charge Apple Pay in DDLog file
//                print("Got an error in charge Apple Pay as \(error.localizedDescription)")
//            }) {
//                // Logging dispose event of charge Apple Pay in DDLog file
//                print("Charge Apple Pay Disposed")
//        }.disposed(by: disposeBag)
//    }
}
