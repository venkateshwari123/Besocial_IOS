//
//  SocialStoriesCollectionViewCell.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 02/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit

protocol SocialStoriesCollectionViewCellDelegate: class {
    func cellDidSelect(index: IndexPath)
    func openStoryCamera()
}

class SocialStoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    var myStories:userStory = userStory(storiesDetails:[:])
    var recentStories:[userStory] = []
    var viewedStories:[userStory] = []
    
    var index = IndexPath(row: 0, section: 0)
    var delegate: SocialStoriesCollectionViewCellDelegate?
    
    struct cellIdentifier {
        static let PostStoryCollectionViewCell = "PostStoryCollectionViewCell"
    }
    
    //MARK:- view life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.storyCollectionView.makeBorderWidth(width: 0.4, color: .darkGray)
        self.storyCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    
    /// To set stoires data in collectoion view geting data from parent class
    ///
    /// - Parameters:
    ///   - storys: my storise data
    ///   - recStories: recent stories data
    ///   - viewStories: viewed stories data
    func setCellDataInStoryCell(storys: userStory, recStories: [userStory], viewStories: [userStory]){
        self.myStories = storys
        self.recentStories = recStories
        self.viewedStories = viewStories
        self.storyCollectionView.reloadData()
    }
}


//MARK:- Collection view data source, delegate and flowlayout delegate
extension SocialStoriesCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            if myStories.userStories.count > 0{
                return 2
            }else{
                return 1
            }
        case 1:
            return self.recentStories.count
        case 2:
            return self.viewedStories.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let storyCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.PostStoryCollectionViewCell, for: indexPath) as? PostStoryCollectionViewCell else{fatalError()}
        if indexPath.section == 0{
                    //check user has stores or not.
                    if(indexPath.item == 0) {
                        //user has no stories.
                        //                storyCell.storyImageView.image = UIImage(named: "add_story")
        //                let userImage = UserDefaults.
                         
                        if let userImageUrl = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String {
                            Helper.addedUserImage(profilePic: userImageUrl, imageView: storyCell.storyImageView, fullName: Utility.getUserFullName() ?? "D")
                        }else {
                            Helper.addedUserImage(profilePic: nil, imageView: storyCell.storyImageView, fullName: Utility.getUserFullName() ?? "D")
                        }
                        storyCell.plusImageView.isHidden = false
                        storyCell.userNameLabel.text = "Add Story".localized
                    } else {
                        storyCell.plusImageView.isHidden = true
                        //user has stories. so display last story image and time details.
                        let allStories = myStories.userStories
                        let lastStory = allStories.last
                        storyCell.storyImageView.setImageOn(imageUrl: lastStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
                        storyCell.userNameLabel.text = "My Story".localized
                    }
                }else{
            let respStory:userStory
            if indexPath.section == 1 {
                respStory = recentStories[indexPath.row]
            } else {
                respStory = viewedStories[indexPath.row]
            }
            storyCell.plusImageView.isHidden = true
            let recentStory = respStory.userStories.last
            storyCell.userNameLabel.text = respStory.userName
            storyCell.storyImageView.setImageOn(imageUrl: recentStory?.thumbNailUrl, defaultImage:#imageLiteral(resourceName: "defaultPicture"))
        Helper.addedUserImage(profilePic: respStory.userProfilePicture, imageView: storyCell.userImageView, fullName: respStory.userName ?? "")
        }
        return storyCell
    }
    
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer)
    {
        if gestureReconizer.state == UIGestureRecognizer.State.began{
            self.delegate?.openStoryCamera()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60 , height: 83)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.cellDidSelect(index: indexPath)
    }
}
