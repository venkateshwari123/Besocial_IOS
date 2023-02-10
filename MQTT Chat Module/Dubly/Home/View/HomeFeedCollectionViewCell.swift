
//
//  HomeFeedCollectionViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 28/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
import MarqueeLabel
import IJKMediaFramework


protocol HomeFeedCollectionViewCellDelegate: AnyObject {
    func forYoulikeButtonTap(index: Int, isSelected: Bool,isFromTrending:Bool,isXclusive: Bool)
    func forYoulikeCountButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYoucommentButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYouviewCountButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYoushareButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYouprofileImageViewTap(index: Int, userName: String?,isFromTrending:Bool,isXclusive: Bool)
    func forYousingleTapOnCell(isFromTrending:Bool,isXclusive: Bool)
    func forYoucategoryButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYoumusicButtonTap(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYoulocationButtonTap(index: Int)
    func forYoufollowUserButtonTap(index: Int, isSelected: Bool,isFromTrending:Bool,isXclusive: Bool)
    func forYouhashtagTextTapped(index: Int, hashTag: String,isFromTrending:Bool,isXclusive: Bool)
    func forYouchannelButtonTapped(index: Int,isFromTrending:Bool,isXclusive: Bool)
    func forYouopenBusinessProductLink(productUrlStr:String,title:String,isFromTrending:Bool,isXclusive: Bool)
    func forYousubscriberUserButton(index: Int, isSelected: Bool,channelId : String)
    func forYousaveToCollectionAction(isFromTrending:Bool,isXclusive: Bool)
    func forYouviewCollection(isFromTrending:Bool,isXclusive: Bool)
    func forYoumoveToCOllections(isFromTrending:Bool,isXclusive: Bool)
    func forYouupdateBookMarkData(index: Int,isSelected: Bool,isFromTrending:Bool,isXclusive: Bool)
    func switchFollowingAndForYou(isFromTrending: Bool,isXclusive: Bool,gesture: UISwipeGestureRecognizer)
    func muteAudio(isFromTrending: Bool,isXclusive: Bool)
    func sendTipAction(isFromTrending:Bool, index: Int,isXclusive: Bool)
    /*
     Bug Name :- Read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added read more actions delegate to update status
     */
    func forYouviewmoreTapped(isViewed: Bool,index : Int,isFromTrending: Bool,isXclusive: Bool)
    func forYoupaidPostTap(isFromTrending: Bool, index: Int,isXclusive: Bool)
    func forYounavigateToConfirmSubscriptionVc(isFromTrending: Bool, index: Int,isXclusive: Bool)
    func showMediaOptions()
}

class HomeFeedCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var musicViewHeightConstraint: NSLayoutConstraint!
    
    /*
     Bug Name :- should be able to click on rotating inage to open videos with that sound
     Fix Date :- 15/05/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added musice subview height constraint and handling
     */
    @IBOutlet weak var musicSubViewheightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shareToChatView: UIView!
    @IBOutlet weak var verificationIndicationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var followingBtnOutlet: UIButton!
    @IBOutlet weak var saveToCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveToCollectionView: UIView!
    @IBOutlet weak var postImageScrollView: UIScrollView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var savedViewPostOutlet: UIView!
    
    @IBOutlet weak var businessPostBtn: UIButton!
    @IBOutlet weak var savedViewPostsButtonOutlet: UIButton!
    
    @IBOutlet weak var savedViewPostsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveToCollectionBtnOutlet: UIButton!
    
    @IBOutlet weak var followBtnOutlet: UIButton!
    @IBOutlet weak var verifyIndicationImageViewOutlet: UIImageView!
    
    @IBOutlet weak var floatingMusicImageView: UIImageView!
    @IBOutlet weak var likeCountButtonOutlet: UIButton!
    
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var muteView: UIView!
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var viewCount: UIButton!
    @IBOutlet weak var userDetailsView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    @IBOutlet weak var xclusiveBackView: UIView!
    @IBOutlet weak var followImageViewOutlet: UIImageView!
    @IBOutlet weak var userNamelabel: MarqueeLabel!
    @IBOutlet weak var postLocationButtonOutlet: UIButton!
    /*
     Bug Name :- Read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Changed title label type , added active label as KILabel has some issue
     */
    @IBOutlet weak var subscribeUserBtn: UIButton!
    @IBOutlet weak var unlockPostBtn: UIButton!
    @IBOutlet weak var postDetailsLabel: ActiveLabel!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryNameOutlet: UILabel!
    @IBOutlet weak var categoryButtonOutlet: UIButton!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var bottomConstarint: NSLayoutConstraint!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidth: NSLayoutConstraint!
    @IBOutlet weak var postImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var postImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var xclusivePostLbl: UILabel!
    @IBOutlet weak var earnedTipsCount: UIButton!
    @IBOutlet weak var earnedTipsView: UIView!
    
    
    @IBOutlet weak var sendTipView: UIView!
//    @IBOutlet weak var readMoreBtnOutlet: UIButton!
    
    @IBOutlet weak var sendTipBtn: UIButton!
    var currentPlayer:IJKFFMoviePlayerController?
    var postDetailsControllerObject:PostDetailsViewController? = nil
    var isUrlTapped: Bool = false
    var isTrending  = false
    var isXclusive = false
    var isDoneOnce: Bool = false
    var videoUrl: URL?
    var index: Int = 0
    var delegate: HomeFeedCollectionViewCellDelegate?
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var doubleTapGR : UITapGestureRecognizer? = nil
    var swipeGesture: UISwipeGestureRecognizer? = nil
    var forYouPostsRightGesture: UISwipeGestureRecognizer? = nil
    var isLabelAtMaxHeight = false
    var isAspectFill = true
    
    /*
     Bug Name :- Read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added required variables
     */
    var fullText = ""
    var truncatedText = ""
    var truncatedLength = 60
    var isTruncated = true
    /*
     Feat Name:- Readmore/Readless
     Feat Date:- 23/05/21
     Feat by  :- jayaram G
     Discription of Feat:- Added custom type as readmore/readless
     */
    let readMoreType = ActiveType.custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized)
    
    var socialModel: SocialModel?{
        didSet{
            self.setCellData()
        }
    }
    
    var profileChannelModel: ProfileChannelModel?{
        didSet{
        }
    }
    /// This is variable to store the new followed userIds
    /// to update the follow/following status rather than calling API
    var newFollowersList:[String]?
    var removeFollowersList:[String]?
    
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        //make corner radious for user and music image view
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        self.musicImageView.makeCornerRadious(readious: musicImageView.frame.size.width / 2)
        self.followBtnOutlet.setTitle("Follow".localized, for: .normal)
        self.followButtonOutlet.setTitle("Follow".localized, for: .normal)
        
        viewCount.addShadowToText()
        commentCount.addShadowToText()
        self.likeCountButtonOutlet.addShadowToText()
        self.userNamelabel.addShadowToText()
        self.postLocationButtonOutlet.addShadowToText()
        self.categoryNameOutlet.addShadowToText()
        self.postDetailsLabel.addShadowToText()
        self.followBtnOutlet.backgroundColor = Utility.appColor()
        /*
         Feat Name:- Readmore/Readless
         Feat Date:- 23/05/21
         Feat by  :- jayaram G
         Discription of Feat:- Added custom type as readmore/readless
         */
        self.postDetailsLabel.enabledTypes = [.hashtag,.mention,.url,readMoreType]
        self.unlockPostBtn.makeBorderWidth(width: 1.5, color: .white)
        self.subscribeUserBtn.makeBorderWidth(width: 1.5, color: .white)
        
        self.unlockPostBtn.makeCornerRadious(readious: 15)
        self.subscribeUserBtn.makeCornerRadious(readious: 15)
        self.unlockPostBtn.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        self.subscribeUserBtn.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

        self.sendTipBtn.makeBorderWidth(width: 2, color: Helper.hexStringToUIColor(hex: "#FF426B"))
        self.sendTipBtn.setTitle("Send Tip".localized, for: .normal)
        self.xclusivePostLbl.text = "Xclusive Post".localized

        self.postImageScrollView.minimumZoomScale = 1.0
        self.postImageScrollView.maximumZoomScale = 6.0
        self.saveToCollectionViewHeightConstraint.constant = 0
        self.savedViewPostsHeightConstraint.constant = 0
        //Tap gesture setup
        //Double tap gesture
        doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapHandle(_:)))
        //        doubleTapGR.delegate = self
        doubleTapGR!.numberOfTapsRequired = 2
        doubleTapGR!.numberOfTouchesRequired = 1
        self.addGestureRecognizer(doubleTapGR!)
        
        /*
         Feature Name :- Add swipe to switch follow and foryou
         Feature Date :- 21/04/2021
         Featured By :- Jayaram G
         Description Of Feature :- Added swipe gesture to the cell
         */
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandle(_:)))
        
        forYouPostsRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeGestureHandleForYouPosts(_:)))
        
        if forYouPostsRightGesture != nil {
            self.postImageView.addGestureRecognizer(self.forYouPostsRightGesture!)
        }
        if swipeGesture != nil {
            self.addGestureRecognizer(swipeGesture!)
        }
        
        //Single tap gesture
        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(self.singleTapHandle(_:)))
        //        singleTapGR.delegate = self
        singleTapGR.numberOfTapsRequired = 1
        singleTapGR.numberOfTouchesRequired = 1
        postImageView.addGestureRecognizer(singleTapGR)
        singleTapGR.require(toFail: doubleTapGR!)
        /*
         Feat Name:- Readmore/Readless
         Feat Date:- 23/05/21
         Feat by  :- jayaram G
         Discription of Feat:- removed gesture for label
         */
//        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.labelAction(gesture:)))
//        self.postDetailsLabel.addGestureRecognizer(tap)
//        self.postDetailsLabel.isUserInteractionEnabled = true
//        tap.delegate = self
        
    }
    
     func labelAction()
    {
        if self.socialModel!.isExpand {
            self.socialModel!.isExpand = false
            self.delegate?.forYouviewmoreTapped(isViewed: false, index: self.index,isFromTrending: self.isTrending,isXclusive: self.isXclusive)
        }else{
            self.delegate?.forYouviewmoreTapped(isViewed: true, index: self.index,isFromTrending: self.isTrending,isXclusive: self.isXclusive)
            self.socialModel!.isExpand = true
        }
        
        self.postDetailsLabel.attributedText = expandOrCollapse()
        //            self.delegate?.forYoureloadTableView(index: self.index)
        self.reloadInputViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func makeGradientColorForUserAndTopView(){
        if !self.isDoneOnce{
            self.isDoneOnce = true
            let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
            let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
            self.makeGradiantColor(onView: self.userDetailsView, topColor: colorTop, bottomColor: colorBottom)
            self.makeGradiantColor(onView: self.musicView, topColor: colorBottom, bottomColor: colorTop)
        }
    }
    
    //To make gradient color on a view
    func makeGradiantColor(onView: UIView, topColor: UIColor, bottomColor: UIColor){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = onView.bounds
        onView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    

    
    /// To set all cell data according to media type
    func setCellData() {
        if socialModel?.mediaType == 1, let mainUrl = socialModel?.imageUrl{
            
            
            /*
             Bug Name:- videos and images stretched
             Fix Date:- 18th Dec 2021
             Fixed By:- Nikunj C
             Description of Fix:- remove height and c_scale from cloudinary url bcz it stretch video or image
             */
            
            var updatedMainUrl = mainUrl.replace(target: "upload/", withString: "upload/a_ignore/w_\(Int(postImageScrollView.frame.size.width))/")

            if let model = socialModel, model.imageUrlWidth > model.imageUrlHeight {
                updatedMainUrl = mainUrl.replace(target: "upload/", withString: "upload/a_ignore/w_\(Int(postImageScrollView.frame.size.width))/")
            }else{
                updatedMainUrl = mainUrl.replace(target: "upload/", withString: "upload/a_ignore/w_\(Int(postImageScrollView.frame.size.width))/")
            }
                    
            /*
             Bug Name :- if a photo or video is blurred , don’t play video but show the buy post option
             Fix Date :- 07/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Handled video url for paid and normal post , making video url nil if post is paid and not purchased
             */
            let endIndex = updatedMainUrl.index(updatedMainUrl.endIndex, offsetBy: -3)
            var truncated = updatedMainUrl.substring(to: endIndex)
            updatedMainUrl = truncated + "mp4"
            // paid post
                if socialModel?.userId == Utility.getUserid() {
                    self.videoUrl = URL(string: updatedMainUrl)
                }else{
                    if socialModel?.isPurchased == 1 {
                        self.videoUrl = URL(string: updatedMainUrl)
                    }else if socialModel?.postAmount == 0{
                        self.videoUrl = URL(string: updatedMainUrl)
                    }else{
                        self.videoUrl = nil
                    }
            }

            
            self.muteBtn.isHidden = false
        }else{
            self.muteBtn.isHidden = true
        }
        self.thumbnailImageView.contentMode = UIView.ContentMode.scaleAspectFill
        self.postImageView.contentMode = UIView.ContentMode.scaleAspectFill
        
        guard let model = socialModel else {return}
        if model.imageUrlWidth > model.imageUrlHeight {
            print("Thumbnail height \(CGFloat((model.imageUrlHeight *  Float(CGFloat(postImageScrollView.frame.size.width))) / model.imageUrlWidth)), Post Image height \(CGFloat((model.imageUrlHeight *  Float(CGFloat(postImageScrollView.frame.size.width))) / model.imageUrlWidth))")
            self.thumbnailWidth.constant =  postImageScrollView.frame.size.width
            self.thumbnailHeight.constant =  CGFloat((model.imageUrlHeight *  Float(CGFloat(postImageScrollView.frame.size.width))) / model.imageUrlWidth)
            self.postImageViewWidth.constant = postImageScrollView.frame.size.width
            self.postImageViewHeight.constant =  CGFloat((model.imageUrlHeight *  Float(CGFloat(postImageScrollView.frame.size.width))) / model.imageUrlWidth)
            }else{
                
                
                /*
                 Bug Name:- video and images stretched
                 Fix Date:- 17th Dec 2021
                 Fixed By:- Nikunj C
                 Description of Fix:- if more then screen ratio show it with  scaleAspectFit and for squre video like 320* 320 or 640 * 640 show it in it's original size
                 */
                let screenSize: CGRect = UIScreen.main.bounds
                let screenRatio = screenSize.width/screenSize.height
                
                let ratio = CGFloat(model.imageUrlWidth)/CGFloat(model.imageUrlHeight)
                
                if ratio > screenRatio{
                    self.thumbnailImageView.contentMode = .scaleAspectFit
                    self.postImageView.contentMode = .scaleAspectFit
                    self.postImageViewHeight.constant = postImageScrollView.frame.size.height
                    self.thumbnailHeight.constant = postImageScrollView.frame.size.height
                }
                else if ratio == 1{
                    self.postImageViewHeight.constant = CGFloat(model.imageUrlHeight)
                    self.thumbnailHeight.constant = CGFloat(model.imageUrlHeight)
                    layoutIfNeeded()
                }else{
                    self.postImageViewHeight.constant = postImageScrollView.frame.size.height
                    self.thumbnailHeight.constant = postImageScrollView.frame.size.height
                }
                self.thumbnailWidth.constant = postImageScrollView.frame.size.width
                self.postImageViewWidth.constant = postImageScrollView.frame.size.width
        }
        
        print("*****Thumbnail Image \(self.socialModel?.thumbnailUrl ?? "")")
        print("*****Original Image \(socialModel?.imageUrl ?? "")")
        
        
        /*
         Refactor Name:- use imageUrl in postImageView instead of mainImageUrl
         Refactor Date:- 05/04/21
         Refactor By  :- Nikunj C
         Description of Refactor:- use imageUrl in postImageView instead of mainImageUrl
         */
        if socialModel?.mediaType == 1, var mainUrl = socialModel?.imageUrl{
            if socialModel?.postAmount == 0 {
                mainUrl = socialModel?.imageUrl?.replace(target: "e_blur:2000,o_80,/t_media_lib_thumb/", withString: "") ?? ""
                if let video =  URL(string: mainUrl){
                AVAsset(url: video).generateThumbnail() { [weak self] (image) in
                            DispatchQueue.main.async {
                                guard self?.currentPlayer != nil else {
                                    return
                                }
                                self?.postImageView.image = image
                            }
                        }
                }
            }else{
                self.postImageView.setImageOn(imageUrl: socialModel?.thumbnailUrl, defaultImage:UIImage())
            }

        }else{
            var mainUrl = socialModel?.imageUrl
            if socialModel?.postAmount == 0 {
              mainUrl = socialModel?.imageUrl?.replace(target: "e_blur:2000,o_80,/t_media_lib_thumb/", withString: "")
            }else{
                mainUrl = self.socialModel?.imageUrl ?? ""
            }
            self.thumbnailImageView.setImageOn(imageUrl: self.socialModel?.thumbnailUrl, defaultImage: UIImage(),isThumbnail : true)
            self.postImageView.setImageOn(imageUrl: mainUrl, defaultImage:UIImage())
        }
        
        if socialModel?.userName?.count ?? 0 > 7 {
            
        }
        
        /*
         Bug Name :- Home page->Allowing to share the paid post in the chat
         Fix Date :- 19/08/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Hiding share button for paid posts
         */
        if socialModel?.isPaid == true {
            self.shareToChatView.isHidden = true
        }else{
            self.shareToChatView.isHidden = false
        }
        setPaidView()
        self.setFavouriteButtonsAndCounts()
        self.setUserDetails()
        self.setFollowingUserStatus()
        self.linkHandler()
    }
    
    
    
    func setPaidView() {
        // paid post
               
    }
    /*
     Bug Name :- Active Label
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Adding link handler for active label
     */
    /// To handle link in description
    private func linkHandler(){
        postDetailsLabel.customize { label in
//            self.postDetailsLabel.attributedText = Helper.makeAttributedString(title:socialModel?.title ?? "" , font: Utility.Font.Bold.ofSize(14))

            /*
             Bug Name :- hash tag and user tag is to be made bold white
             Fix Date :- 29/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added configureLinkAttribute for label
             */
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                switch type {
                case .hashtag,.email,.mention,.url:
                    atts[NSAttributedString.Key.font] = Utility.Font.Bold.ofSize(16)
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.white//UIColor.textBlackColor
                /*
                 Feat Name:- Readmore/Readless
                 Feat Date:- 23/05/21
                 Feat by  :- jayaram G
                 Discription of Feat:- added attributes for readmore/readless text
                 */
                case .custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized):
                    atts[NSAttributedString.Key.font] = Utility.Font.Bold.ofSize(16)
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.white
                default: ()
                }
                return atts
            }

            self.truncatedText = getText(fullText: socialModel?.title ?? "")
                   label.attributedText = Helper.makeAttributedString(title: socialModel?.title ?? "", font: Utility.Font.Regular.ofSize(16))
            label.attributedText = self.expandOrCollapse()
            /*
             Feat Name:- Readmore/Readless
             Feat Date:- 23/05/21
             Feat by  :- jayaram G
             Discription of Feat:- added action
             */
            label.handleCustomTap(for: readMoreType) { (str) in
                self.labelAction()
            }
            label.handleMentionTap {
                self.isUrlTapped = true
                self.delegate?.forYouprofileImageViewTap(index: self.index, userName: $0, isFromTrending: self.isTrending, isXclusive: self.isXclusive)
                
            }
            label.handleHashtagTap {
                self.delegate?.forYouhashtagTextTapped(index: self.index, hashTag: $0,isFromTrending: self.isTrending, isXclusive: self.isXclusive)}
         //   label.handleURLTap { self.alert("URL", message: $0.absoluteString) }
        }
    }
    
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- To get full title of the post
     */
    func getText(fullText: String) -> String{
        
        self.fullText = fullText
        
        if fullText.count < truncatedLength{
            return self.fullText
        }
        else{
            let index = fullText.index(fullText.startIndex, offsetBy: truncatedLength - 1)
            self.truncatedText = fullText[...index].description
            return self.truncatedText
        }
    }
    
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- To get dynamic text of the title
     */
    func expandOrCollapse() -> NSMutableAttributedString? {
    
        
        if self.fullText.count < truncatedLength{
            let myString:NSString = (self.socialModel?.title)! as NSString
            var myMutableString = NSMutableAttributedString()
            myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size:  16.0)!])
            return myMutableString
        }else{
            if self.socialModel!.isExpand {
//                self.readMoreBtnOutlet.setTitle(" view less", for: .normal)
                let myString:NSString = (self.fullText + "..." + "Read Less".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size: 16.0)!])
                myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                return myMutableString
                
            }
            else{
//                self.readMoreBtnOutlet.setTitle(" view more", for: .normal)
                let myString:NSString = (self.truncatedText + "..." + "Read More".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size: 16.0)!])
                myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                return myMutableString
            }
        }
    }
    
    
    /// to set buttons and there counts
    private func setFavouriteButtonsAndCounts(){
        if let data = socialModel {
            if data.liked == 1{
                  self.likeImageView.image = UIImage(named: "like_on")
            }else{
                 self.likeImageView.image = UIImage(named: "like_off.dubly")
            }
            self.likeCountButtonOutlet.setTitle("\(String(describing: data.likesCount))", for: UIControl.State.normal)
            
            /*
             Refactor Name:- use distinctview in home page
             Refactor Date:- 30/03/21
             Refactor By  :- Nikunj C
             Discription of Refactor:- use distincView instead of totalviews
             */
            
            self.viewCount.setTitle("\(String(describing: data.distinctView))", for: UIControl.State.normal)
            self.commentCount.text = "\(data.commentCount)"
            if data.tipsAmount ?? 0.0 > 0.0{
                self.earnedTipsView.isHidden = false
            }else{
                self.earnedTipsView.isHidden = true
            }
            self.earnedTipsCount.setTitle("\(data.tipsAmount?.formatUsingAbbrevation() ?? "0.0")", for: .normal)
        }
    }
    
    /// To set user details
    private func setUserDetails(){
        if socialModel?.isStar == 1 ||  socialModel!.isStarBool  {
            self.verifyIndicationImageViewOutlet.isHidden = false
            self.verificationIndicationHeightConstraint.constant = 25
        }else {
            self.verificationIndicationHeightConstraint.constant = 0
            self.verifyIndicationImageViewOutlet.isHidden = true
        }
        if socialModel?.userId == Utility.getUserid() {
            self.xclusiveBackView.isHidden = true
        }else {
            if socialModel?.isPurchased == 1 {
                self.xclusiveBackView.isHidden = true
            }else if socialModel?.postAmount == 0 {
                self.xclusiveBackView.isHidden = true
            }else{
                self.xclusiveBackView.isHidden = false
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.xclusiveBackView.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//                self.xclusiveBackView.addSubview(blurEffectView)
                self.unlockPostBtn.setTitle("Unlock this post for".localized + " \(socialModel?.postAmount ?? 0) ".uppercased(), for: .normal)
                if socialModel?.subscriptionAmount ?? 0 > 0 {
                    self.subscribeUserBtn.isHidden = false
                }else {
                    self.subscribeUserBtn.isHidden = true
                }

                self.subscribeUserBtn.setTitle("Subscribe for".localized + " \(socialModel?.subscriptionAmount ?? 0.0) ".uppercased(), for: .normal)
            }
        }
        if let place = socialModel?.place, place.count > 0{
            
            self.postLocationButtonOutlet.setTitle(place, for: .normal)
            self.postLocationButtonOutlet.isHidden = false
        }else{
            self.postLocationButtonOutlet.isHidden = true
        }
        
        if let channelName = socialModel?.channelName, channelName == "" {
            if let businessPostType = socialModel?.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
                self.userNamelabel.text = "@\(socialModel?.businessProfileObj?.businessName ?? "")" + "  "
                Helper.addedUserImage(profilePic: socialModel?.businessProfileObj?.businessProfilePic, imageView: self.userImageView, fullName: socialModel?.businessProfileObj?.businessName ?? "A")
            }else {
                self.userNamelabel.text = "@\(socialModel?.userName ?? "")" + "  "
                /*
                 Bug Name:- Show the intials for default profile pic
                 Fix Date:- 12/05/21
                 Fix By  :- Jayram G
                 Description of Fix:- setting initials image when user not uploaded profile pic
                 */
                Helper.addedUserImage(profilePic: socialModel?.profilePic, imageView: self.userImageView, fullName: socialModel?.fullNameWithSpace ?? "A")
            }
        }else{
            self.userNamelabel.text = "@\(socialModel?.channelName ?? "" )" + "  "
            self.userImageView.setImageOn(imageUrl: socialModel?.channelImageUrl, defaultImage: #imageLiteral(resourceName: "defaultImage"))
        }
    
//        if  socialModel?.title == ""{
//         self.postDetailsLabel.isHidden = true
//
//        }
//        else{
//           self.postDetailsLabel.isHidden = false
//             self.postDetailsLabel.attributedText = Helper.makeAttributedString(title: socialModel?.title ?? "", font: Utility.Font.Bold.ofSize(14))
//        }
        
        let title = socialModel?.title
                    if title?.count ?? 0 > 60 {
                         
//                         self.readMoreBtnOutlet.isHidden = false
             //            self.readMoreBtnOutlet.setTitle(" view more", for: .normal)
                         
                         self.postDetailsLabel.numberOfLines = 0
                     }else {
//                         self.readMoreBtnOutlet.isHidden = true
                         self.postDetailsLabel.numberOfLines = 2
                     }
        
        if socialModel?.categoryName == ""{
            self.categoryContainer.isHidden = true
        }else{
            /*
             Bug Name :- Remove category from home page
             Fix Date :- 20/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Hiding category UI.
             */
            self.categoryContainer.isHidden = true
            self.categoryNameOutlet.text  =  socialModel?.categoryName
        }
        
        
        if let businessPostType = socialModel?.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
            self.businessPostBtn.isHidden = false
            /* Bug Name : Add business button color
             Fix Date : 05-May-2021
             Fixed By : Jayaram G
             Description Of Fix : Added dynamic border color for
             */
            
            /* Bug Name : improve business post button
             Fix Date : 05-May-2021
             Fixed By : Jayaram G
             Description Of Fix : changed business button ui , removed old ui
             */
//            self.businessPostBtn.semanticContentAttribute = UIApplication.shared
//                .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
            if let color = socialModel?.businessProfileObj?.businessButtonColor{
                self.businessPostBtn.makeBorderWidth(width: 2, color: Helper.hexStringToUIColor(hex: color))
            }else{
                self.businessPostBtn.makeBorderWidth(width: 2, color: Helper.hexStringToUIColor(hex: "#18F8DF"))
            }
            let businessPrice = socialModel?.businessProfileObj?.businessPrice
            if businessPrice == nil {
                self.businessPostBtn.setTitle("\(socialModel?.businessProfileObj?.businessButtonText?.localized ?? "") ", for: .normal)
            }else {
                self.businessPostBtn.setTitle(" \(socialModel?.businessProfileObj?.businessButtonText?.localized ?? "")" + " @ \(socialModel?.businessProfileObj?.businessCurrencySymbol ?? "")\(businessPrice ?? 0) ", for: .normal)
            }
        }else{
            self.businessPostBtn.isHidden = true
        }
        
    
        self.setUserDetailsView(mediaType: socialModel?.mediaType)
    }
    
    func setFollowingUserStatus(){
        if let channelName = socialModel?.channelName, channelName == "" {
            if let userId = socialModel?.userId, let list = newFollowersList,list.contains(userId) || (socialModel?.isFollowing) ?? false,let removeList = removeFollowersList,!removeList.contains(userId)  {
                self.followButtonOutlet.isSelected = true
                self.followBtnOutlet.isHidden = true
                self.followingBtnOutlet.isHidden = false
            }else{
                self.followButtonOutlet.isSelected = false
                self.followBtnOutlet.isHidden = false
                self.followingBtnOutlet.isHidden = true
            }}else {
                if socialModel?.isSubscribed == 1 || profileChannelModel?.isSubscribed == 1 || (socialModel?.isFollowing) ?? false {
                    self.followBtnOutlet.isHidden = true
                    self.followingBtnOutlet.isHidden = false
                    self.followButtonOutlet.isSelected = true
                }else{
                    self.followButtonOutlet.isSelected = false
                    self.followBtnOutlet.isHidden = false
                    self.followingBtnOutlet.isHidden = true
                }
            }
        
        if let memberId = self.socialModel?.userId, let userId = Utility.getUserid(){
            if memberId == userId{
                self.sendTipView.isHidden = true
                self.followButtonOutlet.isHidden = true
                self.followingBtnOutlet.isHidden = true
            }else{
                self.sendTipView.isHidden = false
                self.followButtonOutlet.isHidden = false
               if self.socialModel?.isFollowing == true {
                    self.followBtnOutlet.isHidden = true
                    self.followingBtnOutlet.isHidden = false
               }else{
                self.followBtnOutlet.isHidden = false
                self.followingBtnOutlet.isHidden = true
               }
                
                
            }
        }else{
            self.followButtonOutlet.isHidden = false
            self.followBtnOutlet.isHidden = false
            self.followingBtnOutlet.isHidden = true
        }
    }
    
    /// To set user details and there heights according media type
    ///
    /// - Parameter mediaType: media type 0 for image and 1 for video
    private func setUserDetailsView(mediaType: Int?){
        if mediaType == 1, let mediaModel = self.socialModel?.mediaData,mediaModel.name?.count ?? 0 > 0{
            /*
             Bug Name :- if i don’t tag a song etc the whole profile pic etc should move down a bit Dynamically this must happen Does not show for this post But shows for this post
             Fix Date :- 13/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Handling music view height
             */
            
            /*
            Bug Name : can we increase the of three rotating circle a bit more like on triller
            Fix Date : 14-May-2021
            Fixed By : Jayaram G
            Description Of Fix : increased bottom space
          */
            self.musicViewHeightConstraint.constant = 42
            /*
             Bug Name :- should be able to click on rotating inage to open videos with that sound
             Fix Date :- 15/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added musice subview height constraint and handling
             */
            self.musicSubViewheightConstraint.constant = 22
              self.musicView.isHidden = false
            var font = Utility.DublyFont.BoldItalic.ofSize(14)
            var attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
            let userName = NSMutableAttributedString(string: mediaModel.name!, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
            font = Utility.DublyFont.LightItalic.ofSize(15)
            attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
            let comment = NSMutableAttributedString(string: mediaModel.artist, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
            let attrString = NSMutableAttributedString(string: " by ", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
            self.musicNameLabel.attributedText = userName + attrString + comment

            print("music image ")
            let image = UIImage(named: "music-symbol")!
            print("***** music image \(mediaModel.imageUrl)")
            self.musicImageView.setImageOn(imageUrl: mediaModel.imageUrl, defaultImage: image)
            /* Bug Name : Add gif for music
             Fix Date : 22-Apr-2021
             Fixed By : Jayaram G
             Description Of Fix : Loading gif for music
             */
            self.floatingMusicImageView.loadGif(name: "music")
            self.musicImageView.startRotating()
        }else{
            self.musicView.isHidden = true
            /*
             Bug Name :- should be able to click on rotating inage to open videos with that sound
             Fix Date :- 15/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added musice subview height constraint and handling
             */
            self.musicSubViewheightConstraint.constant = 0
            /*
             Bug Name :- if i don’t tag a song etc the whole profile pic etc should move down a bit Dynamically this must happen Does not show for this post But shows for this post
             Fix Date :- 13/05/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Handling music view height
             */
            self.musicViewHeightConstraint.constant = 0
        }
        self.layoutIfNeeded()
        //  self.makeGradientColorForUserAndTopView()
    }
    
    override func prepareForReuse() {
        self.postImageView.image = nil
        self.thumbnailImageView.image = nil
    }
    
    
    
    func showViewBookMark(socialModel: SocialModel,collectionModel: SavedCollectionModel){
        self.savedViewPostsButtonOutlet.setTitle("Saved to".localized + " \(collectionModel.collectionName ?? "")", for: .normal)
        UIView.animate(withDuration: 0.3, animations: {
            self.savedViewPostsHeightConstraint.constant = 50
            self.layoutIfNeeded()
        }) { (isFinishedSuccessfully) in
            if isFinishedSuccessfully{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        DispatchQueue.main.async {
                            self.savedViewPostsHeightConstraint.constant = 0
                        }
                        self.layoutIfNeeded()
                    }){ (isFinishedSuccessfully) in
                    }
                })
            }
        }
    }
    
    
    //MARK:- Buttons Action
    
    @IBAction func unlockPostAction(_ sender: UIButton) {
        delegate?.forYoupaidPostTap(isFromTrending: self.isTrending, index: index, isXclusive: self.isXclusive)

    }
    
    @IBAction func subscribeUserBtnAction(_ sender: Any) {
        delegate?.forYounavigateToConfirmSubscriptionVc(isFromTrending: self.isTrending, index: index, isXclusive: self.isXclusive)
    }
    
    
    
    
    @IBAction func showMediaButtonAction(_ sender: Any) {
        self.delegate?.showMediaOptions()
    }
    @IBAction func sendTipBtnAction(_ sender: UIButton) {
        self.delegate?.sendTipAction(isFromTrending: self.isTrending, index: self.index, isXclusive: self.isXclusive)
    }
    
    @IBAction func muteBtnAction(_ sender: Any) {
        self.delegate?.muteAudio(isFromTrending: self.isTrending, isXclusive: self.isXclusive)
    }
    
    @IBAction func likeButtonAction(_ sender: Any) {
         if let status = Utility.getIsGuestUser() , !status {
        if socialModel?.liked == 1{
            delegate?.forYoulikeButtonTap(index: self.index, isSelected: true, isFromTrending: isTrending, isXclusive: self.isXclusive )
            socialModel?.liked = 0
            socialModel?.likesCount = (socialModel?.likesCount)! - 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_off.dubly"), view: self.likeImageView)
        }else{
            delegate?.forYoulikeButtonTap(index: self.index, isSelected: false, isFromTrending: isTrending, isXclusive: self.isXclusive)
            socialModel?.liked = 1
            socialModel?.likesCount = (socialModel?.likesCount)! + 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
        }
        if let data = socialModel{
            self.likeCountButtonOutlet.setTitle("\(String(describing: data.likesCount))", for: UIControl.State.normal)
        }
        }
         else{
            self.presentWelcomeController()
        }
    }
    
    /*
     Bug Name :- read more , read less
     Fix Date :- 26/04/2021
     Fixed By :- Jayaram G
     Description Of Fix :- Added read more/less action
     */
//    @IBAction func readMoreBtnAction(_ sender: UIButton){
//            print(self.socialModel!.isExpand)
//            if self.socialModel!.isExpand {
//                self.socialModel!.isExpand = false
//                self.delegate?.forYouviewmoreTapped(isViewed: false, index: self.index)
//            }else{
//                self.delegate?.forYouviewmoreTapped(isViewed: true, index: self.index)
//                self.socialModel!.isExpand = true
//            }
//
//        let readmoreFont = UIFont(name: "Poppins-Bold", size: 17)
//            let readmoreFontColor = UIColor.blue
//    //        self.fullText = getText(fullText: socialModel!.title ?? "")
//            self.postDetailsLabel.text = expandOrCollapse()
////            self.delegate?.forYoureloadTableView(index: self.index)
//            self.reloadInputViews()
//        }
    
    @IBAction func channelButtonAction(_ sender: UIButton) {
        delegate?.forYouchannelButtonTapped(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
        
    }
    

    
        /// To handle single tap
       ///
       /// - Parameter gesture: tap gesture
    @objc func singleTapHandle(_ gesture: UITapGestureRecognizer){
           print("single tapped")
                    if socialModel?.mediaType == 1 && !self.isUrlTapped{
                        delegate?.forYousingleTapOnCell(isFromTrending: isTrending, isXclusive: self.isXclusive)
            }else{
                self.isUrlTapped = false
            }
       }
    

    @IBAction func businessPostButtonAction(_ sender: UIButton) {
        if let businessProductUrl = socialModel?.businessProfileObj?.businessUrl {
            delegate?.forYouopenBusinessProductLink(productUrlStr: businessProductUrl, title: socialModel?.title ?? "", isFromTrending: isTrending, isXclusive: self.isXclusive)
        }
    }
    
    @IBAction func likeCountAction(_ sender: Any) {
        delegate?.forYoulikeCountButtonTap(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    
    @IBAction func commentButtonAction(_ sender: Any) {
        delegate?.forYoucommentButtonTap(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    @IBAction func viewCountAction(_ sender: Any) {
        if let count = socialModel?.distinctView{
            delegate?.forYouviewCountButtonTap(index: index, isFromTrending: isTrending, isXclusive: self.isXclusive)
        }
    }
    
    
    
    @IBAction func shareButtonAction(_ sender: Any) {
        delegate?.forYoushareButtonTap(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    
    @IBAction func profileButtonAction(_ sender: Any) {
        delegate?.forYouprofileImageViewTap(index: index, userName: nil, isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        delegate?.forYoucategoryButtonTap(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    @IBAction func musicButtonaction(_ sender: Any) {
        delegate?.forYoumusicButtonTap(index: index,isFromTrending: isTrending, isXclusive: self.isXclusive)
    }
    
    @IBAction func postLocationAction(_ sender: Any) {
        if let status = Utility.getIsGuestUser() , !status {
            guard let place = socialModel?.place else{return}
            if place != ""{
                delegate?.forYoulocationButtonTap(index: index)
            }
        }else {
            presentWelcomeController()
        }
    }
    
    
    @IBAction func showSavedPostsBtnAction(_ sender: UIButton) {
        // delegate?.viewCollection()
    }
    
    @IBAction func moveToCollections(_ sender: UIButton) {
        delegate?.forYoumoveToCOllections(isFromTrending:isTrending, isXclusive: self.isXclusive)
    }
    
    
    @IBAction func followUserAction(_ sender: Any) {
        if let status = Utility.getIsGuestUser() , !status {
            if let channelId = socialModel?.channelId, channelId == "" {
                if let userId = socialModel?.userId, let list = newFollowersList,list.contains(userId) || (socialModel?.isFollowing) ?? false,let removeList = removeFollowersList,!removeList.contains(userId){
                    delegate?.forYoufollowUserButtonTap(index: index, isSelected: true, isFromTrending: isTrending, isXclusive: self.isXclusive)
                    socialModel?.isFollowing = false
                    self.followButtonOutlet.isSelected = false
                    self.followBtnOutlet.isHidden = false
                    self.followingBtnOutlet.isHidden = true
                }else{
                    delegate?.forYoufollowUserButtonTap(index: self.index, isSelected: false, isFromTrending: isTrending, isXclusive: self.isXclusive)
                    socialModel?.isFollowing = true
                    self.followButtonOutlet.isSelected = true
                    self.followBtnOutlet.isHidden = true
                    self.followingBtnOutlet.isHidden = false

                }
            }else  if let channelId = self.socialModel?.channelId  {
                    if self.socialModel?.isSubscribed == 0 || profileChannelModel?.isSubscribed == 0{
                        delegate?.forYousubscriberUserButton(index: index, isSelected: true, channelId: channelId)
                        self.socialModel?.isSubscribed = 1
                        profileChannelModel?.isSubscribed = 1
                        self.followButtonOutlet.isSelected = false
                        self.followBtnOutlet.isHidden = false
                        self.followingBtnOutlet.isHidden = true
                    }else{
                        delegate?.forYousubscriberUserButton(index: self.index, isSelected: false, channelId: channelId)
                        self.socialModel?.isSubscribed = 0
                        profileChannelModel?.isSubscribed = 0
                        self.followButtonOutlet.isSelected = true
                        self.followBtnOutlet.isHidden = true
                        self.followingBtnOutlet.isHidden = false
                    }
                }
            
        }else {
            presentWelcomeController()
        }
        
    }
    
    
    @IBAction func saveToCollectionBtnAction(_ sender: UIButton) {
        delegate?.forYousaveToCollectionAction(isFromTrending:isTrending, isXclusive: self.isXclusive)
    }
    
    
    @IBAction func bookMarkAction(_ sender: UIButton) {
        if let status = Utility.getIsGuestUser() , !status {
            if !(socialModel?.isBookMarked)! {
                model.addBookmark(socialModel?.postId ?? "")
                model.didUpdateDict = { response in
                    self.delegate?.forYouupdateBookMarkData(index: self.index, isSelected: true, isFromTrending: self.isTrending, isXclusive: self.isXclusive)
                    sender.isSelected = true
                    self.socialModel?.isBookMarked = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.saveToCollectionViewHeightConstraint.constant = 45
                        self.layoutIfNeeded()
                    }) { (isFinishedSuccessfully) in
                        if isFinishedSuccessfully{
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                                UIView.animate(withDuration: 0.3, animations: {
                                    self.saveToCollectionViewHeightConstraint.constant = 0
                                    self.layoutIfNeeded()
                                }){ (isFinishedSuccessfully) in
                                }
                            })
                        }
                    }
                }
                model.didError = { error in
                }
            }else{
                self.model.removeBookmark(self.socialModel?.postId ?? "")
                self.model.didUpdateDict = { response in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                    self.delegate?.forYouupdateBookMarkData(index: self.index, isSelected: false,isFromTrending: self.isTrending, isXclusive: self.isXclusive)
                    sender.isSelected = false
                    self.socialModel?.isBookMarked = false
                }
                self.model.didError = { error in
                    
                }
                
            }
        }else {
            presentWelcomeController()
        }
    }
    
    func presentWelcomeController() {
        let loginVC = LoginVC.instantiate(storyBoardName: "Authentication") as LoginVC
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.modalPresentationStyle = .overCurrentContext
        loginVC.isFromHomeVC = true
        navVC.navigationBar.isHidden = true
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController!.present(navVC, animated: true, completion: nil)
    }
    
    func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        
        postDetailsLabel.frame.size.width = width
        postDetailsLabel.font = font
        postDetailsLabel.numberOfLines = 0
        postDetailsLabel.text = text
        postDetailsLabel.sizeToFit()
        
        
        return postDetailsLabel.frame.size.height
    }
    
    
    
    
    //MARK:- swipe gesture delegate
    /// To switch to home and foryou
    ///
    /// - Parameter gesture: swipe gesture
    @objc func swipeGestureHandle(_ gesture: UISwipeGestureRecognizer){
        self.delegate?.switchFollowingAndForYou(isFromTrending: self.isTrending, isXclusive: self.isXclusive, gesture: gesture)
    }
    
    
    /*
     Bug Name:- Handle swipe for three tabs
     Fix Date:- 04/05/2021
     Fixed By:- Jayaram
     Description of Fix:- Added swipe for exclusive posts
     */
    //MARK:- swipe gesture delegate
    /// To switch to forYou and xclusive
    ///
    /// - Parameter gesture: swipe gesture
    @objc func swipeGestureHandleForYouPosts(_ gesture: UISwipeGestureRecognizer){
        self.delegate?.switchFollowingAndForYou(isFromTrending: self.isTrending, isXclusive: self.isXclusive, gesture: gesture)
    }
    
    
    //MARK:- tap gesture delegate
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func doubleTapHandle(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
            if let status = Utility.getIsGuestUser() , !status , let data = socialModel{
                if data.liked == nil  || data.liked == 0 {
                    delegate?.forYoulikeButtonTap(index: self.index, isSelected: false, isFromTrending: isTrending, isXclusive: self.isXclusive)
                socialModel?.likesCount = (socialModel?.likesCount)! + 1
                socialModel?.liked = 1
                self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
                self.likeCountButtonOutlet.setTitle("\(socialModel?.likesCount ?? 0)", for: UIControl.State.normal)
                }
            
            self.bigLikeImageView.popUpDoubletapFavouritAnimation()
        }
            else{
                self.presentWelcomeController()
        }
    }
}


extension HomeFeedCollectionViewCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.postImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.postImageScrollView.zoomScale = 1.0
    }
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}


