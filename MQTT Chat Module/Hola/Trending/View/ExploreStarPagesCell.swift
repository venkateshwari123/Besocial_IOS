//
//  ExploreStarPagesCell.swift
//  PicoAdda
//
//  Created by 3Embed on 02/11/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
protocol ExploreStarUsersCellDelegate: class{
    func followingButtonAction(cell: ExploreStarPagesCell)
}
class ExploreStarPagesCell: UITableViewCell {
    
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    
    
    weak var delegate: ExploreStarUsersCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    //MARK:- Set cell data
    
    ///Set people data ain cell
    func setPeopleData(modelData: PeopleModel){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        self.nameLabel.text = modelData.firstName + " " + modelData.lastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.imageViewOutlet, fullName: modelData.firstName + " " + modelData.lastName)
        self.nameLabel.text = modelData.firstName + " " + modelData.lastName
        self.detailsLabel.text = modelData.userName
        if let userID = Utility.getUserid(), userID == modelData.peopleId{
            self.followView?.isHidden = true
        }else{
            self.followView?.isHidden = false
        }
        if modelData.isStar == 1{
            self.verifiedImageView.isHidden = false
        }else{
            self.verifiedImageView.isHidden = true
        }
        if self.followView != nil {
            setFollowButton(modelData: modelData)
        }
    }
    
    ///set follow button of cell
    func setFollowButton(modelData: PeopleModel){
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        if !Utility.isDarkModeEnable(){
            self.followView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.followStatus == 0{
            var title: String = "Follow".localized
            if modelData.privicy == 1{
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
    @IBAction func followButtonAction(_ sender: Any) {
        print("Follow button action")
        self.delegate?.followingButtonAction(cell: self)
    }
}
