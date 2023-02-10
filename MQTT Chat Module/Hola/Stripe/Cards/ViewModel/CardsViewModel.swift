//
//  CardsViewModel.swift
//  StripeDemo
//
//  Created by Rahul Sharma on 20/12/19.
//  Copyright © 2019 stripe. All rights reserved.


import Foundation
import Stripe
import RxSwift

class CardsViewModel {
    
    /// Dispose bag
    var disposeBag = DisposeBag()
    
    /// isTableViewNeedReaload rx publishsubject object to inform ViewController when to update TableView
    let isTableViewNeedReaload = PublishSubject<Bool>()
    
    /// Card Array where we need to store all card details
    fileprivate var cards = [Card]()
    
    /// Selected Index of cardl
    fileprivate var selectedIndex: Int?
    
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
        return Utility.getUserid() ?? ""
    }
    
    func allCards() -> [Card]{
        return self.cards
    }
    
    /// Set up Stripe Publish key
    func setUpStripePublishKey() {
        Stripe.setDefaultPublishableKey("pk_test_wkBp1AheycW1DkLZjT3WQkNV")
    }
    
    /// Get selected index
    // It returns selected index if it has value else returns nil
    func getSelectedIndex() -> Int? {
        return selectedIndex
    }
    
    /// Set selected index
    /// - Parameter index: index of selected card
    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
    }
    
    func setSelectedCardIndex(_ index: Int, success: @escaping (Bool)->Void) {
        for (indexx,card) in cards.enumerated(){
            if indexx == index{
                card.isDefault = true
            }
            if indexx != index{
                card.isDefault = false
            }
        }
        success(true)
    }
    
    /// Add Apple pay card if device supports Apple Pay
//    func addApplePayCard() {
//        // If device support apple pay then create card object for apple pay for UI purpose
//        if Stripe.deviceSupportsApplePay() {
//            let appleCard = Card(forApplePay: "Apple Pay")
//            self.cards.append(appleCard)
//        }
//    }
    /// Update card in cards array
    /// - Parameter card: card object, it may be newly added or any card which is update
    func update(new card: Card) {
        // Check card is exsting cards array
        if let index = cards.firstIndex(where: {$0.id == card.id }) {
            // If found then update that card object with new card
            cards.remove(at: index)
            cards.insert(card, at: index)
        }
        // Else If card is new and device supports Apple Pay then
        else if Stripe.deviceSupportsApplePay() {
            // Check exsting cards count is more than 2
            // In that last card will be Apple Pay
            // And one normal card then
            if getNumberOfCards() > 2 {
                // Insert new card above the Apple Pay
                cards.insert(card, at: getNumberOfCards() - 1)
            } else {
                // Else insert new card at first position
                cards.insert(card, at: 0)
            }
        }
        // Else add new card at end of the array
        else {
            cards.append(card)
        }
        // After card updation confirm any one of them will be defalt
        makeDefaultCard()
    }
    
    /// Delete card from existing array
    /// - Parameter card: card detail
    func delete(_ card: Card) {
        // First find out index of delete card
        if let index = cards.firstIndex(where: {$0.id == card.id }) {
            // then remove from existing array
            cards.remove(at: index)
            // After card delete confirm any one of them will be defalt
            makeDefaultCard()
        }
    }
    
    /// Get number of rows for tableView
    func getNumberOfRows() -> Int {
        return getNumberOfCards()
    }
    
    /// Check cell type is Add New Card or not
    /// - Parameter index: index of cell position in TableView
    func checkCellTypeIsAddNewCard(at index: Int) -> Bool {
        // Check index is less than number of cards or not
        if index < getNumberOfCards() {
            // If index is less than cards count then cell type is not Add card
            return false
        }
        // Else cell type is Add New Card type
        return true
    }
    
    /// Get numbers of card in array
    func getNumberOfCards() -> Int {
        return cards.count
    }
    
    /// Get card from cards array
    /// - Parameter index: position in array
    func getCard(at index: Int) -> Card? {
        // Check index is less than number of cards or not
        if index < getNumberOfCards() {
            // If index is less than cards count then return card detail at index positon from cards array
            return cards[index]
        }
        // else return nil
        return nil
    }
    
    /// Get detalut card index
    /// It may get index or nil
    func getDefaultCardIndex() -> Int? {
        // If get number of cards count is greater than zero
        // And any one of the card has isDefault property true
        // then it will return that card position in array
        if getNumberOfCards() > 0,
            let index = cards.firstIndex(where: {$0.isDefault == true}) {
            // If we found default card index then we will update selectedIndex value
            setSelectedIndex(index)
            return index
        }
        // else return nil
        return nil
    }
    
    /// Make default card if there is no default card
    func makeDefaultCard() {
        // First check default card index.
        if getDefaultCardIndex() == nil {
            // If we didn't find default card index then make first index as default index
            setSelectedIndex(0)
            if let index = getSelectedIndex(), let card = getCard(at: index) {
                // And update default index position card
                card.isDefault = true
            }
        }
    }
}


extension CardsViewModel {
    
    /// Get all cards from server
    func getAllCards() {
        // Check userId has value or not
        if let userId = getUserId() {
            let stripeAPI = StripeAPI()
            if !stripeAPI.cards.hasObservers {
                stripeAPI.cards.subscribe(onNext: { [weak self] (response) in
                    // If response status is true
                    guard let self = self else{return}
                    if response.status {
                        // Parse all card details and store them in Cards array
                        if let cards = response.response["data"] as? [[String:Any]] {
                            self.cards = cards.map { Card($0)}
                        }
                    }
                    // Add apple pay if device supports
//                    self.addApplePayCard()
                    // Make default card if no card is default in cards array
                    self.makeDefaultCard()
                    // Inform UIViewController to reload TableView
                    self.isTableViewNeedReaload.onNext(true)
                }, onError: { (error) in
                    print("Got an error in stripeAPI.cards and error is \(error.localizedDescription)")
                    self.isTableViewNeedReaload.onError(error)
                }, onCompleted: {
                    print("stripeAPI.cards completed")
                }, onDisposed: {
                    print("stripeAPI.cards disposed")
                }).disposed(by: disposeBag)
            }
            // Call API to get cards from server
            stripeAPI.getCards(userId)
        }
    }
     
    
    /// Delete card from server
    /// - Parameter card: card which need to delete
    func deleteCardFromServer(_ card: Card) {
        // Check card id is there or not
        if let cardId = card.id {
            let stripeAPI = StripeAPI()
            if !stripeAPI.deleteCard.hasObservers {
                stripeAPI.deleteCard.subscribe(onNext: { (response) in
                    if response.status {
                        // If card is deleted successfully from server
                        // then delete card details from local cards array and update tableView
                        if response.status {
                            self.delete(card)
                            self.isTableViewNeedReaload.onNext(true)
                        }
                    }
                }, onError: { (error) in
                    print("Got an error in stripeAPI.cards and error is \(error.localizedDescription)")
                }, onCompleted: {
                    print("stripeAPI.cards completed")
                }, onDisposed: {
                    print("stripeAPI.cards disposed")
                }).disposed(by: disposeBag)
            }
            // Call API to delete card from server
            stripeAPI.deleteCard(cardId)
        }
    }
    
    /// Update card in server
    /// - Parameter card: card which need to update
    func updateCardInServer(_ card: Card) {
        // Check userId and cardId are there or not
        if let userId = getUserId(),
            let cardId = card.id {
            let stripeAPI = StripeAPI()
            if !stripeAPI.updateCard.hasObservers {
                stripeAPI.updateCard.subscribe(onNext: { (response) in
                    if response.status {
                        // Need to change Key data to cards
                        if response.status, let data = response.response["data"] as? [String:Any] {
                            let card = Card(data)
                            self.update(new: card)
                            self.isTableViewNeedReaload.onNext(true)
                        }
                    }
                }, onError: { (error) in
                    print("Got an error in stripeAPI.cards and error is \(error.localizedDescription)")
                }, onCompleted: {
                    print("stripeAPI.cards completed")
                }, onDisposed: {
                    print("stripeAPI.cards disposed")
                }).disposed(by: disposeBag)
            }
            // Then call API to update card
            stripeAPI.updateCard(userId, and: cardId)
        }
    }
    
    /// Charge  through Applr Pay API
    /// - Parameters:
    ///   - paymentId: apple pay paymentId
    ///   - applePay: applePay required details like country code, currency code, amount and description
    ///   - completion: response is success or failure
//    func chargeApplePay(_ paymentId: String, and applePay: ApplePay, completion: @escaping (Bool, Error?) -> Void) {
//        // Check userId
//        if let userId = getUserId() {
//            let stripeAPI = StripeAPI()
//            if !stripeAPI.applePay.hasObservers {
//                stripeAPI.applePay.subscribe(onNext: { (response) in
//                    // Update response status in completion handler
//                    completion(response.status, nil)
//                }, onError: { (error) in
//                    completion(false, error)
//                    print("Got an error on stripeAPI.applePay and error is \(error.localizedDescription)")
//                }, onCompleted: {
//                    print("stripeAPI.applePay completed")
//                }) {
//                    print("stripeAPI.applePay completed")
//                }.disposed(by: disposeBag)
//            }
//            // Call charge through Apple Pay API
//            stripeAPI.chargeApplePay(for: userId, and: paymentId, with: applePay)
//        }
//    }
}
