//
//  UserNameTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 29/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class UserNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userContactNumber: UILabel!
    @IBOutlet weak var userName: UILabel!
    var contInfoObj : ContactInfoTableViewController?
    var userId: String?
    var userImage: String?
    @IBOutlet weak var chatIconBtn: UIButton!
    @IBOutlet weak var videoIconBtn: UIButton!
    @IBOutlet weak var callIconBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code`  bnm,/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    
    func setUpcontactInfo(regiNum:String ,userName:String , infoObj:ContactInfoTableViewController,userID:String,profilePic:String,isBlock:Bool){
        
        self.userContactNumber.text =  userName.count != 0 ? userName : regiNum
        self.userName.text =  regiNum
        //        self.userContactNumber.text = userName
        //        self.userName.text =   regiNum
        contInfoObj = infoObj
        userId = userID
        userImage = profilePic
        self.videoIconBtn.isEnabled = !isBlock
        self.callIconBtn.isEnabled = !isBlock
        
    }
    
    
    @IBAction func chatButtonCliked(_ sender: Any) {
        
        if  (contInfoObj?.isComingFromHistory)! {
             contInfoObj?.performSegue(withIdentifier: "infoToChatView", sender: contInfoObj)
        }else {
            contInfoObj?.navigationController?.popViewController(animated: true)
        }
       
    }
    
    
    @IBAction func videoButtonCliked(_ sender: Any) {
        if Helper.checkCallGoingOn() == true{
            return
        }
       
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        
        guard let userID = userId else{ return  }
        guard let registerNum = userContactNumber.text else {return}
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
        videoView.calling_userName.text = String(format:"%@",self.userContactNumber.text!)
        videoView.userImageView.kf.setImage(with: URL(string: userImage!), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        
        videoView.addCameraView()
        window.addSubview(videoView)
    }
    
    @IBAction func audioButtonCliked(_ sender: Any) {
   
        if Helper.checkCallGoingOn() == true{
            return
        }
        
        guard let ownID = Utility.getUserid() else { return }
        MQTTCallManager.sendcallAvilibilityStatus(status: 0, topic: AppConstants.MQTT.callsAvailability + ownID)
        
        UserDefaults.standard.set(true, forKey: "iscallBtnCliked")
        guard let userID = userId else{ return  }
        guard let registerNum =  self.userContactNumber.text else {return}
        
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
        audioView.userNameLbl.text = String(format:"%@",self.userContactNumber.text!)
        audioView.callerID = userID
        audioView.setMessageData(messageData: dict)
        audioView.userImageView.kf.setImage(with: URL(string: userImage!), placeholder: #imageLiteral(resourceName: "defaultImage"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
        })
        
        window.addSubview(audioView);
    
    }
}
