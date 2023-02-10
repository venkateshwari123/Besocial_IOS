//
//  FollowActivityTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 04/03/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol FollowActivityTableViewCellDelegate: class {
    func followingButtonActionAt(index: Int)
    func followUserNameClicked(name: String)
    func followHashTagClicked(hashtag: String)
    func userImagetapAction(activityType: ActivityType, index: Int)
}

class FollowActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageContainerView: UIView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var userImageButtonOutlet: UIButton!
    @IBOutlet weak var nameLabel: ActiveLabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    var index: Int = 0
    var activityType: ActivityType = .Follow
    
    var delegate: FollowActivityTableViewCellDelegate?
    
    var isLodedOnce: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isLodedOnce{
            self.isLodedOnce = true
            self.userImageContainerView.makeCornerRadious(readious: self.userImageContainerView.frame.size.width / 2)
            self.imageViewOutlet.makeCornerRadious(readious: self.imageViewOutlet.frame.size.width / 2)
            self.userImageContainerView.makeGradientToUserView()
        }
    }

    ///set activity follow model data
    func setFollowData(modelData: ActivityFollowModel, index: Int){
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.imageViewOutlet, fullName: modelData.userName)
        self.nameLabel.text = "\(modelData.message) " /*+ "you".localized*/
        let time = Helper.getTimeStamp(timeStamp: modelData.timeStamp)
        let timeArr = time.components(separatedBy: " ")
        var timeString = ""
        for item in timeArr{
            timeString.append(item.localized + " ")
        }
        self.detailsLabel.text = timeString
        setFollowButtonForActivity(modelData: modelData)
        self.index = index
        self.handleUserNameAndHashTag()
    }
    
    func setFollowButtonForActivity(modelData: ActivityFollowModel){
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        
        if !Utility.isDarkModeEnable(){
            self.followView.makeShadowEffect(color: UIColor.lightGray)
        }
        
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.amIFollowing == 0{
            let title: String = "Follow".localized
//            if modelData.privicy == 1{
//                title = "Request"
//            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            let title: String = "Following".localized
//            if modelData.followStatus == 2{
//                title = "Requested"
//            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.followButtonOutlet.backgroundColor = borderColor
        }
    }

    
    func handleUserNameAndHashTag(){
        // Attach block for handling taps on hashtag
        self.nameLabel.handleHashtagTap { (hashTag) in
            print(hashTag)
            if let delegate = self.delegate{
                delegate.followHashTagClicked(hashtag: hashTag)
            }
        }
        
        // Attach block for handling taps on usenames
        self.nameLabel.handleMentionTap { (name) in
            print(name)
            if let delegate = self.delegate{
                delegate.followUserNameClicked(name: name)
            }
        }
    }
    
    //MARK:- Button Action
    @IBAction func followButtonAction(_ sender: Any) {
        print("Follow button action")
        self.delegate?.followingButtonActionAt(index: index)
    }
    
    
    @IBAction func userImageButtonAction(_ sender: Any) {
        self.delegate?.userImagetapAction(activityType: activityType, index: index)
    }
    
}
