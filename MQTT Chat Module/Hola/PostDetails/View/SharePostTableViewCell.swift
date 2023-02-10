//
//  SharePostTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 24/11/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol SharePostTableViewCellDelegate: class{
    func sendButtonClicked(index: Int)
}


class SharePostTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userPublicName: UILabel!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var verifiedStarImage: UIImageView!
    
    var index: Int = 0
    var delegate: SharePostTableViewCellDelegate?
    
    var followModel: FollowersFolloweeModel?{
        didSet{
            self.setCellData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sendButtonOutlet.setTitle("Send".localized, for: .normal)
//        self.sendView.makeShadowEffect(color: UIColor.lightGray)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.userImageView.makeCornerRadious(readious: self.userImageView.frame.size.width / 2)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setCellData(){
        if let data = self.followModel{
            /*
             Bug Name:- Show the intials for default profile pic
             Fix Date:- 17/05/21
             Fix By  :- Jayram G
             Description of Fix:- setting initials image when user not uploaded profile pic
             */
            Helper.addedUserImage(profilePic: data.profilePic, imageView: self.userImageView, fullName: data.fullName)
            self.userNameLabel.text = "\(data.firstName ?? "")" + "\(data.lastName ?? "")"
            self.userPublicName.text  = data.userName
            /*
             Bug Name:- Handle messages sending b/w normal and star user
             Fix Date:- 24/07/21
             Fix By  :- Jayram G
             Description of Fix:- enable and disabling chat option
             */
            
            if data.isStar == 1{
                self.verifiedStarImage.isHidden = false
            }else{
                self.verifiedStarImage.isHidden = true
            }
//            if data.isChatEnable == 1{
//                if #available(iOS 13.0, *) {
//                    self.userNameLabel.textColor = .label
//                } else {
//                    self.userNameLabel.textColor = .black
//                    // Fallback on earlier versions
//                }
//                self.userPublicName.textColor = .gray
//                self.sendButtonOutlet.isEnabled = true
//                self.sendButtonOutlet.alpha = 1
//            }else{
//                self.userNameLabel.textColor = .gray
//                self.userPublicName.textColor = .gray
//                self.sendButtonOutlet.isEnabled = false
//                self.sendButtonOutlet.alpha = 0.5
//            }
           self.setSendButton(modelData: data)
        }
    }
    
    
    ///set follow button of cell
    private func setSendButton(modelData: FollowersFolloweeModel){
        self.sendButtonOutlet.makeCornerRadious(readious: 5.0)
        
        if !Utility.isDarkModeEnable(){
            self.sendView.makeShadowEffect(color: UIColor.lightGray)
        }
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        self.sendButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.messageStatus == 1{
            self.sendButtonOutlet.setTitle("Sent".localized, for: .normal)
            self.sendButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.sendButtonOutlet.backgroundColor = UIColor.white
        }else{
            self.sendButtonOutlet.setTitle("Send".localized, for: .normal)
            self.sendButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.sendButtonOutlet.backgroundColor = borderColor
        }
    }
    
    //MARK:- Button Action
    @IBAction func sendAction(_ sender: Any) {
        if let data = followModel{
            data.messageStatus = 1
            self.setSendButton(modelData: data)
            delegate?.sendButtonClicked(index: self.index)
        }
    }
    
}
