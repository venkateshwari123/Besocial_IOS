//
//  SocialInstaCollectionViewCell.swift
//  Starchat
//
//  Created by 3Embed Software Tech Pvt Ltd on 10/04/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher

protocol SocialInstaCollectionViewCellDelegate {
  
//    func singleTapOnCell(index: Int, cell: SocialInstaCollectionViewCell)
    func likeButtonTap(index: Int, isSelected: Bool, socialModel: SocialModel,FromDoubleTap: Bool)
    func openProfileView(index: Int, userName: String?)
    func locationLblTap(index: Int)
    func openBusinessProductLink(productUrlStr:String,title:String)
    func viewCollection()
    func moveToCOllections()
    func paidPostTap(modelData: SocialModel,index: Int)
    func navigateToConfirmSubscriptionVc(modelData: SocialModel)
    func followUserTapped(index: Int, isSelected: Bool)
    /*bug Name :- Add zoom to pinch over the cell
      Fix Date :- 22/06/2021
      Fixed By :- Jayaram G
      Description Of fix :- Added zooming scroll to collectionview through delegate
     */
    func zooming(started: Bool)
}

class SocialInstaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var btnSaveToCollection: UIButton!
    
    @IBOutlet weak var followMainView: UIView!
    @IBOutlet weak var followBtnOutlet: UIButton!
    @IBOutlet weak var viewCollectionViewOutlet: UIView!
    @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageView: AnimatedImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var muteUnmuteButtonOutlet: UIButton!
    @IBOutlet weak var viewCollectionsBtnOutlet: UIButton!
    @IBOutlet weak var starBadgeImageView: UIImageView!
    
    @IBOutlet weak var freeImageView: UIImageView!
    @IBOutlet weak var viewCollectionHeightConstraintOutlet: NSLayoutConstraint!
    @IBOutlet weak var saveToCollectionViewOutlet: UIView!
 
    @IBOutlet weak var postLocationBtnOutlet: UIButton!
    
    
    @IBOutlet weak var saveToCollectionViewHeightConstraint: NSLayoutConstraint!
 
    @IBOutlet weak var btnOptions : UIButton!
 
    @IBOutlet weak var businessPostView: UIView!
    @IBOutlet weak var businessButtonText: UILabel!
    @IBOutlet weak var businessProductPrice: UILabel!
    
    @IBOutlet weak var blurBgView: UIView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var btnSubscribepost: UIButton!
    @IBOutlet weak var btnSubscribethispost: UIButton!
    @IBOutlet weak var viewSavedBtn: UIButton!
    @IBOutlet weak var viewLbl: UILabel!

    @IBOutlet weak var tipsAmountBtn: UIButton!
    
    @IBOutlet weak var playPauseVideoImageView: UIImageView!
    
    var socialModel: SocialModel?
    var index: Int = 0
    var videoUrl: URL?
    var delegate: SocialInstaCollectionViewCellDelegate?
    let model = SaveCollectionViewModel.init(api: SavedCollectionAPI.init())
    var hasVideo = false
    var pinch: UIPinchGestureRecognizer?
    var pan: UIPanGestureRecognizer?
    var isZooming = false
    var originalImageCenter:CGPoint?
    
    // the view that will be overlayed, giving a back transparent look
        var overlayView: UIView!
        
        // a property representing the maximum alpha value of the background
        let maxOverlayAlpha: CGFloat = 0.8
        // a property representing the minimum alpha value of the background
        let minOverlayAlpha: CGFloat = 0.4
        
        // the initial center of the pinch
        var initialCenter: CGPoint?
        // the view to be added to the Window
        var windowImageView: UIImageView?
        // the origin of the source imageview (in the Window coordinate space)
        var startingRect = CGRect.zero
    
    
    //MARK:- View life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        self.saveToCollectionViewHeightConstraint.constant = 0
        self.saveToCollectionViewOutlet.makeBorderWidth(width: 0.4, color: .lightGray)
        self.viewCollectionViewOutlet.makeBorderWidth(width: 0.4, color: .lightGray)
        self.viewCollectionHeightConstraintOutlet.constant = 0
        self.btnSaveToCollection.setTitle("Save to Collection".localized, for: .normal)
        self.viewSavedBtn.setTitle("Veiw Saved".localized, for: .normal)
        self.viewLbl.text = "View".localized
        //Tap gesture setup
        self.postImageView.translatesAutoresizingMaskIntoConstraints = false
        self.postImageView.contentMode = .scaleAspectFit
        self.postImageView.isUserInteractionEnabled = true
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        pinch?.delegate = self
        self.postImageView.addGestureRecognizer(pinch!)
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        pan?.delegate = self
        self.postImageView.addGestureRecognizer(pan!)
        
        //Double tap gesture
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(SocialInstaCollectionViewCell.doubleTapHandle(_:)))
        doubleTapGR.numberOfTapsRequired = 2
//        doubleTapGR.numberOfTouchesRequired = 1
        self.postImageView.addGestureRecognizer(doubleTapGR)
//
//        //Single tap gesture
//        let singleTapGR = UITapGestureRecognizer(target: self, action: #selector(SocialInstaCollectionViewCell.singleTapHandle(_:)))
//        singleTapGR.numberOfTapsRequired = 1
////        singleTapGR.numberOfTouchesRequired = 1
//        self.postImageView.addGestureRecognizer(singleTapGR)
//
//        singleTapGR.require(toFail: doubleTapGR)
    }
    
    
    /*bug Name :- Add zoom to pinch over the cell
      Fix Date :- 22/06/2021
      Fixed By :- Jayaram G
      Description Of fix :- Added pinch gesture and handling postimage with overlay view
     */
    // the function called when the user pinches the collection view cell
       @objc func pinch(sender: UIPinchGestureRecognizer) {
           if sender.state == .began {
               // the current scale is the aspect ratio
               let currentScale = self.postImageView.frame.size.width / self.postImageView.bounds.size.width
               // the new scale of the current `UIPinchGestureRecognizer`
               let newScale = currentScale * sender.scale
               
               // if we are really zooming
               if newScale > 1 {
                   // if we don't have a current window, do nothing
                   guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {return}
                   
                   // inform listeners that we are zooming, to stop them scrolling the UICollectionView
                   self.delegate?.zooming(started: true)
                   
                   // setup the overlay to be the same size as the window
                   overlayView = UIView.init(
                       frame: CGRect(
                           x: 0,
                           y: 0,
                           width: (currentWindow.frame.size.width),
                           height: (currentWindow.frame.size.height)
                       )
                   )
                   
                   // set the view of the overlay as black
                   overlayView.backgroundColor = UIColor.black
                   
                   // set the minimum alpha for the overlay
                   overlayView.alpha = CGFloat(minOverlayAlpha)
                   
                   // add the subview to the overlay
                   currentWindow.addSubview(overlayView)
                   
                   // set the center of the pinch, so we can calculate the later transformation
                   initialCenter = sender.location(in: currentWindow)
                   
                   // set the window Image view to be a new UIImageView instance
                   windowImageView = UIImageView.init(image: self.postImageView.image)
                   
                   // set the contentMode to be the same as the original ImageView
                   windowImageView!.contentMode = .scaleAspectFill
                   
                   // Do not let it flow over the image bounds
                   windowImageView!.clipsToBounds = true
                   
                   // since the to view is nil, this converts to the base window coordinates.
                   // so where is the origin of the imageview, in the main window
                   let point = self.postImageView.convert(
                       postImageView.frame.origin,
                       to: nil
                   )
                   
                   // the location of the imageview, with the origin in the Window's coordinate space
                   startingRect = CGRect(
                       x: point.x,
                       y: point.y - (postImageView.frame.size.height/2),
                       width: postImageView.frame.size.width,
                       height: postImageView.frame.size.height
                   )
                   
                   // set the frame for the image to be added to the window
                   windowImageView?.frame = startingRect
                   
                   // add the image to the Window, so it will be in front of the navigation controller
                   currentWindow.addSubview(windowImageView!)
                   
                   // hide the original image
                   postImageView.isHidden = true
               }
           } else if sender.state == .changed {
               // if we don't have a current window, do nothing. Ensure the initialCenter has been set
               guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
                     let initialCenter = initialCenter,
                     let windowImageWidth = windowImageView?.frame.size.width
               else { return }
               
               // Calculate new image scale.
               let currentScale = windowImageWidth / startingRect.size.width
               
               // the new scale of the current `UIPinchGestureRecognizer`
               let newScale = currentScale * sender.scale
               
               // Calculate new overlay alpha, so there is a nice animated transition effect
               overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha

               // calculate the center of the pinch
               let pinchCenter = CGPoint(
                   x: sender.location(in: currentWindow).x - (currentWindow.bounds.midX),
                   y: sender.location(in: currentWindow).y - (currentWindow.bounds.midY)
               )
               
               // calculate the difference between the inital centerX and new centerX
               let centerXDif = initialCenter.x - sender.location(in: currentWindow).x
               // calculate the difference between the intial centerY and the new centerY
               let centerYDif = initialCenter.y - sender.location(in: currentWindow).y
               
               // calculate the zoomscale
               let zoomScale = (newScale * windowImageWidth >= postImageView.frame.width) ? newScale : currentScale

               // transform scaled by the zoom scale
               let transform = currentWindow.transform
                   .translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                   .scaledBy(x: zoomScale, y: zoomScale)
                   .translatedBy(x: -centerXDif, y: -centerYDif)

               // apply the transformation
               windowImageView?.transform = transform
               
               // Reset the scale
               sender.scale = 1
           } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
               guard let windowImageView = self.windowImageView else { return }
               
               // animate the change when the pinch has finished
               UIView.animate(withDuration: 0.3, animations: {
                   // make the transformation go back to the original
                   windowImageView.transform = CGAffineTransform.identity
               }, completion: { _ in
                   
                   // remove the imageview from the superview
                   windowImageView.removeFromSuperview()
                   
                   // remove the overlayview
                   self.overlayView.removeFromSuperview()
                   
                   // make the original view reappear
                   self.postImageView.isHidden = false
                   
                   // tell the collectionview that we have stopped
                   self.delegate?.zooming(started: false)
               })
           }
       }
    
    @objc func doubleTapHandle(_ gesture: UITapGestureRecognizer) {
        if self.socialModel?.liked == 0{
            delegate?.likeButtonTap(index: self.index, isSelected: false, socialModel: self.socialModel!, FromDoubleTap: true)
            self.socialModel?.liked = 1
            self.socialModel?.likesCount = (socialModel?.likesCount)! + 1
        }
        
        self.bigLikeImageView.popUpDoubletapFavouritAnimation()

    }
    
    @objc func pan(sender: UIPanGestureRecognizer) {
    if self.isZooming && sender.state == .began {
    self.originalImageCenter = sender.view?.center
    } else if self.isZooming && sender.state == .changed {
    let translation = sender.translation(in: self)
    if let view = sender.view {
    view.center = CGPoint(x:view.center.x + translation.x,
    y:view.center.y + translation.y)
    }
    sender.setTranslation(CGPoint.zero, in: self.postImageView.superview)
    }
    }
    
    /// To set socila model data in in cell
    ///
    /// - Parameter socialModel: social model
    func setSocialCellData(socialModel: SocialModel){
        self.socialModel = socialModel
        btnSubscribepost.titleLabel?.font = Utility.Font.SemiBold.ofSize(15)
        btnSubscribethispost.titleLabel?.font = Utility.Font.SemiBold.ofSize(15)
        tipsAmountBtn.titleLabel?.font = Utility.Font.Regular.ofSize(13)
        self.tipsAmountBtn.setTitle(" \(socialModel.tipsAmount?.formatUsingAbbrevation() ?? "0.0") " + "tips".localized, for: .normal)
        if socialModel.userId == Utility.getUserid() {
            self.followMainView.isHidden = true
        }else{
            self.followMainView.isHidden = false
        }
        if socialModel.isFollowing {
            self.followBtnOutlet.setTitle("Following".localized, for: .normal)
        }else{
            self.followBtnOutlet.setTitle("Follow".localized, for: .normal)
        }
        self.followBtnOutlet.setTitleColor(Utility.appColor(), for: .normal)
        self.followBtnOutlet.setTitleColor(Utility.appColor(), for: .selected)
        self.followBtnOutlet.titleLabel?.font = Utility.Font.Bold.ofSize(13)
        /*
         Bug Name:- add star badge for star user
         Fix Date:- 08/06/21
         Fixed By:- Nikunj C
         Description of Fix:- for star show star badge
         */
        if socialModel.isStar == 1 {
            self.starBadgeImageView.isHidden = false
        }else{
            self.starBadgeImageView.isHidden = true
        }
        if socialModel.channelName == "" {
            if let businessPostType = socialModel.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
                self.userNameLabel.text = socialModel.businessProfileObj?.businessName
                Helper.addedUserImage(profilePic: socialModel.businessProfileObj?.businessProfilePic, imageView: self.userImageView, fullName: socialModel.businessProfileObj?.businessName ?? "P")
            }else {
                /*
                 Bug Name:- Show the intials for default profile pic
                 Fix Date:- 12/05/21
                 Fix By  :- Jayram G
                 Description of Fix:- setting initials image when user not uploaded profile pic
                 */
                Helper.addedUserImage(profilePic: socialModel.profilePic, imageView: self.userImageView, fullName: socialModel.fullNameWithSpace ?? "")
                if socialModel.isStar == 1{
                    self.userNameLabel.text = socialModel.userName
                }else{
                    self.userNameLabel.text = socialModel.userName
                }
            }
            
        }else {
            self.userNameLabel.text = socialModel.channelName
            Helper.addedUserImage(profilePic: socialModel.channelImageUrl, imageView: self.userImageView, fullName: socialModel.channelName ?? "P")
        }
        
        if socialModel.place == "" {
            self.postLocationBtnOutlet.isHidden = true
            self.locationHeightConstraint.constant = 0.0
        }else {
            self.postLocationBtnOutlet.isHidden = false
            self.locationHeightConstraint.constant = 20.0
            self.postLocationBtnOutlet.setTitle(socialModel.place, for: .normal)
        }
        
        
        if let businessPostType = socialModel.businessProfileObj?.businessPostTypeName , businessPostType.count > 0 , businessPostType != "Regular"{
            self.businessPostView.isHidden = false
            //            if socialModel.businessProfileObj?.businessButtonText == "Buy now" {
            //                self.businessPostView.backgroundColor = UIColor.blue
            //            }else {
            //                self.businessPostView.backgroundColor = UIColor.orange
            //            }
            if let color = socialModel.businessProfileObj?.businessButtonColor{
                self.businessPostView.backgroundColor = Helper.hexStringToUIColor(hex: color)
            }else{
                self.businessPostView.backgroundColor = UIColor.clear
            }
            self.businessButtonText.text = socialModel.businessProfileObj?.businessButtonText
            let businessPrice = socialModel.businessProfileObj?.businessPrice
            if businessPrice == nil {
                self.businessProductPrice.text = ""
            }else {
                self.businessProductPrice.text = "\(socialModel.businessProfileObj?.businessCurrency ?? "")"+" "+"\(String(describing: businessPrice!))"
            }
        }else{
            self.businessPostView.isHidden = true
        }
        
        if socialModel.mediaType == 1{
            if let url = socialModel.thumbnailUrl{
                let endIndex = url.index(url.endIndex, offsetBy: -3)
                var truncatedForVideo = url.substring(to: endIndex)
                var truncated = url.substring(to: endIndex)
                truncated = truncated + "jpg"
                self.postImageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                if socialModel.userId == Utility.getUserid() {
                self.videoUrl = URL(string: truncatedForVideo + "mov")
                }else{
                    if socialModel.isPaid {
                        if socialModel.isPurchased == 1 {
                            self.videoUrl = URL(string: truncatedForVideo + "mov")
                        }else{
                            /*bug Name :- Home Page: The video which are locked or pay to unlock videos are being played with blurr screen
                              Fix Date :- 09/06/2021
                              Fixed By :- Jayaram G
                              Description Of fix :- Setting video url nil for paid post and not purchased
                             */
                            self.videoUrl = nil
                        }
                    }else{
                    self.videoUrl = URL(string: truncatedForVideo + "mov")
                    }
                }
            }
            self.videoImageView.isHidden = false
            self.muteUnmuteButtonOutlet.isHidden = false
            hasVideo = true
        }else{
            https://res.cloudinary.com/demo/image/upload/e_blur:300/sample.jpg
            if socialModel.userId == Utility.getUserid() {
                self.postImageView.setImageOn(imageUrl: socialModel.imageUrl
                , defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }else{
                    if socialModel.isPurchased == 1 {
                        self.postImageView.setImageOn(imageUrl: socialModel.imageUrl
                        , defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    }else{
                        var urlString = socialModel.imageUrl
                        urlString = urlString?.replace(target: "upload/", withString: "upload/")
                    self.postImageView.setImageOn(imageUrl: urlString
                        , defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    }
            
            }
            
            self.videoImageView.isHidden = true
            self.muteUnmuteButtonOutlet.isHidden = true
            hasVideo = false
        }
        
        // paid post
        if socialModel.isPaid {
            self.freeImageView.isHidden = true
            if socialModel.userId == Utility.getUserid() {
                self.freeImageView.image = #imageLiteral(resourceName: "Group 40857")
                blurView.isHidden = true
            }else{
                if socialModel.isPurchased == 1 {
                    self.freeImageView.image = #imageLiteral(resourceName: "Group 40857")
                    blurView.isHidden = true
                }else{
                    
                    blurView.isHidden = false
                    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.frame = blurBgView.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    blurBgView.alpha = 0.75
                    blurBgView.addSubview(blurEffectView)
                    let fullString = NSMutableAttributedString(string: "Unlock this post for".localized + "  ")
                    let image1Attachment = NSTextAttachment()
                    image1Attachment.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 15, height: 15))
                    let image1String = NSAttributedString(attachment: image1Attachment)
                    
                    fullString.append(image1String)
                    fullString.append(NSAttributedString(string: " \(socialModel.postAmount ?? 0)"))


                    let fullStringForSubscribe = NSMutableAttributedString(string: "Subscribe to".localized + " \(socialModel.userName ?? "") " + "for".localized + "  ")
                    let image1AttachmentForSubscribe = NSTextAttachment()
                    image1AttachmentForSubscribe.image = UIImage(named: "dollar")?.resizeImageUsingVImage(size: CGSize(width: 15, height: 15))
                    let image1StringForSubscribe = NSAttributedString(attachment: image1Attachment)
                    
                    fullStringForSubscribe.append(image1StringForSubscribe)
                    fullStringForSubscribe.append(NSAttributedString(string: " \(socialModel.subscriptionAmount ?? 0.0)"))

                    if socialModel.subscriptionAmount ?? 0 > 0 {
                        self.btnSubscribethispost.isHidden = false
                    }else {
                        self.btnSubscribethispost.isHidden = true
                    }
                    btnSubscribepost.setAttributedTitle(fullString, for: .normal)
                    btnSubscribethispost.setAttributedTitle(fullStringForSubscribe, for: .normal)
                }
                
            }
            
        }
        else{
            
            /*bug Name :- remove free tag from homepage
              Fix Date :- 22/03/2021
              Fixed By :- Nikunj C
              Description Of fix :- hide freetag  */
            
            self.freeImageView.isHidden = true
            self.freeImageView.image = #imageLiteral(resourceName: "Group 40726")
            blurView.isHidden = true
        }
    }
    
    
    @IBAction func purchasePostTap(_ sender: Any) {
        guard let data = self.socialModel else {return}
        delegate?.paidPostTap(modelData: data,index: self.index)
    }
    @IBAction func PurchaseSubscriptionTap(_ sender: Any) {
        guard let data = self.socialModel else {return}
        delegate?.navigateToConfirmSubscriptionVc(modelData: data)
    }
    
    func setImageInCell(social: SocialModel, isPlaying: Bool){
        if social.mediaType == 1{
            if let url = social.thumbnailUrl{
//                if isPlaying{
////                    let gifString = url.makeGifUrl()
//                    self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
//                }else{
//                    self.postImageView.image = nil
//                }
                self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            self.videoImageView.isHidden = false
        }else{
            if let url = social.imageUrl{
                self.postImageView.setImageOn(imageUrl: url, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
            }
            self.videoImageView.isHidden = true
        }
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
    
    
    
    
     
    //MARK:- Buttons Action
    
    @IBAction func followButtonAction(_ sender: Any) {
        if self.socialModel?.isFollowing == true {
            self.followBtnOutlet.setTitle("Follow".localized, for: .normal)
            self.delegate?.followUserTapped(index: self.index, isSelected: false)
        }else{
            self.followBtnOutlet.setTitle("Following".localized, for: .normal)
            self.delegate?.followUserTapped(index: self.index, isSelected: true)
        }
    }
    
    
    @IBAction func viewCollectionsButton(_ sender: UIButton) {
        delegate?.viewCollection()
    }
    
    @IBAction func moveToCollectionsVc(_ sender: UIButton) {
           delegate?.moveToCOllections()
       }
       
    
//    var isSaved = true
    @IBAction func savedPostButtonAction(_ sender: UIButton) {
//        self
        if !(socialModel?.isBookMarked)! {
            model.addBookmark(socialModel?.postId ?? "")
            model.didUpdateDict = { response in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                sender.isSelected = true
                self.socialModel?.isBookMarked = true
                UIView.animate(withDuration: 0.3, animations: {
                    self.saveToCollectionViewHeightConstraint.constant = 50
                    self.layoutIfNeeded()
                }) { (isFinishedSuccessfully) in
                    if isFinishedSuccessfully{
                         DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {
                            UIView.animate(withDuration: 1, animations: {
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
        }
    }

    
    
    
    @IBAction func postLocationBtnAction(_ sender: UIButton) {
        delegate?.locationLblTap(index: self.index)
    }
    
    
    
    
    @IBAction func openProfileAction(_ sender: Any) {
        delegate?.openProfileView(index: index, userName: nil)
    }
    

    
    @IBAction func businessPostButtonAction(_ sender: UIButton) {
        if let businessProductUrl = socialModel?.businessProfileObj?.businessUrl {
            delegate?.openBusinessProductLink(productUrlStr: businessProductUrl, title: socialModel?.title ?? "")
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
    
    
}

extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
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
extension SocialInstaCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
    }
}
