//
//  CallViewModel.swift
//  GroupCalling
//
//  Created by Rahul Sharma on 26/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import Foundation
import CocoaLumberjack
import RxSwift

enum CallState: String {
    case connecting
    case active
    case held
    case ended
    case request
    case inCall
    case busy
    case none
    var description: String {
        switch self {
        case .request:  return "request"
        case .inCall:   return "call"
        case .busy:     return "busy"
        case .none:     return ""
        case .connecting:
            return "connecting"
        case .active:
            return "active"
        case .held:
            return "held"
        case .ended:
            return "ended"
        }
    }
}

class CallViewModel {
    
    var disposeBag = DisposeBag()
    let createCall = PublishSubject<Bool>()
    let disconnectCall = PublishSubject<Bool>()
    let joinCall = PublishSubject<Bool>()

    var room: Int64?
    var users =  [User]()
    var userIds = [String]()
    var callId: String?
    var callState: CallState = .none
    
    func getUsersCount() -> Int {
        return userIds.count
    }
    
    func getUser(at index: Int) -> User? {
        if index < getUsersCount() {
            return users[index]
        }
        return nil
    }
    
    func getUserIds() -> [String] {
        if getUsersCount() > 0 {
//            let userIds = users.map({$0.userId})
            return userIds//.compactMap({$0})
        }
        
        return []
    }

    func addNew(_ user: User) {
        users.append(user)
    }
    
    func addNewUserId(_ userId : String){
        userIds.append(userId)
    }
    
    func remove(_ user: User) {
        if let index = users.firstIndex(where: {$0.userId == user.userId }) {
            users.remove(at: index)
        }
    }
    
    func removeAllUsers() {
        users.removeAll()
    }
    
    func createRoom() {
        let uuidDigits = Int64(UUID().hashValue)
        let currentTimeStamp = Date().getCurrentMillis()
        let room = "\(uuidDigits)\(currentTimeStamp)".replacingOccurrences(of: "-", with: "")
        self.room = Int64(room.suffix(room.count/2))
    }
    
    func getRoom() -> Int64? {
        return room
    }
    
    func setRoom(value: Int64) {
        room = value
    }
    
    func createNewCall(_ callType : String = "video") {
        let receiverIds = getUserIds()
        if receiverIds.count > 0, let room = room {
        let callAPI = CallAPI()
        if !callAPI.createCall.hasObservers {
            callAPI.createCall.subscribe(onNext: { response in
                if let data = response.response["data"] as? [String:Any] {
                    if let callId = data["callId"] as? String {
                        self.callId = callId
                        MQTTManager.shared.subscribeToTopic(topic: "call/\(callId)")
                    }
                    self.createCall.onNext(response.status )
                }else{
                    if response.statusCode == .conflict || response.statusCode == .lengthRequired {
                        self.callState = .busy
                    }
                    self.createCall.onNext(response.status )
                }
                
                if  let isCallDisconnected = UserDefaults.standard.value(forKey: "IsDisconnected") as? Bool,isCallDisconnected{
                    UserDefaults.standard.setValue(false, forKey: "IsDisconnected")
                    UserDefaults.standard.removeObject(forKey:"IsDisconnected" )
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() ){
                        self.disconnectingCall {
                            print("DISCONNECTED")
                        }
                    }
                  
                }
                print(response.response)
            }, onError: { error in

                DDLogError("Error occured in Create Call API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("callAPI.createCall is disposed")
            }).disposed(by: disposeBag)
        }
        var params = ["room": "\(room)",
            "to": receiverIds,
            "type": callType] as [String: Any]

        if let sessionId = UserDefaults.standard.value(forKey: "sessionId1"){
            params["sessionId"] = "\(sessionId)"
        }
        callAPI.createCall(params)
        }
    }
    
    func joinACall() {
        let callAPI = CallAPI()
        if !callAPI.joinCall.hasObservers {
            callAPI.joinCall.subscribe(onNext: { response in
                if let data = response.response["data"] as? [String:Any] {
                    print(data)
                    if let callId = data["callId"] as? String {
                        self.callId = callId
                        MQTTManager.shared.subscribeToTopic(topic: "call/\(callId)")
                    }
                    self.joinCall.onNext(response.status )
                }
            }, onError: { error in
                self.disconnectCall.onNext(true)
                DDLogError("Error occured in Create Call API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("callAPI.createCall is disposed")
            }).disposed(by: disposeBag)
        }
        callAPI.joinCall(self.callId!)
    }
    
    func disconnectingCall(_ callFrom : String = CallState.inCall.description,completion:@escaping()-> Void) {
        let callAPI = CallAPI()
        if !callAPI.disconnectCall.hasObservers {
            callAPI.disconnectCall.subscribe(onNext: { response in
                print(response.message)
                MQTTManager.shared.unsubscribeToTopic(topic: "call/\(self.callId ?? "")")
                if (response.response["data"] as? [String:Any]) != nil {
                    self.disconnectCall.onNext(response.status)
                    print("DISCONNECTED___SUCCESSFUL")
                }else{
                    
                    print("ERROR _____CAYSED")
                   // self.disconnectCall.onNext(response.status)
                }
                completion()
            }, onError: { error in
                completion()
                DDLogError("Error occured in Create Call API and error is \(error.localizedDescription)")
            }, onDisposed: {
                DDLogInfo("callAPI.disconnectCall is disposed")
            }).disposed(by: disposeBag)
        }
        let params = ["callId": callId ?? "",
                      "callFrom": callFrom] as [String: Any]
        callAPI.disconnectCall(params)
    }
}

extension Date {
    
    func getCurrentMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970)
    }
}
