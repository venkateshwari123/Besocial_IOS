//
//  ContactsTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 22/08/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol ContactsTableViewCellDelegate: class{
    func followingButtonAction(cell: ContactsTableViewCell, isActive: Bool)
}

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageOutlet: UIImageView!
    @IBOutlet weak var userNameOutlet: UILabel!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var followContainerView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    weak var delegate: ContactsTableViewCellDelegate?
    var contactDetails: Contacts?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        if !Utility.isDarkModeEnable(){
            followContainerView.makeShadowEffect(color: UIColor.lightGray)
        }
        followButtonOutlet.makeCornerRadious(readious: 5)
        self.followButtonOutlet.isSelected = false
        updateFollowButtonUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setDataInContactsCell(contact: Contacts){
        userNameOutlet.text = contact.fullName == "" ?contact.registerNum : contact.fullName
        firstLastNameLabel.text = contact.firstName! + contact.lastName!
//        cell.userName.text =  contact.fullName == "" ? contact.registerNum : contact.fullName
//        cell.userStatus.text = contact.status
//        cell.numberType.text = "mobile"
//
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: contact.profilePic, imageView: self.userImageOutlet, fullName: contact.fullName ?? "D")

        if let follow = contact.follow, let status = follow["type"] as? Int{
            if status == 1 || status == 2{
                 self.followButtonOutlet.isSelected = true
            }else{
                 self.followButtonOutlet.isSelected = false
            }
        }else{
            self.followButtonOutlet.isSelected = false
        }
        contactDetails = contact
        updateFollowButtonUI()
    }
    
    func updateFollowButtonUI(){
        if self.followButtonOutlet.isSelected{
            var requestStr: String = "Following".localized
            if contactDetails != nil, let follow = contactDetails?.follow, let status = follow["type"] as? Int, status == 2{
                requestStr = "Requested".localized
            }
            followButtonOutlet.setTitle(requestStr, for: .selected)
            followButtonOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
            followButtonOutlet.backgroundColor = Utility.appColor()
        }else{
            var requestStr: String = "Follow".localized
            if contactDetails != nil && contactDetails?.privicy == 1{
                requestStr = "Request".localized
            }
            followButtonOutlet.setTitle(requestStr, for: .normal)
            followButtonOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
            followButtonOutlet.backgroundColor = UIColor.white
        }
    }
    
    //MARK:- Button Action
    @IBAction func followButtonAction(_ sender: Any) {
        if self.delegate != nil{
            if followButtonOutlet.isSelected{
                followButtonOutlet.isSelected = false
            }else{
                followButtonOutlet.isSelected = true
            }
            self.delegate?.followingButtonAction(cell: self, isActive: followButtonOutlet.isSelected)
//            updateFollowButtonUI()
        }
    }
    

}
