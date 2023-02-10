//
//  UserProfileHeaderTableViewCell.swift
//  dub.ly
//
//  Created by 3Embed Software Tech Pvt Ltd on 17/01/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import Kingfisher
protocol UserProfileHeaderTableViewCellDelegate: class{
    func didFollowButtonTap()
    func openWebsiteWithUrl(url: URL)
    func openMailWithReciept(To: String)
    func moveToWalletVc()
    func moveToTransactionVc()
    func moveToQrCodeVc()
    func moveToActivityVc()
    func switchingAccountVc()
    func openingEmailAction()
    func openingCallAction()
    func businessWebsiteAction()
    func openMessageAction()
    func openAddressLocation()
    func subscribeUserAction()
    func subscribersListAction()
    func moveToCoinVc()
    func viewMoreButtonTapped()
}

class UserProfileHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postsFollowersBackView: UIView!
    @IBOutlet weak var emailMessageCallViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageBtnOutlet: UIButton!
    @IBOutlet weak var emailBtnOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var activityBusinessViewOutlet: UIView!
    @IBOutlet weak var walletQrCodeView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var businessBtnOutlet: UIButton!
    @IBOutlet weak var earnedCoinsBtnOutlet: UIButton!

    @IBOutlet weak var userMessageBtnOutlet: UIButton!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var websiteBtnOutlet: UIButton!
    @IBOutlet weak var businessAddressLbl: UILabel!
    @IBOutlet weak var businessBio: ActiveLabel!
    @IBOutlet weak var qrCodeBtnOutlet: UIButton!
    @IBOutlet weak var walletQrCodeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var verifyProfileIndicateImage: UIImageView!
    @IBOutlet weak var userStatus: ActiveLabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followContainerView: UIView!
    @IBOutlet weak var followButtonOutlet: UIButton!
    @IBOutlet weak var locationBtnOutlet: UIButton!
    @IBOutlet weak var stackViewOutlet: UIStackView!
    @IBOutlet weak var balanceBtnOutlet: UIButton!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var emailCallMessageViewOutlet: UIView!
    @IBOutlet weak var followContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coinBtnOutlet: UIButton!
    
    @IBOutlet weak var activityBtnOutlet: UIButton!
    
    @IBOutlet weak var subscriptionsCountLabel: UILabel!
    @IBOutlet weak var subscribeBtnOutlet: UIButton!
    @IBOutlet weak var postsTextLabel: UILabel!
    @IBOutlet weak var followerTextLabel: UILabel!
    @IBOutlet weak var followingTextLabel: UILabel!
    @IBOutlet weak var subscriberTextLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var subscribeDotView: UIView!
    @IBOutlet weak var subscribersViewOutlet: UIView!
    @IBOutlet weak var businessProfileIndicationImage: UIImageView!
    var isMine: Bool = false
    var delegate: UserProfileHeaderTableViewCellDelegate?
    
    /*
     Bug Name :- Read more , read less
     Fix Date :- 06/05/2021
     Fixed By :- Nikunj C
     Description Of Fix :- Added required variables
     */
    var fullText = ""
    var truncatedText = ""
    var truncatedLength = 60
    var isTruncated = true
    var isExpand:Bool = false
    var statusText = ""
    var businessBioText = ""
    
    /*
     Feat Name:- can detect email and website from status
     Feat Date:- 26/04/21
     Feat by  :- Nikunj C
     Discription of Feat:- add custome type to recognise email and website in bio status
     */
    
    
    let email = ActiveType.custom(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
    let websiteType = ActiveType.custom(pattern: "((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+")
    let readMoreType = ActiveType.custom(pattern: "..." + "Read More".localized + "|..." + "Read Less".localized)
    //MARK:- Life cycel
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setLocalization()
        self.coinBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.balanceBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.userMessageBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.activityBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.userMessageBtnOutlet.makeCornerRadious(readious: 7)
        self.followButtonOutlet.makeCornerRadious(readious: 7)
        self.coinBtnOutlet.makeCornerRadious(readious: 7)
        self.balanceBtnOutlet.makeCornerRadious(readious: 7)
        self.activityBtnOutlet.makeCornerRadious(readious: 7)
        self.earnedCoinsBtnOutlet.makeCornerRadious(readious: 7)
        self.earnedCoinsBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.messageBtnOutlet.makeCornerRadious(readious: 7)
        self.callButtonOutlet.makeCornerRadious(readious: 7)
        self.locationBtnOutlet.makeCornerRadious(readious: 7)
        self.emailBtnOutlet.makeCornerRadious(readious: 7)
        
        self.emailBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.messageBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.callButtonOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        self.locationBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        
//        self.locationBtnOutlet.isHidden = true
        self.verifyProfileIndicateImage.isHidden = true
        
        /*
         Feat Name:- now email tap available for bio status
         Feat Date:- 27/03/21
         Feat by  :- Nikunj C
         Discription of Feat:- setup for customType
         */
        
        /*
         Bug Name :- hash tag and user tag is to be made bold white
         Fix Date :- 29/04/2021
         Fixed By :- Jayaram G
         Description Of Fix :- Added configureLinkAttribute for label
         */
        self.userStatus.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .hashtag,.email,.mention,.url:
                atts[NSAttributedString.Key.font] = Utility.Font.Bold.ofSize(16)
                if #available(iOS 13.0, *) {
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.label
                } else {
                    atts[NSAttributedString.Key.foregroundColor] = UIColor.black
                }
            default: ()
            }
            return atts
        }
        
        self.userStatus.enabledTypes = [.hashtag,.mention,.url,email,readMoreType]
        self.businessBio.enabledTypes = [.hashtag,.mention,.url,email,readMoreType]
        self.userStatus.customColor[readMoreType] = .systemPurple
        self.businessBio.customColor[readMoreType] = .systemPurple
        self.userStatus.customColor[.url] = .blue
        self.businessBio.customColor[.url] = .blue
        
        if  Utility.getDeviceHeight() > 736.0 {
            self.postsTextLabel.font = postsTextLabel.font.withSize(self.contentView.frame.width * 0.036)
            followerTextLabel.font = followerTextLabel.font.withSize(self.contentView.frame.width * 0.036)
            followingTextLabel.font = followingTextLabel.font.withSize(self.contentView.frame.width * 0.036)
            subscriberTextLabel.font = subscriberTextLabel.font.withSize(self.contentView.frame.width * 0.036)
            
        }else{
            self.postsTextLabel.font = postsTextLabel.font.withSize(self.contentView.frame.width * 0.032)
            followerTextLabel.font = followerTextLabel.font.withSize(self.contentView.frame.width * 0.032)
            followingTextLabel.font = followingTextLabel.font.withSize(self.contentView.frame.width * 0.032)
            subscriberTextLabel.font = subscriberTextLabel.font.withSize(self.contentView.frame.width * 0.032)
        }
    }
    
    func setLocalization(){
        self.postsTextLabel.text = "Posts".localized
        self.followerTextLabel.text = "Followers".localized
        self.followingTextLabel.text = "Following".localized
        self.subscriberTextLabel.text = "Subscribers".localized
        self.userMessageBtnOutlet.setTitle("Message".localized, for: .normal)
        self.messageBtnOutlet.setTitle("Message".localized, for: .normal)
        self.callButtonOutlet.setTitle("Call".localized, for: .normal)
        self.emailBtnOutlet.setTitle("Email".localized, for: .normal)
        self.locationBtnOutlet.setTitle("Locate".localized, for: .normal)
        self.activityBtnOutlet.setTitle("Notifications".localized, for: .normal)
    }
    
    /*
     Bug Name :- view more in profile status
     Fix Date :- 16/05/2021
     Fixed By :- Nikunj c
     Description Of Fix :- read more/read less  action
     */
    
    func labelAction(){
        if self.isExpand {
            self.isExpand = false
        }else{
            self.isExpand = true
        }
        self.delegate?.viewMoreButtonTapped()
        self.userStatus.attributedText = expandOrCollapse()
        self.businessBio.attributedText = expandOrCollapse(isForBusiness: true)
        //            self.delegate?.forYoureloadTableView(index: self.index)
        self.reloadInputViews()
    }
    
    /*
     Bug Name :- view more in profile status
     Fix Date :- 16/05/2021
     Fixed By :- Nikunj c
     Description Of Fix :- Adding link handler for active label
     */
    /// To handle link in description
    private func linkHandler(){
        userStatus.customize { label in

           
            label.handleURLTap { (url) in
                self.delegate?.openWebsiteWithUrl(url: url)
            }
            
            label.handleCustomTap(for: email) { (To) in
                print("email \(To) tapped")
                self.delegate?.openMailWithReciept(To: To)
            }
            
            label.handleCustomTap(for: websiteType) { (website) in
                guard let url = URL(string: website) else {return}
                self.delegate?.openWebsiteWithUrl(url: url)
            }

            label.handleCustomTap(for: readMoreType) { (String) in
                self.labelAction()
            }

            self.truncatedText = getText(fullText: statusText)
            label.attributedText = self.expandOrCollapse()

        }
        
        businessBio.customize { label in

            
            
            label.handleURLTap { (url) in
                self.delegate?.openWebsiteWithUrl(url: url)
            }
            
            label.handleCustomTap(for: email) { (To) in
                print("email \(To) tapped")
                self.delegate?.openMailWithReciept(To: To)
            }

            label.handleCustomTap(for: websiteType) { (website) in
                guard let url = URL(string: website) else {return}
                self.delegate?.openWebsiteWithUrl(url: url)
            }

            label.handleCustomTap(for: readMoreType) { (string) in
                self.labelAction()
            }
            self.truncatedText = getText(fullText: businessBioText)
            label.attributedText = self.expandOrCollapse(isForBusiness: true)

        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //        self.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 300)
        
        //make corner radious of top left and top right for detailsContainerView
        let maskPath = UIBezierPath.init(roundedRect: self.detailsContainerView.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize.init(width: 20.0, height: 20.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.detailsContainerView.bounds
        maskLayer.path = maskPath.cgPath
        self.detailsContainerView.layer.mask = maskLayer
        
        //make corner radious for profileImageView and border width
        self.profileImageView.makeCornerRadious(readious: profileImageView.frame.size.width / 2)
        self.profileImageView.makeBorderWidth(width: 1.0, color: UIColor.white)
       
        
        //     self.activityBtnOutlet.makeCornerRadious(readious: 5)
        //        self.businessBtnOutlet.makeCornerRadious(readious: 5)
        //        self.businessBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        //self.activityBtnOutlet.makeBorderWidth(width: 1, color: Utility.appColor())
        
        self.followContainerView.makeCornerRadious(readious: 5.0)
        
        self.balanceBtnOutlet.makeCornerRadious(readious: 5.0)

        
        //   self.businessBtnOutlet.titleLabel?.numberOfLines = 2
        // self.businessBtnOutlet.titleLabel?.textAlignment = .center
        
        //        self.emailCallMessageViewOutlet.isHidden = true
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /*
     Bug Name :- read more , read less
     Fix Date :- 06/05/2021
     Fixed By :- Nikunj C
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
     Bug Name :- view more in profile status
     Fix Date :- 16/05/2021
     Fixed By :- Nikunj C
     Description Of Fix :- To get dynamic text of the status
     */
    
    func expandOrCollapse(isForBusiness:Bool? = false) -> NSMutableAttributedString? {
    
        
        if self.fullText.count < truncatedLength{
            if isForBusiness ?? false{
                let myString:NSString = (self.businessBioText) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size:  16.0)!])
                return myMutableString
            }else{
                let myString:NSString = (self.statusText) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size:  16.0)!])
                return myMutableString
            }
            
        }else{
            if self.isExpand {
                let myString:NSString = (self.fullText + " ..." + "Read Less".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size: 16.0)!])
                return myMutableString
            }
            else{
                let myString:NSString = (self.truncatedText + " ..." + "Read More".localized) as NSString
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font:UIFont(name: "RobotoCondensed-Regular", size: 16.0)!])
                return myMutableString
            }
        }
    }
    
    /// To set header view UI
    ///
    /// - Parameters:
    ///   - isMine: to check if it is mine profile header or other
    ///   - name: name of user
    ///   - status: status of user
    ///   - image: image of user
    func setHeaderView(isMine: Bool,userName: String?, name: String?, status: String?, image: String?,coverImage: String?,starRequest: StarProflie?,balance:Double?,businessId:String?,businessCategory: String?,businessAddress:String?,businessWebsite:String? , businessBio:String?,isStar:Int?,starKnownAs:String?,businessEmailDetails:BusinessEmail?,businessMobileDetails:BusinessPhone?,businessChatIsVisible:Int?,businessprofileImage:String?,businessCoverImage:String?,isActiveBusinessProfile:Int?,businessName:String?,businessUserName:String?){
        /*Bug Name :- Coin and wallet balance not updating in profile page
          Fix Date :- 29/06/2021
          Fixed By :- jayaram G
          Description Of Fix :- refreshing balance here
         */
        let walletData = Double(KeychainHelper.sharedInstance.getWalletBalance())?.formatUsingAbbrevation()
        self.balanceBtnOutlet.setTitle(" \(Utility.getWalletCurrenySymbol()) \(walletData ?? "")", for: .normal)
        if let coinData = Double(KeychainHelper.sharedInstance.getCoinWalletBalance())?.formatUsingAbbrevation(){
            if Double(coinData) ?? 0 > 1 {
                self.coinBtnOutlet.setTitle(" \(coinData)", for: .normal)
            }else{
                self.coinBtnOutlet.setTitle(" \(coinData)", for: .normal)
            }
            
        }
        
        //        _label.systemURLStyle = YES;
        if isActiveBusinessProfile == 1 {
            self.businessProfileIndicationImage.isHidden = false
        }else {
            self.businessProfileIndicationImage.isHidden = true
        }
        
        if isMine {
            if isStar == 1 {
                self.subscribeDotView.isHidden = false
                self.subscribersViewOutlet.isHidden = false
            }else{
                self.subscribeDotView.isHidden = true
                self.subscribersViewOutlet.isHidden = true
            }
        }else{
            self.subscribeDotView.isHidden = true
            self.subscribersViewOutlet.isHidden = true
        }
//        if status == nil || status == ""{
//            self.statusText = AppConstants.defaultStatus
//            self.userStatus.text = AppConstants.defaultStatus
//        }else{
//            self.statusText = status ?? AppConstants.defaultStatus
//            self.userStatus.text = status
//        }
        
        if isStar == 0 {
            self.verifyProfileIndicateImage.isHidden = true
            if let isBusinessProfile = isActiveBusinessProfile as? Int {
                if isBusinessProfile  == 1{
                    
                    let businessEmailVisible = businessEmailDetails?.isVisible as? Int
                    if businessEmailVisible == 0 {
                        self.emailBtnOutlet.isEnabled = false
                        self.emailBtnOutlet.isHidden = true
                    }else{
                        self.emailBtnOutlet.isEnabled = true
                    }
                    if businessChatIsVisible == 0 {
                        self.messageBtnOutlet.isEnabled = false
                        self.messageBtnOutlet.isHidden = true
                    }else{
                        self.messageBtnOutlet.isEnabled = true
                    }
                    let businessPhoneVisible = businessMobileDetails?.isVisible as? Int
                    if businessPhoneVisible == 0 {
                        self.callButtonOutlet.isEnabled = false
                        self.callButtonOutlet.isHidden = true
                    }else{
                        self.callButtonOutlet.isEnabled = true
                    }
                    if !isMine {
                        self.emailCallMessageViewOutlet.isHidden = false
                        self.emailMessageCallViewHeightConstraint.constant = 45
                    }
                }else {
                    let businessEmailVisible = businessEmailDetails?.isVisible as? Int
                    if businessEmailVisible == 0 {
                        self.emailBtnOutlet.isEnabled = false
                        self.emailBtnOutlet.isHidden = true
                    }else{
                        self.emailBtnOutlet.isEnabled = true
                    }
                    if businessChatIsVisible == 0 {
                        self.messageBtnOutlet.isEnabled = false
                        self.messageBtnOutlet.isHidden = true
                    }else{
                        self.messageBtnOutlet.isEnabled = true
                    }
                    let businessPhoneVisible = businessMobileDetails?.isVisible as? Int
                    if businessPhoneVisible == 0 {
                        self.callButtonOutlet.isEnabled = false
                        self.callButtonOutlet.isHidden = true
                    }else{
                        self.callButtonOutlet.isEnabled = true
                    }
                    
                    /*
                     Refactor Name:- hide call,chat,email,location for star user
                     Refactor Date:- 24/04/21
                     Refactor   By:- Nikunj c
                     Description of Refactor:- show view for  business profile only
                     */
                    
                    if !isMine{
                        self.emailCallMessageViewOutlet.isHidden = true
                        self.emailMessageCallViewHeightConstraint.constant = 0
                    }
                }
            }
        }
        
        
        //         let starStatus = starRequest?["starUserProfileStatusText"] as? String
        //            if starStatus == "approved"{
        //                UserDefaults.standard.set(true, forKey: AppConstants.UserDefaults.isVerifiedUserProfile)
        //              let isVisibleEmail  = starRequest?["isEmailVisible"] as? Int
        //                    if isVisibleEmail == 0 {
        //                        self.emailBtnOutlet.isEnabled = false
        //                    }else{
        //                        self.emailBtnOutlet.isEnabled = true
        //                    }
        //
        //                 let isVisibleNumber  = starRequest?["isNumberVisible"] as? Int
        //                        if isVisibleNumber == 0 {
        //                            self.callButtonOutlet.isEnabled = false
        //                        }else{
        //                            self.callButtonOutlet.isEnabled = true
        //                        }
        //
        //            }else {
        //                self.emailCallMessageViewOutlet.isHidden = true
        //                self.emailMessageCallViewHeightConstraint.constant = 0
        //                self.verifyProfileIndicateImage.isHidden = true
        //            }
        
        var containerHeight: CGFloat = 340
        var qrCodeImage = UIImage()
        if isMine{
            DispatchQueue.main.async {
                self.followContainerView.isHidden = true
                self.followButtonOutlet.isHidden = true
                self.earnedCoinsBtnOutlet.isHidden = false
                self.qrCodeBtnOutlet.isHidden = false
                self.followContainerViewHeightConstraint.constant = 0
                self.emailCallMessageViewOutlet.isHidden = true
                self.emailMessageCallViewHeightConstraint.constant = 0
                
                
                self.walletQrCodeView.isHidden = false
                
                
                if let businessProfileCreated = isActiveBusinessProfile as? Int {
                    if businessProfileCreated == 1{
                        DispatchQueue.main.async {
                          //  self.businessCategoryLbl.isHidden = false
                            self.websiteBtnOutlet.isHidden = false
                            self.businessAddressLbl.isHidden = false
                            self.userStatus.isHidden = true
                            self.businessBio.isHidden = false
//                            self.userNameLabel.isHidden = true
                        }
                    }else {
                        DispatchQueue.main.async {
                          //  self.businessCategoryLbl.isHidden = true
                            self.websiteBtnOutlet.isHidden = true
                            self.businessAddressLbl.isHidden = true
                            self.userStatus.isHidden = false
                            self.businessBio.isHidden = true
//                            self.userNameLabel.isHidden = false
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                     //   self.businessCategoryLbl.isHidden = true
                        self.websiteBtnOutlet.isHidden = true
                        self.businessAddressLbl.isHidden = true
                        self.userStatus.isHidden = false
                        self.businessBio.isHidden = true
//                        self.userNameLabel.isHidden = false
                    }
                }
            }
            containerHeight = containerHeight - 20
            self.editImageView.isHidden = false
        }else{
            DispatchQueue.main.async {
                if isActiveBusinessProfile == 1 {
                    self.followContainerView.isHidden = true
                    self.businessAddressLbl.isHidden = false
                    self.followContainerViewHeightConstraint.constant = 0
                }else {
//                    self.followContainerView.isHidden = false
                    self.followButtonOutlet.isHidden = false
                    self.earnedCoinsBtnOutlet.isHidden = true
                    self.qrCodeBtnOutlet.isHidden = true
                    self.businessAddressLbl.isHidden = true
                }
                
                self.websiteBtnOutlet.isHidden = true
                //                self.stackViewOutlet.spacing = 5.0
                self.businessBio.isHidden = true
                //     self.emailCallMessageViewOutlet.isHidden = true
                self.userStatus.isHidden = false
                //   self.businessIdHeightConstraint.constant = 0
                // self.activityBusinessViewOutlet.isHidden = true
                // self.businessActivityHeightConstraint.constant = 0
                self.walletQrCodeView.isHidden = true
                //   self.walletQrCodeHeightConstraint.constant = 0
                //                self.followContainerView.isHidden = false
            }
            self.editImageView.isHidden = true
        }
        
        if isMine {
            if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                if businessProfileCreated {
                    self.userNameLabel.text = "@\(businessUserName ?? "")"
                    self.fullNameLabel.text = businessName
                 }else {
                    if isStar == 1{
                        /*Bug Name :- Should show knownas for star user
                          Fix Date :- 03/05/2021
                          Fixed By :- jayaram G
                          Description Of Fix :- Assigning "starUserKnownBy" data to fullName
                         */
                        self.fullNameLabel.text = "Known as".localized + " \(starRequest?.starUserKnownBy ?? "")"
                        self.verifyProfileIndicateImage.isHidden = false
                    }else{
                        self.fullNameLabel.text = name
                    }
                    self.userNameLabel.text = "@\(userName ?? "")"
                }
            }else{
                
                /*
                 Bug Name:- on first login on profile it had some hard coded detail
                 Fix Date:- 06/05/21
                 Fixed By:- Nikunj C
                 Description of Fix:- add condition is not saved userdefault
                 */
                
                if isStar == 1{
                    self.fullNameLabel.text = "Known as".localized + " \(starRequest?.starUserKnownBy ?? "")"
                    self.verifyProfileIndicateImage.isHidden = false
                }else{
                    self.fullNameLabel.text = name
                }
                self.userNameLabel.text = "@\(userName ?? "")"
            }
        }else{
            if isActiveBusinessProfile == 1{
                self.userNameLabel.text = "@\(businessName ?? "")"
                 
            }else {
                if isStar == 1{
                    /*Bug Name :- Should show knownas for star user
                      Fix Date :- 03/05/2021
                      Fixed By :- jayaram G
                      Description Of Fix :- Assigning "starUserKnownBy" data to fullName
                     */
                    self.fullNameLabel.text = "Known as".localized + " \(starRequest?.starUserKnownBy ?? "")"
                    self.verifyProfileIndicateImage.isHidden = false
                    }else{
                        self.fullNameLabel.text = name
                    }
                self.userNameLabel.text = "@\(userName ?? "")"
            }
        }
        
//        self.userFullName.text = name
//        self.userNameLabel.text = userName
      //  self.businessCategoryLbl.text = businessCategory
        self.businessAddressLbl.text = businessAddress
        self.businessBioText = businessBio ?? ""
        self.businessBio.text = businessBio
        let businessWebsiteObj = businessWebsite ?? ""
        self.websiteBtnOutlet.setTitle(businessWebsiteObj, for: .normal)
        linkHandler()
        
        
        self.isMine = isMine
        DispatchQueue.main.async {
            //  self.userStatus.isHidden = false
            //self.userStatusHeightConstraint.constant = height
            //  self.detailsContainerHeightConstraint.constant = containerHeight + height
            //            self.updateConstraints()
            //            self.layoutIfNeeded()
        }
        
        //        if let starStatus = data.starRequest?["starUserProfileStatusText"] as? String{
        //            if starStatus == "accepted"{
        //                self.verifyProfileIndicateImage.isHidden = false
        //            }else {
        //                self.verifyProfileIndicateImage.isHidden = true
        //            }
        //        }
        
        
    }
    
    func setHeaderViewFromModel(modelData: UserProfileModel?, isSelf: Bool){
        self.isMine = isSelf
        var containerHeight: CGFloat = 360
        if let earnedCoin = modelData?.earnCoins.formatUsingAbbrevation() {
            self.earnedCoinsBtnOutlet.setTitle(" \(earnedCoin)", for: .normal)
        }
        if isMine{
            self.emailCallMessageViewOutlet.isHidden = true
            self.emailMessageCallViewHeightConstraint.constant = 0
            self.followContainerView.isHidden = true
            self.followButtonOutlet.isHidden = true
            self.earnedCoinsBtnOutlet.isHidden = false
            self.qrCodeBtnOutlet.isHidden = false
            self.followContainerViewHeightConstraint.constant = 0
            // self.followContainerTopLayOutConstraint.constant = 0.0
            containerHeight = containerHeight - 20
            self.layoutIfNeeded()
        }else{
            if let isStar = modelData?.isStar {
                if isStar == 0 {
                    self.verifyProfileIndicateImage.isHidden = true
                    if modelData?.businessDetails != nil {
                        if !isSelf {
                            if modelData?.businessProfileActive == 1 {
                                self.emailCallMessageViewOutlet.isHidden = false
                                self.emailMessageCallViewHeightConstraint.constant = 45
                            }else {
                                self.emailCallMessageViewOutlet.isHidden = true
                                self.emailMessageCallViewHeightConstraint.constant = 0
                            }
                        }
                    }
                    else {
                        self.emailCallMessageViewOutlet.isHidden = true
                        self.emailMessageCallViewHeightConstraint.constant = 0
                        //                            self.verifyProfileIndicateImage.isHidden = true
                    }
                }else if isStar == 1 {
                    /*
                     Refactor Name:- hide call,chat,email,location for star user
                     Refactor Date:- 24/04/21
                     Refactor   By:- Nikunj c
                     Description of Refactor:- show view for  business profile only
                     */
                    self.verifyProfileIndicateImage.isHidden = false
                    if modelData?.businessDetails != nil {
                        if !isSelf {
                            if modelData?.businessProfileActive == 1 {
                                self.emailCallMessageViewOutlet.isHidden = false
                                self.emailMessageCallViewHeightConstraint.constant = 45
                            }else {
                                self.emailCallMessageViewOutlet.isHidden = true
                                self.emailMessageCallViewHeightConstraint.constant = 0
                            }
                        }
                    }
                }
            }
            
            self.followButtonOutlet.isHidden = false
            self.earnedCoinsBtnOutlet.isHidden = true
            self.qrCodeBtnOutlet.isHidden = true
            if modelData?.businessDetails.count ?? 0 > 0 {
                self.followContainerView.isHidden = true
                self.followContainerViewHeightConstraint.constant = 0
            }
            
            if modelData?.subscriptionAmount != -1  && modelData?.subscriptionAmount != nil && modelData?.subscriptionAmount != 0.0 && modelData?.followStatus == 0{
                self.followContainerViewHeightConstraint.constant = 39
                self.followContainerView.isHidden = false
                self.userMessageBtnOutlet.isHidden = true
            }else if  modelData?.followStatus == 0 {
                self.followContainerViewHeightConstraint.constant = 0
                self.followContainerView.isHidden = true
                self.userMessageBtnOutlet.isHidden = true
            }else{
                self.followContainerViewHeightConstraint.constant = 39
                self.followContainerView.isHidden = false
                if modelData?.isStar == 0{
                    self.userMessageBtnOutlet.isHidden = false
                }else{
                    if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool {
                        if isStarVerified {
                            self.userMessageBtnOutlet.isHidden = false
                        }else{
                            if modelData?.isStar == 1 && modelData?.subscriptionAmount != -1  && modelData?.subscriptionAmount != nil && modelData?.subscriptionAmount != 0.0 {
                                
                            }else{
                                self.followContainerViewHeightConstraint.constant = 0
                                self.followContainerView.isHidden = true
                            }
                                
                            self.userMessageBtnOutlet.isHidden = true
                        }
                    }else{
                        if modelData?.isStar == 1 && modelData?.subscriptionAmount != -1  && modelData?.subscriptionAmount != nil && modelData?.subscriptionAmount != 0.0 {
                        }else{
                            self.followContainerViewHeightConstraint.constant = 0
                            self.followContainerView.isHidden = true
                        }
                        self.userMessageBtnOutlet.isHidden = true
                    }
                
            }
            }
            //self.followContainerTopLayOutConstraint.constant = 12.0
            self.layoutIfNeeded()
        }
        guard let data = modelData else {return}
        
        if isMine {
            if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                if businessProfileCreated {
                   self.userNameLabel.text = "@\(data.businessDetails.first?.businessUserName ?? "")"
                    self.fullNameLabel.text = data.businessDetails.first?.businessName
                 }else {
                    self.userNameLabel.text = "@\(data.userName ?? "")"
                    self.fullNameLabel.text = data.firstName + " " + data.lastName
                }
            }
            
            /*
             Bug Name:- on first login on profile it had some hard coded detail
             Fix Date:- 06/05/21
             Fixed By:- Nikunj C
             Description of Fix:- add condition is not saved userdefault
             */
            
            else{
                self.userNameLabel.text = "@\(data.userName ?? "")"
                self.fullNameLabel.text = data.firstName + " " + data.lastName
            }
        }else{
            if data.businessProfileActive == 1{
                self.userNameLabel.text =  "@\(data.businessDetails.first?.businessName ?? "")"
             }else {
                 self.userNameLabel.text = "@\(data.userName ?? "")"
                self.fullNameLabel.text = data.firstName + " " + data.lastName
            }
        }
        
        self.businessAddressLbl.text = "\(data.businessDetails.first?.businessStreetAddress ?? ""),\(data.businessDetails.first?.businessCity ?? ""),\(data.businessDetails.first?.businessZipCode ?? "")"
        
        self.businessBioText = data.businessDetails.first?.businessBio ?? ""
        self.businessBio.text = data.businessDetails.first?.businessBio
        self.websiteBtnOutlet.setTitle(data.businessDetails.first?.businessWebsite, for: .normal)
        
        if data.status == nil || data.status == ""{
            self.statusText = AppConstants.defaultStatus
            self.userStatus.text = AppConstants.defaultStatus
        }else{
            self.statusText = data.status ?? ""
            self.userStatus.text = data.status
        }
        linkHandler()
        /*Bug Name :- cover image not show
          Fix Date :- 30/04/2021
          Fixed By :- Nikunj C
          Description Of Fix :- set cover image */
        let fullName = data.firstName + " " + data.lastName
        /*
         Bug Name:- Show the intials for default profile pic
         Fix Date:- 12/05/21
         Fix By  :- Jayram G
         Description of Fix:- setting initials image when user not uploaded profile pic
         */
        if isMine {
            if data.businessProfileActive == 1 {
                Helper.addedUserImage(profilePic: data.businessDetails.first?.businessProfileImage, imageView: self.profileImageView, fullName: data.businessDetails.first?.businessName ?? "D")
                
                /*
                 Feat Name:- Back button and other button are not being displayed when there is an empty cover photo
                 Feat Date:- 11/07/21
                 Feat By  :- Nikunj C
                 Description of Feat:- for aws link show dubly banner
                 */
                
                if (data.businessDetails.first?.businessCoverImage?.contains(".amazonaws.com")) == true{
                    self.coverImageView.image = Utility.setDefautlCoverImage()
                }else{
                self.coverImageView.setImageOn(imageUrl: data.businessDetails.first?.businessCoverImage, defaultImage: Utility.setDefautlCoverImage())
                }
            }else{
                
                /*
                 Feat Name:- Back button and other button are not being displayed when there is an empty cover photo
                 Feat Date:- 11/07/21
                 Feat By  :- Nikunj C
                 Description of Feat:- for aws link show dubly banner
                 */
                
                Helper.addedUserImage(profilePic: data.profilePic, imageView: self.profileImageView, fullName: fullName)
                if (data.coverImage?.contains(".amazonaws.com")) == true{
                    self.coverImageView.image = Utility.setDefautlCoverImage()
                }else{
                self.coverImageView.setImageOn(imageUrl: data.coverImage, defaultImage: Utility.setDefautlCoverImage())
                }
            }
            
        }else{
            if data.isBlocked {
                Helper.addedUserImage(profilePic: data.profilePic, imageView: self.profileImageView, fullName: data.firstName + " " + data.lastName)
                self.coverImageView.image = Utility.setDefautlCoverImage()
            }else {
                if data.businessProfileActive == 1 {
                    Helper.addedUserImage(profilePic: data.businessDetails.first?.businessProfileImage, imageView: self.profileImageView, fullName: data.businessDetails.first?.businessName ?? "P")
                    
                    /*
                     Feat Name:- Back button and other button are not being displayed when there is an empty cover photo
                     Feat Date:- 11/07/21
                     Feat By  :- Nikunj C
                     Description of Feat:- for aws link show dubly banner
                     */
                    
                    if (data.businessDetails.first?.businessCoverImage?.contains(".amazonaws.com")) == true{
                        self.coverImageView.image = Utility.setDefautlCoverImage()
                    }else{
                    self.coverImageView.setImageOn(imageUrl: data.businessDetails.first?.businessCoverImage, defaultImage: Utility.setDefautlCoverImage())
                    }
                }else{
                    Helper.addedUserImage(profilePic: data.profilePic, imageView: self.profileImageView, fullName: fullName)
                    
                    /*
                     Feat Name:- Back button and other button are not being displayed when there is an empty cover photo
                     Feat Date:- 11/07/21
                     Feat By  :- Nikunj C
                     Description of Feat:- for aws link show dubly banner
                     */
                    
                    if (data.coverImage?.contains(".amazonaws.com")) == true{
                        self.coverImageView.image = Utility.setDefautlCoverImage()
                    }else{
                        self.coverImageView.setImageOn(imageUrl: data.coverImage, defaultImage: Utility.setDefautlCoverImage())
                    }
                    
                }
            }
        }
        
        self.subscriptionsCountLabel.text = "\(data.subscriptionsCount)"
        self.postCountLabel.text = "\(data.postsCount)"
        self.followersCountLabel.text = "\(data.followersCount)"
        self.followingCountLabel.text = "\(data.followingCount)"
        self.setFollowButton(modelData: modelData!)
        
        
        
        DispatchQueue.main.async {
            
            self.updateConstraints()
            self.layoutIfNeeded()
        }
        
    }
    
    ///set follow button of cell
    func setFollowButton(modelData: UserProfileModel){
        self.followButtonOutlet.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        self.subscribeBtnOutlet.makeCornerRadious(readious: 7)
//        self.followContainerView.makeShadowEffect(color: UIColor.lightGray)
        let borderColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
        //        self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
        if modelData.followStatus == 0{
            var title: String = "Follow".localized
            if modelData.privicy == 1{
                title = "Request".localized
                
            }
            self.followButtonOutlet.makeBorderWidth(width: 1, color: borderColor)
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(borderColor, for: .normal)
            self.followButtonOutlet.backgroundColor = UIColor.white
        }else{
            var title: String = "Following".localized
            if modelData.followStatus == 2{
                title = "Requested".localized
            }
            self.followButtonOutlet.setTitle(title, for: .normal)
            self.followButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            self.followButtonOutlet.backgroundColor = borderColor
        }
        
        /*
         Bug Name:- hide subscribe button if star user have no subscription plan
         Fix Date:- 07/05/21
         Fixed By:- Nikunj C
         Description of Fix:- if subscriptionAmount is nil then hode button
         */
        if modelData.isStar == 1 && modelData.subscriptionAmount != -1  && modelData.subscriptionAmount != nil && modelData.subscriptionAmount != 0.0{
            self.subscribeBtnOutlet.tintColor = UIColor.white
            self.subscribeBtnOutlet.backgroundColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
            self.subscribeBtnOutlet.makeCornerRadious(readious: 7.0)
            if !Utility.isDarkModeEnable(){
                self.subscribeBtnOutlet.makeShadowEffect(color: UIColor.lightGray)
            }
            self.subscribeBtnOutlet.backgroundColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
            followButtonOutlet.isHidden = false
            self.earnedCoinsBtnOutlet.isHidden = true
            subscribeBtnOutlet.isHidden = false
            
            
            var fullString = NSMutableAttributedString(string: "Subscribe for".localized + " \(modelData.subscriptionAmount ?? 0.0) ")
            subscribeBtnOutlet.semanticContentAttribute = UIApplication.shared
                .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

            
            if modelData.isSubscribe == 1 {
                self.subscribeBtnOutlet.setTitleColor(.white, for: .normal)
                fullString = NSMutableAttributedString(string: "Cancel Subscription".localized)
            }else {
                self.subscribeBtnOutlet.tintColor = Helper.hexStringToUIColor(hex: AppColourStr.followColor)
                self.subscribeBtnOutlet.makeBorderWidth(width: 1, color: borderColor)
                self.subscribeBtnOutlet.makeCornerRadious(readious: 7.0)
                if !Utility.isDarkModeEnable(){
                    self.subscribeBtnOutlet.makeShadowEffect(color: UIColor.lightGray)
                }
                if #available(iOS 13.0, *) {
                    self.subscribeBtnOutlet.backgroundColor = UIColor.systemBackground
                } else {
                    self.subscribeBtnOutlet.backgroundColor = UIColor.white
                    // Fallback on earlier versions
                }
                if #available(iOS 13.0, *) {
                    self.subscribeBtnOutlet.setTitleColor(.label, for: .normal)
                } else {
                    self.subscribeBtnOutlet.setTitleColor(.black, for: .normal)
                }
            }
            self.subscribeBtnOutlet.setAttributedTitle(fullString, for: .normal)
            self.subscribeBtnOutlet.setAttributedTitle(fullString, for: .selected)
            
        }else {
            self.subscribeBtnOutlet.isHidden = true
        }
    }
    @IBAction func coinAction(_ sender: Any) {
        delegate?.moveToCoinVc()
    }
    
    
    @IBAction func followButtonAction(_ sender: Any) {
        delegate?.didFollowButtonTap()
    }
    
    @IBAction func walletAction(_ sender: UIButton) {
        delegate?.moveToWalletVc()
    }
    
    @IBAction func subscribeBtnAction(_ sender: UIButton) {
        delegate?.subscribeUserAction()
    }
    
    @IBAction func subscribeListBtnAction(_ sender: UIButton) {
        delegate?.subscribersListAction()
    }
    
    @IBAction func transactionAction(_ sender: UIButton) {
        delegate?.moveToTransactionVc()
    }
    
    @IBAction func qrCodeAction(_ sender: UIButton) {
        delegate?.moveToQrCodeVc()
    }
    
    @IBAction func activityBtnAction(_ sender: UIButton) {
        delegate?.moveToActivityVc()
    }
    
    @IBAction func switchingAccount(_ sender: UIButton) {
        delegate?.switchingAccountVc()
    }
    
    @IBAction func emailAction(_ sender: UIButton) {
        delegate?.openingEmailAction()
    }
    
    @IBAction func messageAction(_ sender: UIButton) {
        delegate?.openMessageAction()
    }
    
    @IBAction func callAction(_ sender: UIButton) {
        delegate?.openingCallAction()
    }
    
    @IBAction func businessWebsiteAction(_ sender: UIButton) {
        delegate?.businessWebsiteAction()
    }
    
    @IBAction func openLocationAction(_ sender: UIButton) {
        delegate?.openAddressLocation()
    }
    
}
