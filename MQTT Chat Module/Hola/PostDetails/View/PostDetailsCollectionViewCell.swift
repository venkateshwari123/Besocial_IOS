//
//  PostDetailsCollectionViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 28/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol PostDetailsCollectionViewCellDelegate: class {
    func likeButtonTap(index: Int, isSelected: Bool)
    func likeCountButtonTap(index: Int)
    func commentButtonTap(index: Int)
    func viewCountButtonTap(index: Int)
    func shareButtonTap(index: Int)
    func profileImageViewTap(index: Int, userName: String?)
    func singleTapOnCell(index: Int)
    func categoryButtonTap(index: Int)
    func musicButtonTap(index: Int)
    func locationButtonTap(index: Int)
    func followUserButtonTap(index: Int, isSelected: Bool)
    func hashtagTextTapped(index: Int, hashTag: String)
    func channelButtonTapped(index: Int)
    func openBusinessProductLink(productUrlStr:String,title:String)
    func subscriberUserButton(index: Int, isSelected: Bool,channelId : String)
    func saveToCollectionAction()
    func viewCollection()
    func moveToCOllections()
}

class PostDetailsCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var saveToCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveToCollectionView: UIView!
    @IBOutlet weak var postImageScrollView: UIScrollView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    //    @IBOutlet weak var likeCountLable: UILabel!
    @IBOutlet weak var dividingView: UIView!
    @IBOutlet weak var savedViewPostOutlet: UIView!
    
    @IBOutlet weak var savedViewPostsButtonOutlet: UIButton!
    
    @IBOutlet weak var savedViewPostsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bookMarkBtnOutlet: UIButton!
    
    @IBOutlet weak var saveToCollectionBtnOutlet: UIButton!
    
    
    @IBOutlet weak var likeCountButtonOutlet: UIButton!
    
    @IBOutlet weak var businessButtonText: UILabel!
    @IBOutlet weak var businessProductPrice: UILabel!
    @IBOutlet weak var businessPostView: UIView!
    @IBOutlet weak var channelButtonOutlet: UIButton!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentCountLable: UILabel!
    @IBOutlet weak var viewImageView: UIImageView!
    //    @IBOutlet weak var viewsCountlabel: UILabel!
    @IBOutlet weak var viewCountButtonOutlet: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var userDetailsView: UIView!
    @IBOutlet weak var userDetailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    @IBOutlet weak var followImageViewOutlet: UIImageView!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var postLocationButtonOutlet: UIButton!
    //    @IBOutlet weak var postDetailsLabel: UILabel!
    @IBOutlet weak var postDetailsLabel: KILabel!
    //    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryButtonOutlet: UIButton!
    @IBOutlet weak var musicViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var musicImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    
    @IBOutlet weak var categoryNameOutlet: UILabel!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var channelNameOutlet: UILabel!
    
    var postDetailsControllerObject:PostDetailsViewController? = nil
    var isUrlTapped: Bool = false
    var isDoneOnce: Bool = false
    
    var videoUrl: URL?
    var index: Int = 0
    var delegate: PostDetailsCollectionViewCellDelegate?
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var doubleTapGR : UITapGestureRecognizer? = nil
    var isLabelAtMaxHeight = false
    
    var socialModel: SocialModel?{
        didSet{
            self.setCellData()
        }
    }
    
    var profileChannelModel: ProfileChannelModel?{
        didSet{
            self.setChannelData()
        }
    }
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        //make corner radious for user and music image view
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        self.musicImageView.makeCornerRadious(readious: musicImageView.frame.size.width / 2)
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
        
        //Single tap gesture
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.likeImageView.makeShadowEffect(color: UIColor.darkGray)
            self.likeCountButtonOutlet.makeShadowEffect(color: UIColor.darkGray)
            self.commentImageView.makeShadowEffect(color: UIColor.darkGray)
            self.commentCountLable.makeShadowEffect(color: UIColor.darkGray)
            self.viewImageView.makeShadowEffect(color: UIColor.darkGray)
            self.viewCountButtonOutlet.makeShadowEffect(color: UIColor.darkGray)
            self.bookMarkBtnOutlet.makeShadowEffect(color: UIColor.darkGray)
            self.shareImageView.makeShadowEffect(color: UIColor.darkGray)
        }
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
    
    
    
    
   func setChannelData(){
        print(profileChannelModel)
    
    
    }
    
    /// To set all cell data according to media type
    func setCellData() {
        if socialModel?.mediaType == 1{
            if var url = socialModel?.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncated = url.substring(to: endIndex)
                self.videoUrl = URL(string: truncated + "mov")
                truncated = truncated + "jpg"
                self.postImageView.contentMode = UIView.ContentMode.scaleAspectFit
                if socialModel!.imageUrlWidth == socialModel!.imageUrlHeight{
                    //                    let width: Int = Int(self.frame.size.width)
                    //                    truncated = truncated.replace(target: "upload/", withString: "upload/w_\(width),h_\(width)/")
//                    self.postImageView.contentMode = UIView.ContentMode.scaleAspectFit
                }
                self.postImageView.kf.setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "Default logo"), options: [.transition(ImageTransition.fade(1))], progressBlock: nil, completionHandler: { (image, error, CacheType, url) in
//                    self.kf.indicator.stopAnimatingView()
                })
                DispatchQueue.main.async {
//                    if let presentIndex = self.postDetailsControllerObject?.currentIndex {
////                    self.postDetailsControllerObject?.playVideoOnTheCell(cell: self, indexPath: IndexPath(row: presentIndex, section: 0))
//                    }
                }
            }
        }else{
            self.postImageView.contentMode = UIView.ContentMode.scaleAspectFit
            self.postImageView.setImageOn(imageUrl: socialModel?.imageUrl, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
        }
        
        if let isBookMarked = socialModel?.isBookMarked {
            self.bookMarkBtnOutlet.isSelected  = isBookMarked
        }
        self.setFavouriteButtonsAndCounts()
        self.setUserDetails()
        self.linkHandler()
    }
    
     
    /// To handle link in description
    private func linkHandler(){
        postDetailsLabel.systemURLStyle = true;
         // Attach block for handling taps on usenames
        self.postDetailsLabel.userHandleLinkTapHandler = { (label, string, range) in
            print(string)
            self.isUrlTapped = true
            self.delegate?.profileImageViewTap(index: self.index, userName: string)
        }
        
        postDetailsLabel.hashtagLinkTapHandler = { (label, string, range) in
            print(string)
            self.isUrlTapped = true
            self.delegate?.hashtagTextTapped(index: self.index, hashTag: string)
        }
        
        //        postDetailsLabel.urlLinkTapHandler = { (label, string, range) in
        //            print(string)
        //            self.isUrlTapped = true
        //
        //        }
    }
    
    /// to set buttons and there counts
    private func setFavouriteButtonsAndCounts(){
        if let data = socialModel {
            if data.liked == 0{
                self.likeImageView.image = UIImage(named: "like_off")
            }else{
                self.likeImageView.image = UIImage(named: "like_on")
            }
            self.likeCountButtonOutlet.setTitle("\(String(describing: data.likesCount))", for: UIControl.State.normal)
            self.commentCountLable.text = "\(String(describing: data.commentCount))"
            self.viewCountButtonOutlet.setTitle("\(String(describing: data.distinctView))", for: UIControl.State.normal)
        }
    }
    
    /// To set user details
    private func setUserDetails(){
        print(socialModel?.isSubscribed)
         self.postLocationButtonOutlet.setTitle(socialModel?.place, for: .normal)
        if let channelName = socialModel?.channelName, channelName == "" {
            if let businessPostType = socialModel?.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
                self.userNamelabel.text = socialModel?.businessProfileObj?.businessName
                Helper.addedUserImage(profilePic: socialModel?.businessProfileObj?.businessProfilePic, imageView: self.userImageView, fullName: socialModel?.businessProfileObj?.businessName ?? "P")
            }else {
                self.userNamelabel.text = socialModel?.userName
                /*
                 Bug Name:- Show the intials for default profile pic
                 Fix Date:- 17/05/21
                 Fix By  :- Jayram G
                 Description of Fix:- setting initials image when user not uploaded profile pic
                 */
                Helper.addedUserImage(profilePic: socialModel?.profilePic, imageView: self.userImageView, fullName: socialModel?.fullNameWithSpace ?? "D")
            }

            }else{
            self.userNamelabel.text = socialModel?.channelName
                Helper.addedUserImage(profilePic: socialModel?.channelImageUrl, imageView: self.userImageView, fullName: socialModel?.channelName ?? "P")
        }
        
//        let postMainTitleString = socialModel?.title
//        let readMoreSubString = " ... Readmore"
//        let titleSubString = postMainTitleString?.prefix(45)
//        let font1 = UIFont(name: "CenturyGothic-Bold", size: 15.0)!
//        let attributed1 = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font1]
//        let attributeReadMoreString = NSMutableAttributedString(string: readMoreSubString, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed1))
//
//        let font2 = Utility.Font.Regular.ofSize(15)
//        let attributed2 = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font2]
//        let attributetitleSubString = NSMutableAttributedString(string: "\(titleSubString!)", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed2))
//       // attributetitleSubString.append(attributeReadMoreString)
//        self.postLocationButtonOutlet.setTitle(socialModel?.place, for: .normal)
//        self.postDetailsLabel.numberOfLines = 0
//        if (socialModel?.title!.count)! > 50 {
//            self.postDetailsLabel.attributedText = attributetitleSubString + attributeReadMoreString
//            self.postDetailsLabel.sizeToFit()
//         }else {
//            self.postDetailsLabel.text = socialModel?.title
//        }
//
        
        self.postDetailsLabel.text = socialModel?.title
        if socialModel?.categoryName == ""{
            self.categoryButtonOutlet.isHidden = true
        }else{
            self.categoryButtonOutlet.isHidden = false
            self.categoryNameOutlet.text  =  socialModel?.categoryName
        }
        
        if socialModel?.categoryName == "" || socialModel?.channelName == ""{
            self.dividingView.isHidden = true
        }else{
            self.dividingView.isHidden = false
        }
        
        if socialModel?.channelName == ""{
            self.channelButtonOutlet.isHidden = true
        }else{
            self.channelButtonOutlet.isHidden = false
            self.channelNameOutlet.text = socialModel?.channelName
        }
        
        
        if let businessPostType = socialModel?.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
            self.businessPostView.isHidden = false
            if let color = socialModel?.businessProfileObj?.businessButtonColor{
                self.businessPostView.backgroundColor = Helper.hexStringToUIColor(hex: color)
            }else{
                self.businessPostView.backgroundColor = UIColor.clear
            }
            self.businessButtonText.text = socialModel?.businessProfileObj?.businessButtonText
            let businessPrice = socialModel?.businessProfileObj?.businessPrice
            if businessPrice == nil {
                self.businessProductPrice.text = ""
            }else {
                self.businessProductPrice.text = "\(socialModel?.businessProfileObj?.businessCurrency ?? "")"+" "+"\(String(describing: businessPrice!))"
            }
        }else{
            self.businessPostView.isHidden = true
        }
        
        if let channelName = socialModel?.channelName, channelName == "" {
            if (socialModel?.isFollowing) ?? false{
                self.followButtonOutlet.isSelected = true
                followImageViewOutlet.image = UIImage(named: "check_icon")
            }else{
                self.followButtonOutlet.isSelected = false
                followImageViewOutlet.image = UIImage(named: "add_image")
            }}else {
            if socialModel?.isSubscribed == 1 || profileChannelModel?.isSubscribed == 1{
                self.followButtonOutlet.isSelected = true
                followImageViewOutlet.image = UIImage(named: "check_icon")
            }else{
                self.followButtonOutlet.isSelected = false
                followImageViewOutlet.image = UIImage(named: "add_image")
            }
        }
        
        if let memberId = self.socialModel?.userId, let userId = Utility.getUserid(){
            if memberId == userId{
                self.followButtonOutlet.isHidden = true
                self.followImageViewOutlet.isHidden = true
            }else{
                self.followButtonOutlet.isHidden = false
                self.followImageViewOutlet.isHidden = false
            }
        }else{
            self.followButtonOutlet.isHidden = false
            self.followImageViewOutlet.isHidden = false
        }
        self.setUserDetailsView(mediaType: socialModel?.mediaType)
    }
    
    
    /// To set user details and there heights according media type
    ///
    /// - Parameter mediaType: media type 0 for image and 1 for video
    private func setUserDetailsView(mediaType: Int?){
        if mediaType == 1, let mediaModel = self.socialModel?.mediaData{
            self.musicNameLabel.text = mediaModel.name
            let image = UIImage(named: "music-symbol")!
            self.musicImageView.setImageOn(imageUrl: mediaModel.imageUrl, defaultImage: image)
            self.musicViewHeightConstraint.constant = 27.0
        }else{
            self.musicNameLabel.text = ""
            self.musicImageView.image = nil
            self.musicViewHeightConstraint.constant = 0.0
        }
        if let postData = socialModel, let title = postData.title{
            let width = self.frame.size.width - 20
            let height = title.height(withConstrainedWidth: width, font: self.postDetailsLabel.font)
            if height <= 18{
                // self.userDetailsHeightConstraint.constant = 135
            }else{
                // self.userDetailsHeightConstraint.constant = 112 + height
            }
        }
        self.layoutIfNeeded()
        self.makeGradientColorForUserAndTopView()
    }
    
    override func prepareForReuse() {
        self.postImageView.image = nil
    }
    
    
    
    func showViewBookMark(socialModel: SocialModel,collectionModel: SavedCollectionModel){
        self.savedViewPostsButtonOutlet.setTitle("Saved to \(collectionModel.collectionName ?? "")", for: .normal)
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
    
    @IBAction func likeButtonAction(_ sender: Any) {
        
        if socialModel?.liked == 1{
            delegate?.likeButtonTap(index: self.index, isSelected: true)
            socialModel?.liked = 0
            socialModel?.likesCount = (socialModel?.likesCount)! - 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_off"), view: self.likeImageView)
        }else{
            delegate?.likeButtonTap(index: self.index, isSelected: false)
            socialModel?.liked = 1
            socialModel?.likesCount = (socialModel?.likesCount)! + 1
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
        }
        if let data = socialModel{
            self.likeCountButtonOutlet.setTitle("\(String(describing: data.likesCount))", for: UIControl.State.normal)
        }
    }
    
    @IBAction func channelButtonAction(_ sender: UIButton) {
        delegate?.channelButtonTapped(index: index)
        
    }
    
    
//    @IBAction func readMoreBtnAction(_ sender: UIButton) {
//        if isLabelAtMaxHeight {
//            readMoreBtnOutlet.setTitle("Read more", for: .normal)
//            isLabelAtMaxHeight = false
//            postDetailsLabel.numberOfLines = 2
//            postTitleLabelHeightConstraint.constant = 50
//            postDetailsLabel.sizeToFit()
//
//        }
//        else {
//            readMoreBtnOutlet.setTitle("Read less", for: .normal)
//            isLabelAtMaxHeight = true
//            postTitleLabelHeightConstraint.constant = getLabelHeight(text: socialModel!.title!, width: UIScreen.main.bounds.width, font: Utility.Font.Regular.ofSize(15))
//            self.layoutIfNeeded()
//        }
//    }
//
    
    @IBAction func businessPostButtonAction(_ sender: UIButton) {
        if let businessProductUrl = socialModel?.businessProfileObj?.businessUrl {
            delegate?.openBusinessProductLink(productUrlStr: businessProductUrl, title: socialModel?.title ?? "")
        }
    }
    
    @IBAction func likeCountAction(_ sender: Any) {
        if let count = socialModel?.likesCount{
            delegate?.likeCountButtonTap(index: index)
        }
    }
    
    
    @IBAction func commentButtonAction(_ sender: Any) {
        delegate?.commentButtonTap(index: index)
    }
    
    @IBAction func viewCountAction(_ sender: Any) {
        if let count = socialModel?.distinctView{
            delegate?.viewCountButtonTap(index: index)
        }
    }
    
    
    @IBAction func shareButtonAction(_ sender: Any) {
        delegate?.shareButtonTap(index: index)
    }
    
    
    @IBAction func profileButtonAction(_ sender: Any) {
        delegate?.profileImageViewTap(index: index, userName: nil)
    }
    
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        delegate?.categoryButtonTap(index: index)
    }
    
    @IBAction func musicButtonaction(_ sender: Any) {
        delegate?.musicButtonTap(index: index)
    }
    
    @IBAction func postLocationAction(_ sender: Any) {
        guard let place = socialModel?.place else{return}
        if place != ""{
            delegate?.locationButtonTap(index: index)
        }
    }
    
    
    @IBAction func showSavedPostsBtnAction(_ sender: UIButton) {
        // delegate?.viewCollection()
    }
    
    @IBAction func moveToCollections(_ sender: UIButton) {
        delegate?.moveToCOllections()
    }
    
    
    @IBAction func followUserAction(_ sender: Any) {
        if let channelName = socialModel?.channelName, channelName == "" {
            if (socialModel?.isFollowing)!{
                delegate?.followUserButtonTap(index: index, isSelected: true)
                socialModel?.isFollowing = false
                self.followButtonOutlet.isSelected = false
                self.followImageViewOutlet.singleTapLikeButtonAnimation(changeImage: UIImage(named: "add_image")!, view: self.followImageViewOutlet)
            }else{
                delegate?.followUserButtonTap(index: self.index, isSelected: false)
                socialModel?.isFollowing = true
                self.followButtonOutlet.isSelected = true
                self.followImageViewOutlet.singleTapLikeButtonAnimation(changeImage: UIImage(named: "check_icon")!, view: self.followImageViewOutlet)
            }
        }else {
            if self.socialModel?.isSubscribed == 0 || profileChannelModel?.isSubscribed == 0{
                delegate?.subscriberUserButton(index: index, isSelected: true, channelId: self.profileChannelModel?.channelId ?? "")
               self.socialModel?.isSubscribed = 1
                profileChannelModel?.isSubscribed = 1
                self.followButtonOutlet.isSelected = false
                 followImageViewOutlet.image = UIImage(named: "check_icon")
                self.followImageViewOutlet.singleTapLikeButtonAnimation(changeImage: UIImage(named: "check_icon")!, view: self.followImageViewOutlet)
            }else{
                delegate?.subscriberUserButton(index: self.index, isSelected: false, channelId: profileChannelModel?.channelId ?? "")
                self.socialModel?.isSubscribed = 0
                profileChannelModel?.isSubscribed = 0
                self.followButtonOutlet.isSelected = true
                 followImageViewOutlet.image = UIImage(named: "add_image")
                self.followImageViewOutlet.singleTapLikeButtonAnimation(changeImage: UIImage(named: "add_image")!, view: self.followImageViewOutlet)
            }
        }
        
        
        
    }
    
    
    @IBAction func saveToCollectionBtnAction(_ sender: UIButton) {
        delegate?.saveToCollectionAction()
    }
    
    
    @IBAction func bookMarkAction(_ sender: UIButton) {
        if !(socialModel?.isBookMarked)! {
            model.addBookmark(socialModel?.postId ?? "")
            model.didUpdateDict = { response in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
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
                sender.isSelected = false
                self.socialModel?.isBookMarked = false
            }
            self.model.didError = { error in
                
            }
            //            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            //
            //            alert.addAction(UIAlertAction(title: "Removing this will also remove it from all collections", style: .default , handler:{ (UIAlertAction)in
            //
            //            }))
            //
            //            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            //                print("User click Dismiss button")
            //            }))
            //
            //            self.parentViewController!.present(alert, animated: true, completion: {
            //                print("completion block")
            //            })
            
        }
    }
    
    
    func getLabelHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        
        postDetailsLabel.frame.size.width = width
        postDetailsLabel.font = font
        postDetailsLabel.numberOfLines = 0
        postDetailsLabel.text = text
        postDetailsLabel.sizeToFit()
        
        
        return postDetailsLabel.frame.size.height
    }
    
    
    
    //MARK:- tap gesture delegate
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    @objc func doubleTapHandle(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
        if let data = socialModel{
            if data.liked == 0{
                delegate?.likeButtonTap(index: self.index, isSelected: false)
                socialModel?.likesCount = (socialModel?.likesCount)! + 1
                socialModel?.liked = 1
                self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
                //                self.likeCountLable.text = "\(String(describing: data.likesCount!))"
                self.likeCountButtonOutlet.setTitle("\(socialModel?.likesCount ?? 0)", for: UIControl.State.normal)
            }
            //            self.bigLikeImageView.isHidden = false
            self.bigLikeImageView.popUpDoubletapFavouritAnimation()
        }
    }
    

}


extension PostDetailsCollectionViewCell: UIScrollViewDelegate{
    
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
