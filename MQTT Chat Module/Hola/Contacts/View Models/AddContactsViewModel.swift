//
//  AddContactsViewModel.swift
//  Starchat
//
//  Created by 3Embed on 14/06/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class AddContactsViewModel: NSObject {
    
    private let api: AddContactsAPI
     var didError: ((CustomErrorStruct) -> Void)?
    var didUpdateContacts : (([UserProfile]) -> Void)?
    var didUpdate : (([String : Any]) -> Void)?
    
    init(api:AddContactsAPI) {
        self.api = api
    }

    func fetchContactsToAdd(withuserName contacts : [[String : Any]]) {
        
        self.api.getContactsList(withContacts: contacts) { (contacts, error) in
            if let arrContacts = contacts {
                if let didUpdate = self.didUpdateContacts {
                    didUpdate(arrContacts)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
            
        }
    }
  
   func sendRequest(toUserId userId : String, andMessage message : String) {
        self.api.sendRequest(userId, message: message) { (response, error) in
            if let resp = response {
                if let didUpdate = self.didUpdate {
                    didUpdate(resp)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
        }
    }
    
    func followUnfollow(_ userId : String, url : String) {
        self.api.follow(userId, url: url) { (response, error) in
            if let resp = response {
                if let didUpdate = self.didUpdate {
                    didUpdate(resp)
                }
            } else {
                if let error = error, let didError = self.didError {
                    didError(error)
                }
            }
         }
    }
    
    
    /// To update user follow status in database and server
          ///
          /// - Parameters:
          ///   - contact: contact to be updated
          ///   - isFollow: follow or unfollow
          func FollowPeopleService(isFollow: Bool, peopleId: String, privicy: Int){
          
              ContactAPI.followAndUnfollowService(with: isFollow, followingId: peopleId, privicy: privicy)
          }
    
}
