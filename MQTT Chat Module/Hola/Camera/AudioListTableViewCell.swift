//
//  AudioListTableViewCell.swift
//  dub.ly
//
//  Created by DINESH GUPTHA on 12/18/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

class AudioListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songImageView: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var songDuration: UILabel!
    
    @IBOutlet weak var songAuthor: UILabel!
    
    @IBOutlet weak var favouriteBtn: UIButton!
    
    @IBOutlet weak var dubBtn: UIButton!
    @IBOutlet weak var dubBtmheightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var songName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dubBtn.setTitle("DUB WITH THIS SOUND".localized, for: .normal)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setuSoundDetails(audio:Audio) {
        self.songName?.text = audio.name
        self.songImageView?.setImageOn(imageUrl: audio.thumbNail, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        self.songDuration?.text = String(audio.duration)
        self.songAuthor?.text = audio.artist
    }

}
