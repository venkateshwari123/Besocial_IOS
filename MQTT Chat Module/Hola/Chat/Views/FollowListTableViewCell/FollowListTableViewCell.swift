//
//  FollowListTableViewCell.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/07/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class FollowListTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var starIndicationImage: UIImageView!
    @IBOutlet weak var userStatusLabel: UILabel!
    
    var isLodedOnce:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.imageContainerView.makeCornerRadious(readious: self.imageContainerView.frame.size.width / 2)
            self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
            self.imageContainerView.makeGradientToUserView()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /// To set data in cell from followfollowe model
    ///
    /// - Parameter model: model data
    func setFollowListCellData(model: FollowersFolloweeModel){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: model.profilePic, imageView: self.userImageView, fullName: model.fullName)
        self.userNameLabel.text = model.userName
        self.userStatusLabel.text = "\(model.firstName ?? "")"  + "\(model.lastName ?? "")"
     
        self.starIndicationImage.isHidden = !(model.isStar == 1)
        /*
         Bug Name:- Handle messages sending b/w normal and star user
         Fix Date:- 24/07/21
         Fix By  :- Jayram G
         Description of Fix:- enable and disabling chat option
         */
//        if model.isChatEnable == 1{
//            if #available(iOS 13.0, *) {
//                self.userNameLabel.textColor = .label
//            } else {
//                self.userNameLabel.textColor = .black
//            }
//            self.userStatusLabel.textColor = .gray
//        }else{
//            self.userNameLabel.textColor = .gray
//            self.userStatusLabel.textColor = .gray
//        }
    }

}
