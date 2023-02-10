//
//  CallHistoryViewModel.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 02/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxAlamofire
import Locksmith
import CocoaLumberjack
import Alamofire

class CallHistoryViewModel {
    
    var rx_callLogArr :Variable<Any> = Variable([])
    var callArrObserval : Observable<Any>!
    let disposeBag = DisposeBag()
    var couchbase = Couchbase.sharedInstance
    
    
    init() {
        setupObsever()
        self.creatDocumentForCallHistory()
        
    }
    
    
    func setupObsever(){
        callArrObserval = rx_callLogArr.asObservable()
    }
    
    
    func getCallHistroyDataFromDB() -> [Any] {
        
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.CallHistryDocumentID) as? String
        if documentID !=  nil{
            let dict =  couchbase.getData(fromDocID: documentID!)
            let arr = dict!["callHistoryList"]
            if let arr1 = arr as? [Any] {
                self.rx_callLogArr.value = arr1
                return arr1
            }   else { return []}
        }
        return []
    }
    
    func getCallHistoryApi() {
        
         _ = self.getCallHistroyDataFromDB()
        let timestamp = "0"
        guard let keyDict = Locksmith.loadDataForUserAccount(userAccount: AppConstants.keyChainAccount) else {return}
        guard  let token = keyDict["token"] as? String  else {return}
        
        let headerParams = ["authorization":/*AppConstants.authorization, "token":*/token,"lang": Utility.getSelectedLanguegeCode(),"timeStamp": "\(timestamp)"]
 
        let url = AppConstants.callLogs + "?" + "timeStamp=\(timestamp)"
        
        let apiCall = RxAlmofireClass()
        apiCall.newtworkRequestAPIcall(serviceName: url, requestType: .get, parameters:nil,headerParams:HTTPHeaders.init(headerParams), responseType: AppConstants.resposeType.callHistoryResponse.rawValue)
        apiCall.subject_response
            .subscribe(onNext: {dict in
                
                guard let responseKey = dict[AppConstants.resposeTypeKey] as? String else {return}
                if responseKey == AppConstants.resposeType.callHistoryResponse.rawValue{
                    self.updateCallHistoryDoc(arr: dict["response"] as! [Any])
                   // self.rx_callLogArr.value = dict["response"] ?? [:]
                }
                
            }, onError: {error in
                
            }).addDisposableTo(disposeBag)
        
    }
    
    
    func displayError(_ error: NSError?) {
        if let e = error {
            Helper.showAlertViewOnWindow(Strings.error.localized, message: e.localizedDescription)
        }
    }
    
    
    
    func creatDocumentForCallHistory(){
        
        //Creat document for callHistory
        let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.CallHistryDocumentID) as? String
        if documentID ==  nil{
            let contactDocID = couchbase.createDocument(withProperties: ["callHistoryList":""] as [String : Any])
            UserDefaults.standard.set(contactDocID, forKey: AppConstants.UserDefaults.CallHistryDocumentID)
        }
    }
    
    func updateCallHistoryDoc(arr:[Any]){
        
        let dbArr =  self.getCallHistroyDataFromDB()
        if arr.count == dbArr.count {
            return
        }else {
        
            let documentID = UserDefaults.standard.object(forKey: AppConstants.UserDefaults.CallHistryDocumentID)
            if  let document = couchbase.getDocumentObject(fromDocID: documentID as! String){
                do{
                    try document.update { (newRev) -> Bool in
                        newRev["callHistoryList"] = arr
                        return true
                    }
                }
                catch let error {
                    DDLogDebug("cdkvndkv\(error)")
                }
            } else {
                DDLogDebug("failed to get documet from provided DocID")
                return}
            
            self.rx_callLogArr.value = arr
        }
    }
    
    
}
