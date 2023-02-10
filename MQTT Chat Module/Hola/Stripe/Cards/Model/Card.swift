//
//  Card.swift
//  StripeDemo

//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 stripe. All rights reserved.


import Foundation
import Stripe

class Card {
    
    /// Card unique identification
    var id: String?
    
    /// Card last 4 digits
    var last4: String?
    
    /// Customer id of card
    var customer: String?
    
    /// Card expiry month number
    var expiryMonth: Int?
    
    /// Card expiry year number
    var expiryYear: Int?
    
    /// Card brand image, like Visa, MasterCard etc..
    var brand: UIImage?
    
    /// Is Card is default in Stripe. If card default is true then stripe default will charge from that card.
    var isDefault: Bool = false
    
    /// Is card type is Apple Pay then true else false. Normat cards are not an apple pay type.
    var isApplePay: Bool = false
    
    fileprivate init() { }
    
    
    /// Card Object for Normal card type
    /// This we will update from server response
    /// - Parameter data: card details got from server response
    init(_ data: [String: Any]) {
        id = data["id"] as? String
        if let last4 = data["last4"] as? String {
            self.last4 = "**** **** **** " + last4
        }
        customer = data["customer"] as? String
        expiryMonth = data["exp_month"] as? Int
        expiryYear = data["exp_year"] as? Int
        if let brand = data["brand"] as? String {
            self.brand = cardImage(for: brand)
        }
        if let isDefault = data["isDefault"] as? Int {
            self.isDefault = isDefault == 1 ? true : false
        }
    }
    
    /// Card Object for Apple Pay
    /// - Parameter title: Apple Pay string
    init(forApplePay title: String) {
        last4 = title
        brand = cardImage(for: "applePay")
        isApplePay = true
    }
    
    
    /// Update card default property with respect to isDefault parameter
    /// - Parameter isDefault: isDefault boolean value
    func updateCard(_ isDefault: Bool) {
        self.isDefault = isDefault
    }
    
    /// Get Card Image from brand name
    /// - Parameter brand: brand of Card exmple visa, mastercard, jcb, etc
    func cardImage(for brand: String) -> UIImage {
        switch brand {
        case "applePay": return STPImageLibrary.applePayCardImage()
        case "visa": return STPImageLibrary.visaCardImage()
        case "masterCard","mastercard": return STPImageLibrary.masterCardCardImage()
        case "discover": return STPImageLibrary.discoverCardImage()
        case "american express": return STPImageLibrary.amexCardImage()
        case "jcb": return STPImageLibrary.jcbCardImage()
        case "diners club": return STPImageLibrary.dinersClubCardImage()
        case "unionPay": return STPImageLibrary.unionPayCardImage()
        default: return STPImageLibrary.unknownCardCardImage()
        }
    }
}


struct ApplePay {
    
    /// Country code
    var countryCode: String
    
    /// Currency code
    var currencyCode: String
    
    /// Pay Title which will be visible in Apple Pay UI
    var payTitle: String
    
    /// Amount which we need to charge or authorize from Apple Pay
    var payAmount: Double
    
    /// Apple pay required details
    /// - Parameters:
    ///   - country: country code example IN, US etc
    ///   - currency: currency code example INR, USD etc
    ///   - title: this is description for amount which is will authorize or charge from apple
    ///   - amount: amount which is will authorize or charge from apple
    init(country: String, currency: String, title: String, amount: Double) {
        countryCode = country
        currencyCode = currency
        payTitle = title
        payAmount = amount
    }
}
