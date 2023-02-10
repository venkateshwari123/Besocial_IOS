//
//  UserStatusDetailsTableViewCell.swift
//  Infra.Market Messenger
//
//  Created by 3Embed Software Tech Pvt Ltd on 30/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class UserStatusDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var readTimeStatusLabel: UILabel!
    @IBOutlet weak var deliveryTimeStatusLabel: UILabel!
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserStatusDataInCell(msgStatus: MessageDeliveryStatus, isRead: Bool){
        self.userNameLabel.text = msgStatus.memberIdentifier
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: msgStatus.profilePic, imageView: self.userImageView, fullName: msgStatus.memberIdentifier)
        self.readTimeStatusLabel.text = ""
        self.deliveryTimeStatusLabel.text = ""
        if isRead{
            if let date = DateExtension().getDateFromDouble(timeStamp: msgStatus.readAt!){
                let time = DateExtension().getDataAndTimeForMessageInfo(date: date)
                self.readTimeStatusLabel.text = "Read".localized + " - \(time ?? "")"
            }
            if let date = DateExtension().getDateFromDouble(timeStamp: msgStatus.deliveredAt!){
                let time = DateExtension().getDataAndTimeForMessageInfo(date: date)
                self.deliveryTimeStatusLabel.text = "Deliverd".localized + " - \(time ?? "")"
            }
        }else{
            if let date = DateExtension().getDateFromDouble(timeStamp: msgStatus.deliveredAt!){
                let time = DateExtension().getDataAndTimeForMessageInfo(date: date)
                self.deliveryTimeStatusLabel.text = "\(time ?? "")"
            }
        }
        
    }

}
