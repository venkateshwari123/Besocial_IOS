//
//  BlockedUserTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//  Author:- Jayaram G
import UIKit
class BlockedUserTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFirstNameLabel: UILabel!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    
    //MARL:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        self.blockView.makeShadowEffect(color: UIColor.lightGray)
        self.blockButtonOutlet.makeCornerRadious(readious: 5.0)
        self.blockButtonOutlet.setTitle("Unblock".localized, for: .normal)
        self.blockButtonOutlet.makeBorderWidth(width: 1, color: UIColor.lightGray)
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    /// Setting model Data into the cell
    ///
    /// - Parameter modelData: BlockedUserModel
    func setCellData(modelData: BlockedUserModel){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        let fullName = "\(modelData.firstName ?? "")" + " " + "\(modelData.lastName ?? "")"
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: fullName)
        self.userNameLabel.text = modelData.userName
        let firstName = modelData.firstName != nil ? modelData.firstName! : ""
        let lastName = modelData.lastName != nil ? modelData.lastName! : ""
        self.userFirstNameLabel.text = firstName + lastName
    }
    
}
