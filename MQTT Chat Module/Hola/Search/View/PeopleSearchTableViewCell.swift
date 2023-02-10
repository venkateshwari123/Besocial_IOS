//
//  PeopleSearchTableViewCell.swift
//  Starchat
//
//  Created by Rahul Sharma on 21/08/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol PeopleSearchTableViewCellDelegate: class{
    func followingButtonAction(cell: PeopleSearchTableViewCell, tableType: TableType)
}

class PeopleSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    
    var tableType: TableType?
    
    weak var delegate: PeopleSearchTableViewCellDelegate?
    var isViewLoaded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isViewLoaded{
            self.isViewLoaded = true
            self.imageContainerView.makeCornerRadious(readious: self.imageContainerView.frame.size.width / 2)
            let leftColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientLeftColor)
            let rightColor = Helper.hexStringToUIColor(hex: AppColourStr.gradientRightColor)
            self.imageContainerView.makeLeftToRightGeadient(leftColor: leftColor, rightColor: rightColor)
        }
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
        if let userID = Utility.getUserid(), userID == modelData.peopleId{
            self.followView?.isHidden = true
        }else{
            self.followView?.isHidden = false
        }
        if self.followView != nil {
            setFollowButton(modelData: modelData)
        }
        /*
         Bug Name:- should show known as for star user instead of name and also user name should be shown
         Fix Date:- 16/06/21
         Fix By  :- Jayram G
         Description of Fix:- Changed text
         */
        if modelData.isStar == 1{
            self.verifiedImageView.isHidden = false
            self.detailsLabel.text = "Known as".localized + " \(modelData.knownAs ?? "")"
        }else{
            self.verifiedImageView.isHidden = true
            self.detailsLabel.text = modelData.userName
        }
        tableType = TableType.people
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
    
    
    //MARK:- Button Action
    
    @IBAction func followButtonAction(_ sender: Any) {
        print("Follow button action")
        self.delegate?.followingButtonAction(cell: self, tableType: tableType!)
    }
}
