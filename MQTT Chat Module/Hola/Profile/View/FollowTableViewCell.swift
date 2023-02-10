//
//  FollowTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher


class FollowTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageContainerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var firstAndLastNameLabel: UILabel!
    @IBOutlet weak var verifiedImageView: UIImageView!
    
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    var isLodedOnce: Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //MARK:- View life cycle
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.isLodedOnce = true
            self.userImageContainerView.makeCornerRadious(readious: self.userImageContainerView.frame.size.width / 2)
            self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
            self.userImageContainerView.makeGradientToUserView()
        }
    }
    
    func setCellData(modelData: FollowModel){
        self.userName.text = modelData.userName
        if modelData.isStar == 1{
            /*
             Bug Name:- Show Known as for star profile users
             Fix Date:- 10/07/21
             Fix By  :- Jayram G
             Description of Fix:- Added known as for star
             */
            if let knowAs = modelData.starRequest?.starUserKnownBy , knowAs != "" {
                self.firstAndLastNameLabel.text = "Know as".localized + " \(knowAs)"
            }else{
                self.firstAndLastNameLabel.text = modelData.firstName + " " + modelData.lastName
            }
        }else{
            self.firstAndLastNameLabel.text = modelData.firstName + " " + modelData.lastName
        }
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: modelData.firstName + " " + modelData.lastName)
        
        /*bug Name :- star badge for star user in follow view controller
          Fix Date :- 22/03/2021
          Fixed By :- Nikunj C
          Description Of fix :- if user is star then show star badge otherwise hide it*/
        
        if modelData.isStar == 1{
            self.verifiedImageView.isHidden = false
        }else{
            self.verifiedImageView.isHidden = true
        }
        self.setFollowButton(modelData: modelData)
    }
    
    
    ///set follow button of cell
    func setFollowButton(modelData: FollowModel){
//        if let userId = Utility.getUserid(), let follower = modelData.follower{
//            self.followView.isHidden = userId == follower
//            self.followButtonOutlet.isHidden = userId == follower
//        }
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        if !Utility.isDarkModeEnable(){
            self.followView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.status == 0{
            var title: String = "Follow".localized
            if modelData.privicy == 1{
                title = "Request".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            var title: String = "Following".localized
            if modelData.status == 2{
                title = "Requested".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.followButtonOutlet.backgroundColor = borderColor
        }
    }
    
    
    //MARK:- Button Action
    @IBAction func followAction(_ sender: Any) {
        
    }
    
}
