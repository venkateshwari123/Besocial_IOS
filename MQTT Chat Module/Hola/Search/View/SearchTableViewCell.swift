//
//  SearchTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Rahul Sharma on 03/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol SearchTableViewCellDelegate: class{
    func followingButtonAction(cell: SearchTableViewCell, tableType: TableType)
}

class SearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    var tableType: TableType?
    
    weak var delegate: SearchTableViewCellDelegate?
    var isViewLoaded: Bool = false
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isViewLoaded{
            self.isViewLoaded = true
            
        }
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
        self.imageContainerView.makeCornerRadious(readious: self.imageContainerView.frame.size.width / 2)
        let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
        let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
        self.imageContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        self.nameLabel.text = modelData.firstName + " " + modelData.lastName
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.imageViewOutlet, fullName: modelData.firstName + " " + modelData.lastName)
        self.nameLabel.text = modelData.firstName + " " + modelData.lastName
        self.detailsLabel.text = modelData.userName
        if let userID = Utility.getUserid(), userID == modelData.peopleId{
            self.followView?.isHidden = true
        }else{
            self.followView?.isHidden = false
        }
        if self.followView != nil {
            setFollowButton(modelData: modelData)
        }
        if modelData.isStar == 1{
            self.verifiedImageView.isHidden = false
            self.detailsLabel.text = "Known as".localized + " \(modelData.knownAs)"
        }else{
            self.verifiedImageView.isHidden = true
            self.detailsLabel.text = modelData.userName
        }
        tableType = TableType.people
    }
    
    ///set channel data in cell
    func setChannelModel(modelData: ChannelListModel){
        self.imageViewOutlet.setImageOn(imageUrl: modelData.channelImageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        self.nameLabel.text = modelData.channelName
        self.detailsLabel.text = "\(modelData.subscriber)" + " " + "Subscribers".localized
        if let userID = Utility.getUserid(), userID == modelData.userId{
            self.followView.isHidden = true
        }else{
            self.followView.isHidden = false
        }
        setSubscribeButton(modelData: modelData)
        tableType = TableType.channel
    }
    
    ///set hash tag data in cell
    func setTagData(modelData: HashTagModel){
        if let imageUrl = modelData.hashTagImage {
            self.imageViewOutlet.setImageOn(imageUrl:imageUrl , defaultImage: #imageLiteral(resourceName: "HashTag_icon"))
        }else{
            self.imageViewOutlet.image = #imageLiteral(resourceName: "HashTag_icon")
        }
        self.nameLabel.text = modelData.hashTag
        self.detailsLabel.text = "\(modelData.totalPublicPost)" + " " + "Public posts".localized
        self.followView?.isHidden = true
        tableType = TableType.tag
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
    
    
    ///set button as subscribe for cell
    func setSubscribeButton(modelData: ChannelListModel){
        self.followButtonOutlet.makeCornerRadious(readious: 5.0)
        if !Utility.isDarkModeEnable(){
            self.followView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Utility.appColor()
        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.subscribeStatus == 0{
            var title: String = "Subscribe".localized
            if modelData.privicy == 1{
                title = "Request".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            var title: String = "Subscribed".localized
            if modelData.subscribeStatus == 2{
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
        self.delegate?.followingButtonAction(cell: self, tableType: tableType!)
    }
    
}
