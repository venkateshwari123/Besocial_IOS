//
//  AcceptOrDeleteTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 12/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol AcceptOrDeleteTableViewCellDelegate: class{
    func didAcceptButtonSelected(cell: AcceptOrDeleteTableViewCell)
    func didDeleteButtonSelected(cell: AcceptOrDeleteTableViewCell)
}

class AcceptOrDeleteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageContainerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: AcceptOrDeleteTableViewCellDelegate?
    
    var isLodedOnce: Bool = false
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.acceptButton.setTitle("Accept".localized, for: .normal)
        self.deleteButton.setTitle("Deny".localized, for: .normal)
        self.acceptButton.makeCornerRadious(readious: 5.0)
        self.acceptButton.makeBorderWidth(width: 1, color: Utility.appColor())
        self.acceptView.makeShadowEffect(color: Utility.appColor())
         self.deleteButton.makeCornerRadious(readious: 5.0)
        self.deleteButton.makeBorderWidth(width: 1.0, color: UIColor.lightGray)
//        self.deleteView.makeShadowEffect(color: UIColor.lightGray)
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
            self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
            self.userImageContainerView.makeGradientToUserView()
        }
    }
    
    ///TO set data in cell for user follow request
    func setCellForRequestedChannel(channelName: String ,modelData: RequestedUserModel){
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: modelData.userName ?? "")
        self.nameLabel.text = channelName
        self.detailsLabel.text = modelData.userName
    }
    
    ///To set data in cell for follow channle request
    func setCellDataForFollowRequest(modelData: FollowRequestModel){
        Helper.addedUserImage(profilePic: modelData.profilePic, imageView: self.userImageView, fullName: modelData.userName ?? "")
        self.nameLabel.text = modelData.userName
        self.detailsLabel.text = modelData.firstName + " " + modelData.lastName
    }
    
    //MARK:- Buttons Action
    @IBAction func acceptAction(_ sender: Any) {
        delegate?.didAcceptButtonSelected(cell: self)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        delegate?.didDeleteButtonSelected(cell: self)
    }
    
}
