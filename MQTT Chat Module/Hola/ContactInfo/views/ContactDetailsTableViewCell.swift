//
//  ContactDetailsTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 23/03/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class ContactDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var mobilelbl: UILabel!
    @IBOutlet weak var userName: UILabel!
    var perentobj : ContactDetailsTableViewController?
    var userId: String?
    var userImage: String?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    
    func showData(mobileType:String, userNum: String, perentobj: ContactDetailsTableViewController, userID:String, profilePic:String ){
        
        self.mobilelbl.text = mobileType
        self.userName.text = userNum
        self.perentobj = perentobj
        userId = userID
        userImage = profilePic
    }
    
    
    @IBAction func chatButtonCliked(_ sender: Any) {
        
        var isChatVCFound = false
        let arr = self.perentobj?.navigationController?.viewControllers
        for i:UIViewController in arr! {
            if i.isKind(of: ChatViewController.self)   {
                isChatVCFound = true
                self.perentobj?.navigationController?.popToViewController( i, animated: true)
            }
        }
        
     if isChatVCFound == false{self.perentobj?.navigationController?.popToRootViewController(animated: true)}
        
    }
    
    
    @IBAction func videoCallCliked(_ sender: Any) {
        
        if Helper.checkCallGoingOn() == true{
            return
        }
        
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        
        guard let userID = userId else{ return  }
        guard let registerNum = userName.text else {return}
        let dict = ["callerId": userID,
                    "callType" : AppConstants.CallTypes.videoCall ,
                    "registerNum": registerNum,
                    "callId": randomString(length: 100),
                    "callerIdentifier": ""] as [String:Any]
        
        UserDefaults.standard.set(dict, forKey: "storeIndexPath")
        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.callsAvailability + userID , withDelivering: .atLeastOnce)
        
        
        //for VideoCall
        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        let videoView = IncomingVideocallView(frame: CGRect(x: 0, y: 0 ,width : window.frame.width, height: window.frame.height))
        videoView.tag =  17
        videoView.setCallId()
        videoView.otherCallerId = userID
        videoView.calling_userName.text = String(format:"%@",self.userName.text!)
        videoView.userImageView.kf.setImage(with: URL(string: userImage!), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        
        videoView.addCameraView()
        window.addSubview(videoView)
        
    }
    
    
    @IBAction func audioCallCliked(_ sender: Any) {
        
        if Helper.checkCallGoingOn() == true{
            return
        }
        
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        guard let userID = userId else{ return  }
        guard let registerNum =  self.userName.text else {return}
        
        let dict = ["callerId": userID,
                    "callType" : AppConstants.CallTypes.audioCall,
                    "registerNum": registerNum,
                    "callId": randomString(length: 100),
                    "callerIdentifier": ""] as [String:Any]
        
        UserDefaults.standard.set(dict, forKey: "storeIndexPath")
        MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.callsAvailability + userID , withDelivering: .atLeastOnce)
        
        let window = UIApplication.shared.keyWindow!
        window.endEditing(true)
        let audioView = AudioCallView(frame: CGRect(x:0, y:0, width: window.frame.width, height: window.frame.height))
        audioView.tag = 15
        audioView.userNameLbl.text = String(format:"%@",self.userName.text!)
        audioView.callerID = userID
        audioView.setMessageData(messageData: dict)
        audioView.userImageView.kf.setImage(with: URL(string: userImage!), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        
        window.addSubview(audioView);
        
    }
    
    
}
