//
//  EditProfileImageTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 15/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol EditProfileImageTableViewCellDelegate: class {
    func editProfileButtonTap()
    func privicyCheckButtonTap(isSelected: Bool)
}
class EditProfileImageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var editProfilebtnOutlet: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    //    @IBOutlet weak var checkImageView: UIImageView!
    
    
    var isPrivicySelected: Bool = false
    var delegate: EditProfileImageTableViewCellDelegate?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.makeCornerRadious(readious: self.profileImageView.frame.size.width / 2)
    //        self.imageContainerView.makeCornerRadious(readious: self.imageContainerView.frame.size.width / 2)
//        self.profileImageView.makeCornerRadious(readious: self.profileImageViewView.frame.size.width / 2)
        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
       // self.imageContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        self.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(modelData: UserProfileModel){
        if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
            if businessProfileCreated {
                self.profileImageView.setImageOn(imageUrl: modelData.businessDetails.first?.businessProfileImage, defaultImage: #imageLiteral(resourceName: "defaultImage"))
                UserDefaults.standard.setValue(modelData.businessDetails.first?.businessProfileImage, forKeyPath: AppConstants.UserDefaults.userImage)
                
                self.coverImageView.setImageOn(imageUrl: modelData.businessDetails.first?.businessCoverImage, defaultImage: Utility.setDefautlCoverImage())
            }else {
                
                /*Refactor Name :- change default cover image
                  Fix Date :- 22/03/2021
                  Fixed By :- Nikunj C
                  Description Of refactor :- change default image */
                self.coverImageView.setImageOn(imageUrl: modelData.coverImage, defaultImage: Utility.setDefautlCoverImage())
             }
        }
        
        print("Profile Picture" + modelData.profilePic! ?? "")
        if modelData.privicy == 0{
//            self.checkImageView.image = #imageLiteral(resourceName: "unchaked_icon")
            isPrivicySelected = false
        }else{
//            self.checkImageView.image = #imageLiteral(resourceName: "checked_icon")
           
            isPrivicySelected = true
        }
//        self.coverImageView.contentMode = .scaleAspectFill
    }
    
    
    
    //MARK:- Button Action
    @IBAction func editProfilePicButton(_ sender: Any) {
        delegate?.editProfileButtonTap()
    }
    
//    @IBAction func switchPrivicyButtonAction(_ sender: Any) {
//        if isPrivicySelected{
//            //            self.checkImageView.setImageWithFadeAnimation(image: #imageLiteral(resourceName: "unchaked_icon"))
//            self.privicySwitchOutlet.isOn = false
//            isPrivicySelected = false
//        }else{
//            //            self.checkImageView.setImageWithFadeAnimation(image: #imageLiteral(resourceName: "checked_icon"))
//            self.privicySwitchOutlet.isOn = true
//            isPrivicySelected = true
//        }
//        delegate?.privicyCheckButtonTap(isSelected: isPrivicySelected)
//    }
//
    
}



