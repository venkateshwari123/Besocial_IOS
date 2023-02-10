//
//  SubscribersListModel.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 12/12/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import Foundation
class SubscribersListModel: NSObject {
    
    var subscriptionId:String?
    var subscriptionAmout:Double?
    var beneficiaryId:String?
    var buyerId:String?
    var endDateTimeStamp:Double?
    var firstName:String = ""
    var lastName:String = ""
    var number:String?
    var profilePic:String?
    var startDateTimeStamp:Double?
    var userName:String?
    var isSubscriptionCancelled:Int?
    /*
     Bug Name:- Not showing subscription cancelled time
     Fix Date:- 8/06/21
     Fix By  :- Jayram G
     Description of Fix:- Added cancellDate variable
     */
    var cancelledDate:Double?
    
    
    init(modelData:[String:Any]){
        
        if let subscriptionId = modelData["_id"] as? String{
            self.subscriptionId = subscriptionId
        }
        
        if let isSubscriptionCancelled = modelData["isSubscriptionCancelled"] as? Int {
            self.isSubscriptionCancelled = isSubscriptionCancelled
        }
        
        if let cancelDate = modelData["buyerWantsToUnscubscribeTimeStamp"] as? Double{
            self.cancelledDate = cancelDate
        }
        
        
        if let subscriptionAmout = modelData["amount"] as? Double{
            self.subscriptionAmout = subscriptionAmout
        }
        
        if let beneficiaryId = modelData["beneficiaryId"] as? String{
            self.beneficiaryId = beneficiaryId
        }
        
        if let buyerId = modelData["buyerId"] as? String{
            self.buyerId = buyerId
        }
        
        if let endDateTimeStamp = modelData["endDate"] as? Double{
            self.endDateTimeStamp = endDateTimeStamp
        }
        
        if let firstName = modelData["firstName"] as? String{
            self.firstName = firstName
        }
        
        if let lastName = modelData["lastName"] as? String{
            self.lastName = lastName
        }
        
        if let number = modelData["number"] as? String{
            self.number = number
        }
        
        if let profilePic = modelData["profilePic"] as? String{
            self.profilePic = profilePic
        }
        
        if let startDateTimeStamp = modelData["startDate"] as? Double{
            self.startDateTimeStamp = startDateTimeStamp
        }
        
        if let userName = modelData["userName"] as? String{
            self.userName = userName
        }
   
    
    
    
    }
    
}
