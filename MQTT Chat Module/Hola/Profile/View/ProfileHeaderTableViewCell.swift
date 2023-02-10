//
//  ProfileHeaderTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {

    
    @IBOutlet weak var liveVideosButton: UIButton!
    @IBOutlet weak var postCollectionButton: UIButton!
    @IBOutlet weak var postTableButton: UIButton!
    @IBOutlet weak var tagCollectionButton: UIButton!
    @IBOutlet weak var channelButton: UIButton!
    @IBOutlet weak var storiesButton: UIButton!
    @IBOutlet weak var unLockedPostsButton: UIButton!
    @IBOutlet weak var bookMarkedPostsBtn: UIButton!
    
    @IBOutlet weak var bookMarkedHeaderView: UIView!
    @IBOutlet weak var liveVideosHeaderView: UIView!
    @IBOutlet weak var postCollectionHeaderView: UIView!
    @IBOutlet weak var postTableHeaderView: UIView!
    @IBOutlet weak var tagCollectionHeaderView: UIView!
    @IBOutlet weak var channelHeaderView: UIView!
    @IBOutlet weak var storiesHeaderView: UIView!
    @IBOutlet weak var unLockedPostsHeaderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
 } 
