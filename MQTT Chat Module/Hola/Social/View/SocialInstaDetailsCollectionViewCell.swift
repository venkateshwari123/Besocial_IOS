//
//  SocialInstaDetailsCollectionViewCell.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 27/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//
protocol SocialInstaDetailsCollectionViewCellDelegate {
    func likeButtonTap(index: Int, isSelected: Bool, socialModel: SocialModel,FromDoubleTap: Bool)
    func commentButtonTap(index: Int)
    func shareInChatButtonTap(index: Int)
//    func shareThroughDeepLinkButtonTap(index: Int)
    func hastagOrProfileSelected(byTag: String)
    func likeCountButtonTap(index: Int)
    func viewCountButtonTap(index: Int)
    func lblCommentTap(userId:String)
    func openBookMark(index: Int)
    func sendTipAction(index: Int)
    func forYouviewmoreTapped(isViewed: Bool,index : Int)
}

import UIKit

class SocialInstaDetailsCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var btnBookmark: UIButton!
    
    

    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var muteUnmuteButtonOutlet: UIButton!
    
    @IBOutlet weak var sendTipView: UIView!
    @IBOutlet weak var viewCollectionsBtnOutlet: UIButton!
    
    @IBOutlet weak var viewCollectionHeightConstraintOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var postTitleLabel: ActiveLabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var firstCommentLabel: KILabel!
    @IBOutlet weak var firstCommentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var secondCommentLabel: KILabel!
    @IBOutlet weak var secondCommentHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewAllCommentsButton: UIButton!
    @IBOutlet weak var viewAllCommentheghtConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewAllCommentsLabelOutlet: UILabel!
    @IBOutlet weak var sendTipsLbl: UILabel!
    
    @IBOutlet weak var shareChatBtn: UIButton!
 
    var socialModel: SocialModel?
    var index: Int = 0
    var videoUrl: URL?
    var delegate: SocialInstaDetailsCollectionViewCellDelegate?
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var hasVideo = false
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
    
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendTipsLbl.text = "Send Tip".localized
        self.postTitleLabel.enabledTypes = [.hashtag,.mention,.url,readMoreType]
    }
    
    /// To set socila model data in in cell
    ///
    /// - Parameter socialModel: social model
    func setSocialCellData(socialModel: SocialModel){
        self.socialModel = socialModel        
        let time = Helper.getTimeStamp(timeStamp: socialModel.timeStamp ?? 0.0)
        let timeArr = time.components(separatedBy: " ")
        var postTimeString = ""
        for item in timeArr{
            postTimeString.append(item.localized + " ")
        }
        self.postTimeLabel.text = postTimeString
        if socialModel.liked == 1{
            self.likeImageView.image = UIImage(named: "like_on")
        }else{
            self.likeImageView.image = UIImage(named: "favourite_black")
        }
        if socialModel.userId == Utility.getUserid() {
            sendTipView.isHidden = true
        }else{
            sendTipView.isHidden = false
        }
        if socialModel.isPaid {
            self.btnBookmark.isHidden = true
            shareChatBtn.isHidden = true
        }else{
            self.btnBookmark.isHidden = false
            shareChatBtn.isHidden = false
        }
        if socialModel.title?.count ?? 0 > 60 {
            
            //                         self.readMoreBtnOutlet.isHidden = false
            //            self.readMoreBtnOutlet.setTitle(" view more", for: .normal)
            
            self.postTitleLabel.numberOfLines = 0
        }else {
            //                         self.readMoreBtnOutlet.isHidden = true
            self.postTitleLabel.numberOfLines = 2
        }
//        self.viewsCountLabel.text = "\(socialModel.distinctView) Views"
//        self.likesCountLabel.text = "Liked by \(socialModel.likesCount) people"
        self.linkHandler(socialModel: socialModel)
        self.makeAttributedStringForViewAndLike(socialModel: socialModel)
        self.setCommentsAndManageHeights(socialModel: socialModel)
    }
    
    
    func labelAction(){
       if self.socialModel!.isExpand {
           self.socialModel!.isExpand = false
           self.delegate?.forYouviewmoreTapped(isViewed: false, index: self.index)
       }else{
           self.delegate?.forYouviewmoreTapped(isViewed: true, index: self.index)
           self.socialModel!.isExpand = true
       }
       
       self.postTitleLabel.attributedText = expandOrCollapse()
       //            self.delegate?.forYoureloadTableView(index: self.index)
       self.reloadInputViews()
   }
    
    
    func showViewBookMark(socialModel: SocialModel,collectionModel: SavedCollectionModel){
        
        self.viewCollectionsBtnOutlet.setTitle("Saved to".localized + " \(collectionModel.collectionName ?? "")", for: .normal)
         UIView.animate(withDuration: 0.3, animations: {
            self.viewCollectionHeightConstraintOutlet.constant = 50
            self.layoutIfNeeded()
        }) { (isFinishedSuccessfully) in
            if isFinishedSuccessfully{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    UIView.animate(withDuration: 0.3, animations: {
                        DispatchQueue.main.async {
                        self.viewCollectionHeightConstraintOutlet.constant = 0
                        }
                        
                        self.layoutIfNeeded()
                    }){ (isFinishedSuccessfully) in
                    }
                })
            }
        }
    }
    
    
    
    
    /// To set post title and comments and these labels height
    ///
    /// - Parameter socialModel: post social model data
    func setCommentsAndManageHeights(socialModel: SocialModel){
        let width = self.frame.size.width - 20
        let postTitle = socialModel.title!
        self.postTitleLabel.attributedText = self.expandOrCollapse()
        let postTitleHeight = postTitle.height(withConstrainedWidth: width, font: self.postTitleLabel.font)
        var numberOfLine = ceil(postTitleHeight / 15)
        
        self.firstCommentLabel.text = ""
        self.secondCommentLabel.text = ""
//        self.viewAllCommentsButton.setTitle("", for: .normal)
        self.viewAllCommentsLabelOutlet.text = ""
        self.firstCommentHeightConstraint.constant = 0.0
        self.secondCommentHeightConstraint.constant = 0.0
        self.viewAllCommentheghtConstraint.constant = 0.0
        self.viewAllCommentsButton.isUserInteractionEnabled = false
        if socialModel.commentModelArray.count > 0{
            let commentArray = socialModel.commentModelArray
            let firstComment = commentArray[0].commentedBy! + "  " + commentArray[0].comment!
            self.makeFirstCommentLabel(modelData: commentArray[0])
            let firstCommentHeight = firstComment.height(withConstrainedWidth: width, font: self.firstCommentLabel.font)
            numberOfLine = ceil(firstCommentHeight / 15)
            self.firstCommentLabel.numberOfLines = Int(numberOfLine)
            self.firstCommentHeightConstraint.constant = firstCommentHeight
            if socialModel.commentModelArray.count > 1{
                let secondComment = commentArray[1].commentedBy! + "  " + commentArray[1].comment!
                let secondCommentHeight = secondComment.height(withConstrainedWidth: width, font: self.secondCommentLabel.font)
                self.makeSecondCommentLabel(modelData: commentArray[1])
                self.secondCommentHeightConstraint.constant = secondCommentHeight
                numberOfLine = ceil(secondCommentHeight / 15)
                self.secondCommentLabel.numberOfLines = Int(numberOfLine)
            }
            if socialModel.commentCount > 2{
//                self.viewAllCommentsButton.setTitle("View all \(socialModel.commentCount) comments", for: .normal)
                self.viewAllCommentsLabelOutlet.text = "View all".localized + " \(socialModel.commentCount) " + "comments".localized
                self.viewAllCommentsButton.isUserInteractionEnabled = true
                self.viewAllCommentheghtConstraint.constant = 15.0
            }
        }
        self.layoutIfNeeded()
    }
    
    
    func makeAttributedStringForViewAndLike(socialModel: SocialModel){
        var font = UIFont(name: "CenturyGothic-Bold", size: 12.0)!
        var attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let viewCount = NSMutableAttributedString(string: "\(socialModel.distinctView) ", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        let people = NSMutableAttributedString(string: "\(socialModel.likesCount ) " + "people".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        font = UIFont(name: "CenturyGothic", size: 12.0)!
        attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let views = NSMutableAttributedString(string: "Views".localized, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        let likedBy = NSMutableAttributedString(string: "Liked by".localized + " ", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        self.viewsCountLabel.attributedText = viewCount + views
        self.likesCountLabel.attributedText = likedBy + people
    }
    
    /// To make first comment with name and comment in attributed string
    ///
    /// - Parameter modelData: social model data
    func makeFirstCommentLabel(modelData: CommentModel){
        var font = UIFont(name: "CenturyGothic-Bold", size: 12.0)!
        var attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.label]
        let userName = NSMutableAttributedString(string: "\(modelData.commentedBy!) ", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        font = UIFont(name: "CenturyGothic", size: 12.0)!
        attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.label]
        let comment = NSMutableAttributedString(string: modelData.comment!, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        let combine = NSMutableAttributedString()
        combine.append(userName)
        combine.append(comment)
        self.firstCommentLabel.attributedText = combine
    }
    
    
    /// To make second comment with name and comment in attributed string
    ///
    /// - Parameter modelData: social model data
    func makeSecondCommentLabel(modelData: CommentModel){
        var font = UIFont(name: "CenturyGothic-Bold", size: 12.0)!
        var attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.label]
        let userName = NSMutableAttributedString(string: "\(modelData.commentedBy!) ", attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        font = UIFont(name: "CenturyGothic", size: 12.0)!
        attributed = [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.label]
        let comment = NSMutableAttributedString(string: modelData.comment!, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
         self.secondCommentLabel.attributedText = userName + comment
    }
    
    
    private func linkHandler(socialModel: SocialModel){
        postTitleLabel.customize { label in
            /*
             Bug Name :- hash tag and user tag is to be made bold white
             Fix Date :- 29/04/2021
             Fixed By :- Jayaram G
             Description Of Fix :- Added configureLinkAttribute for label
             */
            label.configureLinkAttribute = { (type, attributes, isSelected) in
                var atts = attributes
                print("title type", type)
                switch type {
                case .hashtag,.email,.mention,.url:
                    atts[NSAttributedString.Key.font] = Utility.Font.Bold.ofSize(12)
                    atts[NSAttributedString.Key.foregroundColor] = Utility.appColor() //UIColor.textBlackColor
                /*
                 Feat Name:- Readmore/Readless
                 Feat Date:- 23/05/21
                 Feat by  :- jayaram G
                 Discription of Feat:- added attributes for readmore/readless text
                 */
                case .custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized):
                    atts[NSAttributedString.Key.font] = Utility.Font.Bold.ofSize(12)
                    atts[NSAttributedString.Key.foregroundColor] = Utility.appColor()
                default: ()
                }
                return atts
            }
            
            self.truncatedText = getText(fullText: socialModel.title ?? "")
            label.attributedText = Helper.makeAttributedString(title: socialModel.title ?? "", font: UIFont.init(name: "CenturyGothic", size: 12.0)!)
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
                self.delegate?.hastagOrProfileSelected(byTag: "@" + $0)
            }
            
            label.handleHashtagTap {
                self.delegate?.hastagOrProfileSelected(byTag: "#" + $0)
            }
            /*
             Bug Name:- link not opening
             Fix Date:- 28/06/21
             Fix By  :- jayaram G
             Description of Fix:- Added url tap
             */
            label.handleURLTap { url in
                Helper.openUrl(string: url)
            }
        }
        
        
        firstCommentLabel.systemURLStyle = true
        
//        self.firstCommentLabel.addTapGestureRecognizer {
//            self.delegate?.lblCommentTap(userId: (self.socialModel?.commentModelArray.first?.commentedBy)!)
//        }
        /*
         Bug Name:- link not opening
         Fix Date:- 28/06/21
         Fix By  :- jayaram G
         Description of Fix:- Added url tap
         */
        self.firstCommentLabel.urlLinkTapHandler = { [weak self] (label, string, range) in
            Helper.openUrl(string: string.toURL())
        }
        self.firstCommentLabel.userHandleLinkTapHandler = { [weak self] (label, string, range) in
            print(string)
            self?.delegate?.hastagOrProfileSelected(byTag: string)
        }
        
        
        self.firstCommentLabel.hashtagLinkTapHandler = { (label, string, range) in
            print(string)
            self.delegate?.hastagOrProfileSelected(byTag: string)
        }
        
        
        
        secondCommentLabel.systemURLStyle = true
//        self.secondCommentLabel.addTapGestureRecognizer {
//            self.delegate?.lblCommentTap(userId: (self.socialModel?.commentModelArray.last?.commentedBy)!)
//        }
        
        
        self.secondCommentLabel.userHandleLinkTapHandler = { [weak self] (label, string, range) in
            print(string)
            self?.delegate?.hastagOrProfileSelected(byTag: string)
        }
        
        self.secondCommentLabel.hashtagLinkTapHandler = { [weak self] (label, string, range) in
            print(string)
            self?.delegate?.hastagOrProfileSelected(byTag: string)
        }
        /*
         Bug Name:- link not opening
         Fix Date:- 28/06/21
         Fix By  :- jayaram G
         Description of Fix:- Added url tap
         */
        self.secondCommentLabel.urlLinkTapHandler = { [weak self] (label, string, range) in
            Helper.openUrl(string: string.toURL())
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
                let myString:NSString = (self.socialModel?.title!)! as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont.init(name: "CenturyGothic", size: 12.0)!])
                return myMutableString
            }else{
                if self.socialModel!.isExpand {
    //                self.readMoreBtnOutlet.setTitle(" view less", for: .normal)
                    let myString:NSString = (self.fullText + "..." + "Read Less".localized) as NSString
                    var myMutableString = NSMutableAttributedString()
                    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.init(name: "CenturyGothic", size: 12.0)!])
                    myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                    return myMutableString
                    
                }
                else{
    //                self.readMoreBtnOutlet.setTitle(" view more", for: .normal)
                    let myString:NSString = (self.truncatedText + "..." + "Read More".localized) as NSString
                    var myMutableString = NSMutableAttributedString()
                    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont.init(name: "CenturyGothic", size: 12.0)!])
                    myMutableString.addAttribute(NSAttributedString.Key.strokeColor, value: UIColor.red, range: NSRange(location:myString.length-9,length:8))
                    return myMutableString
                }
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
    
    
//    var isSaved = true
    @IBAction func savedPostButtonAction(_ sender: UIButton) {
//        self
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.bookMarkUpdate)
        if !(socialModel?.isBookMarked)! {
            model.addBookmark(socialModel?.postId ?? "")
            model.didUpdateDict = { response in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                sender.isSelected = true
                self.socialModel?.isBookMarked = true
                self.delegate?.openBookMark(index: sender.tag)
            
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.layoutIfNeeded()
//                }) { (isFinishedSuccessfully) in
//                    if isFinishedSuccessfully{
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
//                            UIView.animate(withDuration: 0.3, animations: {
//                                self.layoutIfNeeded()
//                            }){ (isFinishedSuccessfully) in
//                            }
//                        })
//                    }
//                }
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

    
    @IBAction func likeButtonAction(_ sender: Any) {
        if socialModel?.liked == 1{
            socialModel?.liked = 0
            let likeCount = (socialModel?.likesCount)! - 1
            socialModel?.likesCount = likeCount
            delegate?.likeButtonTap(index: self.index, isSelected: true, socialModel: self.socialModel!,FromDoubleTap: false)
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "favourite_black"), view: self.likeImageView)
        }else{
            socialModel?.liked = 1
            let likeCount = (socialModel?.likesCount)! + 1
            socialModel?.likesCount = likeCount
            delegate?.likeButtonTap(index: self.index, isSelected: false, socialModel: self.socialModel!,FromDoubleTap: false)
            self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
        }
        self.makeAttributedStringForViewAndLike(socialModel: self.socialModel!)
    }
 
    @IBAction func commentButtonAction(_ sender: Any) {
        self.delegate?.commentButtonTap(index: index)
    }
    
    
    @IBAction func sendTipAction(_ sender: UIButton) {
        self.delegate?.sendTipAction(index: index)
    }
    
    @IBAction func shareOnChatAction(_ sender: Any) {
        self.delegate?.shareInChatButtonTap(index: index)
    }
    
    @IBAction func shareThroughDeepLinkAction(_ sender: Any) {
//        self.delegate?.shareThroughDeepLinkButtonTap(index: index)
    }
    
    @IBAction func viewAllCommentsAction(_ sender: Any) {
        self.delegate?.commentButtonTap(index: index)
    }
   
    @IBAction func openViewCountAction(_ sender: Any) {
        if let count = socialModel?.distinctView, count != 0{
            delegate?.viewCountButtonTap(index: index)
        }
    }
    
    
    @IBAction func openLikeCountAction(_ sender: Any) {
        if let count = socialModel?.likesCount, count != 0{
            delegate?.likeCountButtonTap(index: index)
        }
    }
    
    
    
    
    
    
    
    //MARK:- Hndle tap gesture
    /// To handle single tap
    ///
    /// - Parameter gesture: tap gesture
    func singleTapHandle(_ gesture: UITapGestureRecognizer){
        print("single tapped")
        if socialModel?.mediaType == 1{
//            delegate?.singleTapOnCell(index: index, cell: self)
        }
    }
    
    /// To handle double tap of cell
    ///
    /// - Parameter gesture: tap gesture
    func doubleTapHandle(_ gesture: UITapGestureRecognizer){
        print("doubletapped")
        if let data = socialModel{
            if data.liked == 0{
                delegate?.likeButtonTap(index: self.index, isSelected: false, socialModel: self.socialModel!, FromDoubleTap: false)
                socialModel?.liked = 1
                socialModel?.likesCount = (socialModel?.likesCount)! + 1
                self.likeImageView.singleTapLikeButtonAnimation(changeImage: #imageLiteral(resourceName: "like_on"), view: self.likeImageView)
                self.makeAttributedStringForViewAndLike(socialModel: self.socialModel!)
            }
            self.bigLikeImageView.popUpDoubletapFavouritAnimation()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

