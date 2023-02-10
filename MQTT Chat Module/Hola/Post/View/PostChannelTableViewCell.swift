//
//  PostChannelTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 1/31/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class PostChannelTableViewCell: UITableViewCell {

    
    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var selectChannelBtn: UIButton!
    
    
    @IBOutlet weak var channelNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupChannelDetails(channel:ChannelModel) {
        self.channelNameLabel.text = channel.channelName
        Helper.addedUserImage(profilePic: channel.channelImageUrl, imageView: self.channelImageView, fullName: channel.channelName ?? "")
    }

}
