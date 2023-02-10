//
//  UserProfileTableViewCell.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 19/09/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

enum profileTableViewType{
    case postTableView
    case likeTableView
    case tagTableView
    case liveTableView
    case channelTableView
    case unLockedPostsTableView
    case bookmarkCollectionView
}

protocol UserProfileTableViewCellDelegate: class {
    func scrollViewScrolled(index: Int)
    func didSelectAtChannel(index: Int, modelData: [SocialModel])
    func didSelectIndex(index: IndexPath, viewType: ProfileViewType)
    func paggingServiceCallFor(tableViewType: profileTableViewType)
    func refreshingChannelData()
    func moveToPostedChannel(modelData: ProfileChannelModel)
}
protocol UserProfileScrollingDelegate {
    func likedPostsData()
    func tagPostsData()
    func userPostsData()
    func channelPostData()
    func storiesPostData()
    func liveVideosData()
    func unLockedPostsData()
    func bookMarkData()
}

class UserProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookMarkedCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var noBookMarkedPosts: UIView!
    @IBOutlet weak var liveVideosCollectionView: UICollectionView!
    @IBOutlet weak var loadingViewOutlet: UIActivityIndicatorView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var postCollectionView: UICollectionView!

    @IBOutlet weak var unLockedPostsCollectionView2: UICollectionView!
    @IBOutlet weak var likeCollectionView: UICollectionView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var channelTableView: UITableView!
    
    @IBOutlet weak var noLiveVideosVideos: UIView!
    @IBOutlet weak var storiesCollectionView: UICollectionView!
    @IBOutlet weak var noPostByYou: UIView!
    @IBOutlet weak var noPostLikedByYou: UIView!
    @IBOutlet weak var noPostTaggedYou: UIView!
    @IBOutlet weak var noStoriesView: UIView!
    @IBOutlet weak var unLockedNoPostsView: UIView!
    @IBOutlet weak var noPostByYouLabel: UILabel!
    @IBOutlet weak var noPostLikedByYouLabel: UILabel!
    @IBOutlet weak var noPostTaggedYouLabel: UILabel!
    @IBOutlet weak var noCollectionLabel: UILabel!
    @IBOutlet weak var noUnLockedPostsLabel: UILabel!
    
    weak var delegate: UserProfileTableViewCellDelegate?
    var scrollingDelegate:UserProfileScrollingDelegate?
 
    var postDataArray = [SocialModel]()
    var tagDataArray = [SocialModel]()
    var likeDataArray = [SocialModel]()
    var storyDataArray : [userStory] = []
    var channelDataArray = [ProfileChannelModel]()
    var storiesArr = [StoryModel]()
    var liveVideosModelArray = [LiveVideosModel]()
    var unLockedPostsDataArray = [SocialModel]()
    let channelViewModelObj  = CreateChannelViewModel()
    var bookMarkedArray = [SavedCollectionModel]()
    
    var selectedIndex: Int = 0
    var isTap: Bool = false
    
    var isSelf: Bool = false
    
    var canPostServiceCall: Bool = false
    var canUnLockPostServiceCall:Bool = false
    var canLikeServiceCall: Bool = false
    var canTagServiceCall: Bool = false
    var canStoryServiceCall: Bool = false
    var canServiceCallForBookMark:Bool = false
    
    struct cellIdentifier {
        static let postCollectionViewCell = "postCollectionViewCell"
        static let profilePostTableViewCell = "profilePostTableViewCell"
        static let channelPostTableViewCell = "channelPostTableViewCell"
    }
    
    var blockForChannelsViewMoreClicked : ((_ tag:Int)->Void)?
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setLocalization()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // To set cell data after API response
    func setChannelAndPostDataCell(postArray: [SocialModel], likeArray: [SocialModel], tagArray: [SocialModel], channelArray: [ProfileChannelModel],storiesArray: [userStory],liveVideoModelArray:[LiveVideosModel], selectedIndex: Int, isTap: Bool, isSelf: Bool, isAppearedFirst: Bool,unLockedPostsArray:[SocialModel],bookMarkedArray:[SavedCollectionModel]){
        self.isSelf = isSelf
        self.postDataArray = postArray
        self.storyDataArray = storiesArray
        self.likeDataArray = likeArray
        self.tagDataArray = tagArray
        self.channelDataArray = channelArray
        self.liveVideosModelArray = liveVideoModelArray
        self.unLockedPostsDataArray = unLockedPostsArray
        self.bookMarkedArray = bookMarkedArray
        self.postCollectionView.reloadData()
        self.tagCollectionView.reloadData()
        self.likeCollectionView.reloadData()
        self.storiesCollectionView.reloadData()
        self.channelTableView.reloadData()
        self.liveVideosCollectionView.reloadData()
        self.unLockedPostsCollectionView2.reloadData()
        self.bookMarkedCollectionView.reloadData()
        self.selectedIndex = selectedIndex
        self.isTap = isTap
        self.scrollToPosition()
//        if isAppearedFirst{
            self.setNoPostsView()
//        }
    }
    
    func setLocalization() {
        self.noPostByYouLabel.text = "No posts to show".localized + "."
        self.noPostLikedByYouLabel.text = "No liked posts to show".localized + "."
        self.noPostTaggedYouLabel.text = "No tagged posts to show".localized + "."
        self.noUnLockedPostsLabel.text = "No purchased posts to show".localized + "."
        self.noCollectionLabel.text = "Nothing saved yet".localized + "."
    }
    func setCanServiceCallData(post: Bool, tag: Bool, like: Bool,unLock:Bool,bookMark: Bool){
        self.canPostServiceCall = post
        self.canTagServiceCall = tag
        self.canLikeServiceCall = like
        self.canUnLockPostServiceCall = unLock
        self.canServiceCallForBookMark = bookMark
    }
    
    
    private func setNoPostsView(){
        noPostByYou.isHidden = (postDataArray.count == 0) ? false : true
        noPostLikedByYou.isHidden = (likeDataArray.count == 0) ? false : true
        noPostTaggedYou.isHidden = (tagDataArray.count == 0) ? false : true
        if channelDataArray.count == 0 {
            self.setTableViewOrCollectionViewBackground(tableView: self.channelTableView, collectionView: nil, image: UIImage(named: "channel"), labelText: "You have not created any channel.", labelWithImage: true, yPosition: self.contentView.center.y - 70)
        }else{
            self.channelTableView.backgroundView = nil
        }
        noLiveVideosVideos.isHidden = (liveVideosModelArray.count == 0) ? false : true
        noStoriesView.isHidden = (self.storyDataArray.count == 0) ? false :true
        unLockedNoPostsView.isHidden = (self.unLockedPostsDataArray.count == 0) ? false :true
        noBookMarkedPosts.isHidden = (self.bookMarkedArray.count == 0) ? false :true
    }
    
    func setTableViewOrCollectionViewBackground(tableView: UITableView? , collectionView: UICollectionView?,image : UIImage?,labelText: String?,labelWithImage:Bool , yPosition: CGFloat){
        
        let backgroundView = UIView()
        backgroundView.frame = self.contentView.bounds
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: 25))
        
        if let image = image{
            imageView.image = image
            imageView.center.y = yPosition + 10
            imageView.center.x = self.contentView.center.x
            imageView.contentMode = .scaleAspectFill
            backgroundView.addSubview(imageView)
        }
        
        if let labelText = labelText{
            label.text = labelText
            label.textAlignment = .center
            label.font = Theme.getInstance().noLabelStyle.getFont()
            
            if labelWithImage{
                label.center.y = imageView.frame.maxY
                imageView.center.x = self.contentView.center.x
                backgroundView.addSubview(label)
            }else{
                imageView.center.y = self.contentView.center.y
                imageView.center.x = self.contentView.center.x
                backgroundView.addSubview(label)
            }
        }
        
        if let tableView = tableView{
            tableView.backgroundView = backgroundView
        }
        
        if let collectionView = collectionView{
            collectionView.backgroundView = backgroundView
        }
    }
    
    
    //To scroll to given index position in scroll view (0:first, 1:Second, 2:Third)
    func scrollToPosition(){
        var frame = self.mainScrollView.bounds
        switch selectedIndex {
        case 0:
            frame.origin.x = 0.0
            break
        case 1:
            frame.origin.x = self.frame.size.width
            break
        case 2:
            frame.origin.x = self.frame.size.width * 2
            break
        case 3:
            frame.origin.x = self.frame.size.width * 3
            break
        case 4:
            frame.origin.x = self.frame.size.width * 4
            break
        case 5:
            frame.origin.x = self.frame.size.width * 5
            break
        default:
            
            /*
             Refactor Name:- Hide Channel
             Refactor Date:- 30/03/21
             Refactor By  :- Nikunj C
             Discription of Refactor:- make bookmark post as default
             */
            
            frame.origin.x = self.frame.size.width * 4
            break
        }
        self.mainScrollView.scrollRectToVisible(frame, animated: true)
    }
}

extension UserProfileTableViewCell: UITableViewDataSource, UITableViewDelegate,channelViewDelegate{
    func moveViewToChannelPostAction(_ tag: Int) {
    }
    
    func deleteChannelAction(_ tag: Int) {
            let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this channel ?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Delete", style: .default) { [weak self] (action) in
                self?.deleteChannel(tag: tag)
            }
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    
    
    func deleteChannel(tag: Int){
        guard let channelID = self.channelDataArray[tag].channelId else {return}
        channelViewModelObj.deletePostService(channelId: channelID) { (success, error) in
            if success{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConstants.notificationObserverKeys.refreshProfileData), object: nil)
            }else {
//                print(error!)
            }
        }

    }
    
    func moveToChannelPostAction(_ tag: Int, sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.channelTableView)
        let indexPath = self.channelTableView.indexPathForRow(at: buttonPosition)
        delegate?.didSelectAtChannel(index: tag, modelData: (channelDataArray[(indexPath?.row)!].dataArray))
    }
    
    func moveToPostedByChannel(_ tag: Int) {
        let data = self.channelDataArray[tag]
        delegate?.moveToPostedChannel(modelData: data)
    }
    
    func editChannelAction(_ tag : Int) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let CreateChannelVC = storyboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CreateChannelViewController) as? CreateChannelViewController else{return}
        let data = self.channelDataArray[tag]
        CreateChannelVC.selectedChannelModel = data
        
        CreateChannelVC.isEditingChannel = true
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(CreateChannelVC, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channelDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.channelPostTableViewCell) as? ChannelPostTableViewCell else{fatalError()}
        
        if isSelf {
            cell.editButtonOutlet.isHidden = false
            cell.deleteChannelBtnOutlet.isHidden = false
        }else{
            cell.deleteChannelBtnOutlet.isHidden = true
            cell.editButtonOutlet.isHidden = true
        }
        cell.channelViewDelegate = self
        cell.deleteChannelBtnOutlet.tag = indexPath.row
        cell.editButtonOutlet.tag = indexPath.row
        cell.channelViewMoreButton.tag = indexPath.row
       
        let data = self.channelDataArray[indexPath.row]
            cell.setCellData(modelData: data, isSelf: isSelf)
            return cell
//        }
    }
      
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let modelData = self.channelDataArray[indexPath.row]
        if modelData.dataArray.count == 0 {
            return 65
        }else{
            if !isSelf {
                if modelData.privicy == 1 {
                    if modelData.isSubscribed != 1{
                        return 65
                    }else{
                        let width = self.frame.size.width / 3
                        return (width - 5) * 5 / 4 + 65
                    }
                }else {
                    let width = self.frame.size.width / 3
                    return (width - 5) * 5 / 4 + 65
                }}else {
                    let width = self.frame.size.width / 3
                    return (width - 5) * 5 / 4 + 65
                }
        }
        
    }
}

extension UserProfileTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.postCollectionView{
            return self.postDataArray.count
        }else if collectionView == self.likeCollectionView{
            return self.likeDataArray.count
        }else if collectionView == self.tagCollectionView{
            return self.tagDataArray.count
        }else if collectionView == self.storiesCollectionView{
            return self.storyDataArray.first?.userStories.count ?? 0
        }else if collectionView == self.liveVideosCollectionView {
            return self.liveVideosModelArray.count
        }else if collectionView == unLockedPostsCollectionView2{
            return self.unLockedPostsDataArray.count
        }else if collectionView == bookMarkedCollectionView{
            return self.bookMarkedArray.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.postCollectionViewCell, for: indexPath) as? TrendingCollectionViewCell else{fatalError()}
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let postCell = cell as? TrendingCollectionViewCell else {return}
        if collectionView == self.postCollectionView{
            let modelData = self.postDataArray[indexPath.item]
            postCell.setCellDataFrom(modelData: modelData, isPlaying: true)
            let indexPassed: Bool = indexPath.item >= self.postDataArray.count - 10
            if canPostServiceCall && indexPassed{
                canPostServiceCall = false
                delegate?.paggingServiceCallFor(tableViewType: .postTableView)
            }
        }else if collectionView == self.tagCollectionView{
            let modelData = self.tagDataArray[indexPath.item]
            postCell.setCellDataFrom(modelData: modelData, isPlaying: true)
            let indexPassed: Bool = indexPath.item >= self.tagDataArray.count - 10
            if canTagServiceCall && indexPassed{
                canTagServiceCall = false
                delegate?.paggingServiceCallFor(tableViewType: .tagTableView)
            }
        }else if collectionView == self.likeCollectionView{
            
            let modelData = self.likeDataArray[indexPath.item]
            postCell.setCellDataFrom(modelData: modelData, isPlaying: true)
            let indexPassed: Bool = indexPath.item >= self.likeDataArray.count - 10
            if canLikeServiceCall && indexPassed{
                canLikeServiceCall = false
                delegate?.paggingServiceCallFor(tableViewType: .likeTableView)
            }
        }else if collectionView == self.storiesCollectionView {

            let modelData = self.storyDataArray.first?.userStories[indexPath.item]
            let timeStamp = modelData?.createdOn
            let timeStampInt = timeStamp!
            let exactDate = NSDate.init(timeIntervalSince1970: timeStampInt)
            let dateFormatt = DateFormatter();
            dateFormatt.dateFormat = "dd"
            
            if let date = dateFormatt.string(from: exactDate as Date) as? String{
                postCell.dateLabel.text = date
                dateFormatt.dateFormat = "MMM"
            }
            
            
            if let month = dateFormatt.string(from: exactDate as Date) as? String{
                postCell.monthLabel.text = month
            }
            
            postCell.setStoryCellDataFrom(modelData: modelData!, isPlaying: true)
            
        }else if collectionView == liveVideosCollectionView{
            let modelData = self.liveVideosModelArray[indexPath.item]
            
            let timeStamp = modelData.timestamp
            let timeStampInt = timeStamp!/1000

            let exactDate = NSDate.init(timeIntervalSince1970: timeStampInt)
            let dateFormatt = DateFormatter();
            dateFormatt.dateFormat = "dd"
            if let date = dateFormatt.string(from: exactDate as Date) as? String{
                postCell.dateLabel.text = date
                dateFormatt.dateFormat = "MMM"
            }
            if let month = dateFormatt.string(from: exactDate as Date) as? String{
                postCell.monthLabel.text = month
            }
            
            postCell.setLiveVideoDataFrom(modelData: modelData, isPlaying: true)
            let indexPassed: Bool = indexPath.item >= self.liveVideosModelArray.count - 10
            if canLikeServiceCall && indexPassed{
                canLikeServiceCall = false
                delegate?.paggingServiceCallFor(tableViewType: .liveTableView)
            }
        }else if collectionView == self.unLockedPostsCollectionView2 {
            let modelData = self.unLockedPostsDataArray[indexPath.item]
            postCell.setCellDataFrom(modelData: modelData, isPlaying: true)
            let indexPassed: Bool = indexPath.item >= self.unLockedPostsDataArray.count - 10
            if canUnLockPostServiceCall && indexPassed{
                canUnLockPostServiceCall = false
                delegate?.paggingServiceCallFor(tableViewType: .unLockedPostsTableView)
            }
        }else if collectionView == self.bookMarkedCollectionView {
                let modelData = self.bookMarkedArray[indexPath.item]
                postCell.setBookMarkCellData(modelData: modelData,index: indexPath.row)
                let indexPassed: Bool = indexPath.item >= self.bookMarkedArray.count - 10
                if canServiceCallForBookMark && indexPassed{
                    canServiceCallForBookMark = false
                    delegate?.paggingServiceCallFor(tableViewType: .bookmarkCollectionView)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bookMarkedCollectionView {
            let width = self.frame.size.width / 2
            return CGSize(width: width - 10, height: width + 35)
        }else{
            return Utility.makePostsSize(frame: self.frame)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == bookMarkedCollectionView {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }else{
            return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.postCollectionView{
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pPostCollectionView)
        }else if collectionView == self.likeCollectionView{
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pLikeCollectionView)
        }else if collectionView == self.tagCollectionView{
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pTagCollectionView)
        }else if collectionView == self.storiesCollectionView {
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pStoryCollectionView)
        }else if collectionView == self.liveVideosCollectionView {
             self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pLiveVideosCollectionView)
        }else if collectionView == self.unLockedPostsCollectionView2{
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pUnLockedPostsCollectionView)
        }else if collectionView == self.bookMarkedCollectionView {
            self.delegate?.didSelectIndex(index: indexPath, viewType: ProfileViewType.pBookMarkedCollectionView)
        }
    }
    
}


extension UserProfileTableViewCell: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        

    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isTap = false
        
        if scrollView == self.mainScrollView && !self.isTap{
            let offset = scrollView.contentOffset
            if offset.x < (self.frame.size.width * 3) / 4{
                scrollingDelegate?.userPostsData()
                if delegate != nil && self.selectedIndex != 0{
                    delegate?.scrollViewScrolled(index: 0)
                }
            }else if offset.x >= (self.frame.size.width * 3) / 4 && offset.x < (self.frame.size.width * 7) / 4{
                scrollingDelegate?.likedPostsData()
                if delegate != nil && self.selectedIndex != 1{
                    delegate?.scrollViewScrolled(index: 1)
                }
            }else if offset.x >= (self.frame.size.width * 7) / 4 && offset.x < (self.frame.size.width * 11) / 4{
                scrollingDelegate?.tagPostsData()
                if delegate != nil && self.selectedIndex != 2{
                    delegate?.scrollViewScrolled(index: 2)
                }
            }else if offset.x >= (self.frame.size.width * 11) / 4 && offset.x < (self.frame.size.width * 13) / 4{
//                scrollingDelegate?.channelPostData()
//                if delegate != nil && self.selectedIndex != 3{
//                    delegate?.scrollViewScrolled(index: 3)
//                }
//                scrollView.contentOffset = offset
                
                /*
                 Refactor Name:- Hide Channel
                 Refactor Date:- 30/03/21
                 Refactor By  :- Nikunj C
                 Discription of Refactor:- unlockedPost selected instead of channel
                 */
                
                scrollingDelegate?.unLockedPostsData()
                if delegate != nil && self.selectedIndex != 3{
                    delegate?.scrollViewScrolled(index: 3)
                }
            
            }
//            else if offset.x >= (self.frame.size.width * 13) / 4 && offset.x < (self.frame.size.width * 17) / 4 {
//                scrollingDelegate?.unLockedPostsData()
//                if delegate != nil && self.selectedIndex != 4{
//                    delegate?.scrollViewScrolled(index: 4)
//                }
//            }
            else {
                
                /*
                 Refactor Name:- Hide Channel
                 Refactor Date:- 30/03/21
                 Refactor By  :- Nikunj C
                 Discription of Refactor:- make bookmark selected instead of unlocked post
                 */
                
                scrollingDelegate?.bookMarkData()
                if delegate != nil && self.selectedIndex != 4{
                    delegate?.scrollViewScrolled(index: 4)
            }
            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isTap = false
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isTap = false
    }
}

