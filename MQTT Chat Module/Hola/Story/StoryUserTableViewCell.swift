//
//  StoryUserTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 2/15/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class StoryUserTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUserDetails(viewedUser:storyViewedUser) {
        self.nameLabel.text = viewedUser.name
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 17/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        Helper.addedUserImage(profilePic: viewedUser.profilePic, imageView: self.profileImageView, fullName: viewedUser.name)
        let timestamp = String(Int(viewedUser.viewedAt))
        let newMessageDateInString = DateExtension().getDateString(fromTimeStamp: timestamp)
        self.dayLabel.text = newMessageDateInString
        
        let lastmsgDate = DateExtension().getDateObj(fromTimeStamp: timestamp)
        let newMessageTime = DateExtension().lastMessageInHours(date: lastmsgDate)
        self.timeLabel.text = newMessageTime
    }

}
