//
//  PostingTableViewCell.swift
//  dub.ly
//
//  Created by Shivansh on 1/31/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

class PostingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var postMediaWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var locationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewForSelectedLocation: UIView!
    @IBOutlet weak var videoPlayPauseBtn: UIButton!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    @IBOutlet weak var locationMainLabel: UILabel!
    @IBOutlet weak var addToChannelSwitch: UISwitch!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var locationCloseBtn: UIButton!
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var postMediaBackView: UIView!
    @IBOutlet weak var tagLocationBtn: UIButton!
    @IBOutlet weak var categoryTitleLbl: UILabel!

 
    override func awakeFromNib() {
        super.awakeFromNib()
        captionTextView.text = "Write a caption".localized + "..."
        captionTextView.textColor = .lightGray
        categoryNameLabel.text = "Select category".localized
        tagLocationBtn.setTitle("Tag Location".localized, for: .normal)
        tagLocationBtn.setTitleColor(.setColor(lightMode: AppColourStr.textColor, darkMode: AppColourStr.whiteColor), for: .normal)
        categoryTitleLbl.text = "Category".localized
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
         // Configure the view for the selected state
    }
 }
