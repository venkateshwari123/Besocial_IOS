//
//  CallHistoryTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 15/09/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

struct callModes {
    static let incoming = "incoming"
    static let outcoming = "outgoing"
    static let missed = "missed"
}


class CallHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var callTime: UILabel!
    @IBOutlet weak var callTypeimage: UIImageView!
    
//    @IBOutlet weak var callTypeImageView: UIImageView!
    @IBOutlet weak var userImageContainer: UIView!
    var isLodedOnce: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2
            self.userImageContainer.makeCornerRadious(readious: self.userImageContainer.frame.size.width / 2)
            let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
            let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
            self.userImageContainer.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
            
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func showdataIncallHistorycell(data: [String:Any], favDatabase: [Contacts] , segmentIndex:Int) {
        
        let callType = data["callType"] as! String
        if callType == AppConstants.CallTypes.audioCall{
            self.callTypeimage.image = #imageLiteral(resourceName: "missed_audio_call")
        }
        else{
            self.callTypeimage.image = #imageLiteral(resourceName: "missed_video_call")
        }
        
        if let userImage = data["opponentProfilePic"] as? String{
            self.userImageView.setImageOn(imageUrl: userImage, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        }else{
            self.userImageView.image = #imageLiteral(resourceName: "defaultImage")
        }
        self.userName.text = data["userName"] as? String
        
        //        self.callTime.text =  convertimeStampToTime(data["calltime"] as! Double)
//        lastMessageTime
        let callTime = DateExtension().getDateFromDouble(timeStamp: data["calltime"] as! Double)
        self.callTime.text = DateExtension().lastMessageTime(date: callTime!)
//        self.callTime.text = Helper.getTimeStamp(timeStamp: data["calltime"] as! Double)
        let  callMode = data["callInitiated"] as! Bool
        
        switch callMode {
        case true:
            self.callStatus.text = callModes.outcoming
//            self.callTypeImageView.image = UIImage(named: "outgoing_call_icon")
            break
        case false:
            self.callStatus.text = callModes.incoming
//            self.callTypeImageView.image = UIImage(named: "incoming_call_icon")
            break
        }
        
        
        if segmentIndex == 0 {
            if data["callDuration"] as! Int == 0 {
                if callMode == false {
                    self.userName.textColor = UIColor.red
                    self.callStatus.text = callModes.missed
//                    self.callTypeImageView.image = UIImage(named: "missed_call_icon")
                }else {if #available(iOS 13.0, *) {
                    self.userName.textColor = UIColor.label
                } else {
                    self.userName.textColor = UIColor.black
                }}
            }else {if #available(iOS 13.0, *) {
                self.userName.textColor = UIColor.label
            } else {
                self.userName.textColor = UIColor.black
            }}
        } else{
            
            self.userName.textColor = UIColor.red
            self.callStatus.text = callModes.missed
//            self.callTypeImageView.image = UIImage(named: "missed_call_icon")
        }
        
    }
    
    
    func convertimeStampToTime(_ interVal:Double) -> String{
        
        let date = NSDate(timeIntervalSince1970: (interVal/1000))
        let currentDateFormat = DateFormatter()
        currentDateFormat.dateFormat = "dd/MM/YYYY"
        let webDate = currentDateFormat.string(from: date as Date)
        let currentDate = currentDateFormat.string(from: Date())
        
        if webDate == currentDate {
            let timeFormat = DateFormatter()
            timeFormat.dateFormat = "hh:mm a"
            let time = timeFormat.string(from: date as Date)
            return time
        }else {
            return webDate
        }
        
    }
    
}
