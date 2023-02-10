//
//  PopularUserCollectionViewCell.swift
//  Do Chat
//
//  Created by Rahul Sharma on 22/02/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation

protocol PopularCollectionViewCellDelegate: class{
    func followingButtonAction(cell: PopularUserCell)
}

class PopularUserCell: UICollectionViewCell {

    
    @IBOutlet weak var profilePicImageView : UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var followButtonOutlet: UIButton!
    @IBOutlet weak var followView: UIView!
    
    
    weak var delegate: PopularCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.setUI()
        }
        // Initialization code-
    }

    
    func setUI() {
        profilePicImageView.layer.cornerRadius = profilePicImageView.frame.size.width/2
        self.contentView.makeCornerRadious(readious: 10)
    }
    
    func configureCell(modelArray: PopularUserModel) {
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: modelArray.profilePic, imageView: self.profilePicImageView, fullName: modelArray.fullName ?? "")
        userNameLabel.text = modelArray.userName
        fullNameLabel.text = modelArray.firstName + " " + modelArray.lastName
       setFollowButton(modelData: modelArray)
    }
    
    ///set follow button of cell
    func setFollowButton(modelData: PopularUserModel){
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        if !Utility.isDarkModeEnable(){
            self.followView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.followStatus == 0{
            var title: String = "Follow".localized
            if modelData.isPrivate == 1{
                title = "Request".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            var title: String = "Following".localized
            if modelData.followStatus == 2{
                title = "Requested".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.followButtonOutlet.backgroundColor = borderColor
        }
    }
    
    //MARK:- Button Action
    
    @IBAction func followButtonAction(_ sender: Any) {
        print("Follow button action")
        self.delegate?.followingButtonAction(cell: self)
    }
}
