//
//  StoryCollectionViewCell.swift
//  CameraModule
//
//  Created by Shivansh on 11/16/18.
//  Copyright © 2018 Shivansh. All rights reserved.
//

import UIKit
import Gemini

class StoryCollectionViewCell: GeminiCell {
    @IBOutlet weak var storyBackGroundView: UIView!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var viewForSegProgressBar: UIView!

    @IBOutlet weak var textViewForStory:KILabel!
    @IBOutlet weak var vwUserDetails: UIView!

    @IBOutlet weak var storyUpArrowBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var progressCollectionView: UICollectionView!
    @IBOutlet weak var watchStoryViewersBtn: UIButton!
    
    @IBOutlet weak var viewForBottom: UIView!
     @IBOutlet weak var backBtnOutlet: UIButton!
    @IBOutlet weak var viewForTextLabel: UIView!
    var segementView:SegmentedProgressBar?
    @IBOutlet weak var progressView: UIView!
    
    var mainViewWidth:Float = 0.0
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var mainProgressView: UIView!
    @IBOutlet weak var storyPostedTime: UILabel!
    
    var storiesDetails:userStory?
    @IBOutlet weak var profileNameLabel: UILabel!
    
    override func awakeFromNib() {
        let backImage = Helper.makeFiltersForWhiteBackGroud(image:#imageLiteral(resourceName: "Story_Back"))
        backBtnOutlet.imageView?.image = backImage //  setImage(backImage, for: .normal)
        if !Utility.isDarkModeEnable(){
            backBtnOutlet.makeShadowEffect(color: UIColor.lightGray)
        }
        vwUserDetails.makeTopToBottomGeadient(topColor: .black, bottomColor: .clear)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
    func addsubviewsForProgress() {
        for _ in storiesDetails!.userStories.enumerated() {
            let originalFrame = CGRect(x: 0, y: 0, width: 0, height:4)
            let animateView = UIView(frame:originalFrame)
            animateView.backgroundColor = UIColor.yellow
            
        }
    }
    
    func setupStoryDetails(currentIndex:Int) {
        
        let userStory = storiesDetails!.userStories
        
        if let timeStamp = userStory[currentIndex].createdOn {
            let date = Date(timeIntervalSince1970:timeStamp)
            self.storyPostedTime.text = Date().offsetFrom(date:date)
        }
        
        if userStory[currentIndex].storyType == 1 {
            // image story.
            self.storyImageView.setImageOn(imageUrl: userStory[currentIndex].mediaUrl!,defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        } else if userStory[currentIndex].storyType == 3 {
            // text story.
            self.storyImageView.setImageOn(imageUrl: userStory[currentIndex].mediaUrl!,defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        }
        else {
            //video story.
             self.storyImageView.setImageOn(imageUrl: userStory[currentIndex].thumbNailUrl!,defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        }
        
        
        self.profileNameLabel.text = storiesDetails!.userName
        /*
         Bug Name :- Profile pic with initials are not being displayed in the story page
         Fix Date :- 08/06/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Added initials image
         */
            Helper.addedUserImage(profilePic: storiesDetails!.userProfilePicture, imageView: self.profileImageView, fullName: storiesDetails!.userName ?? "D")
        
    }
    
    
}


extension StoryCollectionViewCell:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let stories = storiesDetails?.userStories.count {
            return stories
        }
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfStories = storiesDetails!.userStories.count
        let total = mainViewWidth / Float(numberOfStories)
        return CGSize(width:Int(total), height:4)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let progressCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "progressCell", for: indexPath) as! ProgressCollectionViewCell
        if indexPath.row >= self.storiesDetails!.currentStoryIndex{
             progressCell.progressViewOutlet.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        } else {
             progressCell.progressViewOutlet.backgroundColor = UIColor.white
        }
        
        progressCell.contentView.backgroundColor = UIColor.clear
        progressCell.contentView.layer.cornerRadius = 2
        progressCell.contentView.layoutIfNeeded()
  
        return progressCell
    }
}


@IBDesignable class InsetLabel: KILabel {
    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0
    
    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        set {
            topInset = newValue.top
            leftInset = newValue.left
            bottomInset = newValue.bottom
            rightInset = newValue.right
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjSize = super.sizeThatFits(size)
        adjSize.width += leftInset + rightInset
        adjSize.height += topInset + bottomInset
        
        return adjSize
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += leftInset + rightInset
        contentSize.height += topInset + bottomInset
        
        return contentSize
    }
}
