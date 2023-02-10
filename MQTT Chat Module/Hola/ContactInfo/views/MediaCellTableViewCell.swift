//
//  MediaCellTableViewCell.swift
//  MQTT Chat Module
//
//  Created by Imma Web Pvt Ltd on 29/11/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

import UIKit

class MediaCellTableViewCell: UITableViewCell {
    
    var mediaArr = ["Media".localized,"Mute".localized]
    var mediaImageArr = ["contact_info_gallery_icon","contact_info_sound_icon"]
    
    
    @IBOutlet weak var mediaName: UILabel!
    @IBOutlet weak var media_count: UILabel!
    
    @IBOutlet weak var mediaImage: UIImageView!
    var switchh = UISwitch()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        media_count.text = "None".localized
        switchh = UISwitch.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 65, y: 8, width: 50, height: 40))
        self.addSubview(switchh)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func setUpmediaCell(index: IndexPath, withChatDocId chatDocID: String?){
        self.mediaName?.text = mediaArr[index.row] as String
        self.mediaImage.image = UIImage.init(named: mediaImageArr[index.row])
        if index.row == 0 {
            switchh.isHidden = true
            let chatDocVMObject = ChatsDocumentViewModel(couchbase: Couchbase.sharedInstance)
            if let chatDocID = chatDocID {
                if let msgs = chatDocVMObject.getMediaMessages(withChatDocID: chatDocID) {
                    if index.row == 0 {
                        self.media_count.text = "\(msgs.count)"
                    }
                }
            }
        }
        
    }
}
