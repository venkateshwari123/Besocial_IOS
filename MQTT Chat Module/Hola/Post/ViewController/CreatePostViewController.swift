//
//  CreatePostViewController.swift
//  dub.ly
//
//  Created by Shivansh on 1/31/19.
//  Copyright © 2019 Rahul Sharma. All rights reserved.
//

import UIKit
import FBSDKShareKit
protocol updatePostDelegate {
    func updatePost(updaetedModel: NewPostModel)
}
class CreatePostViewController: UIViewController,UITextViewDelegate {

    var searchViewModel = SearchViewModel()
    var currencyViewModelObj = currencyViewModel()
    var selectedImage:UIImage?
    var postDetailsCell:PostingTableViewCell?
    var newPostDetails:NewPostModel?
    var isForVideo = true
    var mediaPath:String = ""
    var myChannels = [ChannelModel]()
    var showChannels = false
    var isPaidPost = false
    var selectedAmount = "0"
    var isSearchPeople = false
    var selectedAudio:Audio?
    var isFromRecording: Bool = false
    var postTypeId = ""
    var postType = "Regular".localized
    var businessLink = "Link here".localized
    var productPrice:Double = 0.0
    var businessButtonText = ""
    var businessButtonColor = ""
    var isEdit: Bool = false
    var socialModel: SocialModel?
    var caption: String = ""
    var businessCurrency:String = ""
    let local = Locale.current
    var currencySymbol:String?
    var updateDeleagetObj:updatePostDelegate?
    var editPostCallback:((SocialModel)->())?
    
    @IBOutlet weak var viewForSearchResults: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var shareBtnOutlet: UIBarButtonItem!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.businessCurrency = local.currencyCode ?? ""
        self.currencySymbol = local.currencySymbol ?? ""
        // Do any additional setup after loading the view.
        getAmountList()
        newPostDetails = NewPostModel()
        newPostDetails?.isVideo = isForVideo
        newPostDetails?.mediaPath = mediaPath
        newPostDetails?.selectedAudio = selectedAudio
        
        /*
         Bug Name:- Title shoukd be edit post for editing a post
         Fix Date:- 12th Jul 2021
         Fixed By:- Nikunj C
         Description of Fix:- for edit change title and remove channle api call
         */
        
        if self.isEdit{
             self.setPostDetailModel()
            self.shareBtnOutlet.title = "Save".localized
            self.navigationItem.title = "Edit Post".localized
        }else{
            self.shareBtnOutlet.title = "Share".localized
            self.navigationItem.title = "Share To".localized
        }

        self.postTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addGestureForView()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        if self.businessLink == ""{
            businessLink = "Link here".localized
        }
           self.postTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addGestureForView() {
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGest.cancelsTouchesInView = false
        tapGest.delegate = self
        self.viewForSearchResults.addGestureRecognizer(tapGest)
    }
    
    @objc func dismissKeyboard() {
        self.viewForSearchResults.isHidden = true
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        postDetailsCell?.captionTextView.delegate = self
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    func getAmountList() {
        let url = AppConstants.coinAmount
        self.currencyViewModelObj.getCoinsList(strUrl: url) { (success, error) in
            print(self.currencyViewModelObj.coinAmountsListArray)
            DispatchQueue.main.async {
            self.postTableView.reloadData()
            }
        }
    }
    
    func setPostDetailModel(){
        self.newPostDetails?.isEdit = true
        self.newPostDetails?.postId = socialModel?.postId
        if let data = socialModel,let isComment = data.allowComment, let isDownload = data.allowDownload {
            self.newPostDetails?.allowComment = isComment
            self.newPostDetails?.allowDownload = isDownload
        }
        if let data = socialModel , let isPaid = data.isPaid as? Bool {
            self.switchTap(isOn: isPaid, amount: "\(data.postAmount ?? 0)")
        }
        self.newPostDetails?.placeId = socialModel?.placeId ?? ""
        if let channelId = socialModel?.channelId, channelId != ""{
            let selectedChannel = ChannelModel(socialModel: socialModel!)
            self.newPostDetails?.channel = selectedChannel
            self.newPostDetails?.category = selectedChannel.category!
        }else{
            self.newPostDetails?.channel = nil
            showChannels = false
            newPostDetails?.category = CategoryListModel(socialModel: socialModel!)
        }
        if let address = AddressModel(socialModel: socialModel!) as? AddressModel {
            newPostDetails?.selectedAddress = address
            newPostDetails?.placeId = address.addressId
            newPostDetails?.location = address.addressLine1
            newPostDetails?.selectedAddress?.addressLine1 = address.addressLine1
        }
         self.caption = (socialModel?.title)!
    }
    
    @IBAction func playPauseVideoBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func selectChannelBtnAction(_ sender: Any) {
        let selectedBtn = sender as! UIButton
        selectedChannel(atIndex:selectedBtn.tag)
    }
    
    func selectedChannel(atIndex:Int) {
        let selectedChannel = self.myChannels[atIndex]
        self.newPostDetails?.channel = selectedChannel
        self.newPostDetails?.category = selectedChannel.category!
        postDetailsCell?.categoryNameLabel.text = selectedChannel.category?.categoryName
        self.postTableView.reloadData()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            
            if textView.text == "Write a caption".localized + "..."{
                textView.text = nil
            }
            if #available(iOS 13.0, *) {
                textView.textColor = .label
            } else {
                textView.textColor = #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1)
            }
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a caption".localized + "..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            removeTableData()
            dismissKeyboard()
            return false
        }
        if textView.text.count + (text.count - range.length) <= 500{
            
                return true
        }else {
            Helper.showAlertFromTop(showOnView:self.view, message:"Maximum of 100 characters".localized)
            return false
        }
            
        
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        let stringArray = textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        
        //let words = textView.text.byWords
        if stringArray.last == nil || textView.text == "" {
            removeTableData()
        } else {
            let lastString = stringArray.last!
            
            if lastString == "" {
                removeTableData()
                return
            }
            
            if lastString.count > 0 {
                if lastString.first == "@",lastString.count > 1 {
                    isSearchPeople = true
                    var removeSymbol = lastString
                    removeSymbol = String(removeSymbol.dropFirst())
                    self.searchViewModel.peopleOffset = -40
                    getPeopleService(searchString:removeSymbol)
                } else if lastString.first == "#",lastString.count > 1 {
                     isSearchPeople = false
                    
                    var removeSymbol = lastString
                        removeSymbol = String(removeSymbol.dropFirst())
                    self.searchViewModel.tagOffset = -40
                        getTagsService(searchString: removeSymbol)
                } else {
                    removeTableData()
                }
            }
        }
    }
    
    //MARK:- Buttons Action
    @IBAction func addlocationBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let searchLocVc = storyboard.instantiateViewController(withIdentifier: "SearchLocationViewController") as! SearchLocationViewController
        searchLocVc.delegate = self;
        searchLocVc.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.pushViewController(searchLocVc, animated: true)
    }
    
    
 
    
    @objc override func keyboardWillShow(_ notification:Notification) {
//        self.viewForSearchResults.isHidden = false
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            searchTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc override func keyboardWillHide(_ notification:Notification) {
//        self.viewForSearchResults.isHidden = true
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
//            searchTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @IBAction func postBtnAction(_ sender: Any) {
        //checking mandatory things before posting.
        self.view.endEditing(true)
        newPostDetails?.isPaid = self.isPaidPost
        newPostDetails?.postAmount = (selectedAmount as NSString).integerValue
        if (self.postDetailsCell?.captionTextView.text!)! == "Write a caption".localized + "..." {
            newPostDetails?.caption = ""
        }else{
            newPostDetails?.caption = (self.postDetailsCell?.captionTextView.text!)!
        }
        if self.isFromRecording{
            newPostDetails?.height = Int(self.view.frame.size.width)
        }else{
            newPostDetails?.height = Int(self.view.frame.size.height)
        }
        newPostDetails?.width = Int(self.view.frame.size.width)
 
        if isForVideo && !self.isEdit{
            newPostDetails?.image = postDetailsCell?.shareImageView.image
        }
 
        if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
            if businessProfileCreated {
                newPostDetails?.businessPostTypeId = self.postTypeId
           
               // newPostDetails?.businessUrl = self.businessLink
                if postType != "Regular".localized{
                    if self.businessLink == "Link here".localized {
                        Helper.showAlertFromTop(showOnView:self.view, message:"Please enter link".localized)
                        return
                     }else {
                        newPostDetails?.businessUrl = self.businessLink
                     }
                     if productPrice == 0.0 {
                    newPostDetails?.businessPrice = nil
                    newPostDetails?.businessCurrency = ""
                    }else {
                        newPostDetails?.businessCurrency = self.currencySymbol ?? ""
                        newPostDetails?.businessPrice = self.productPrice
                    }
                    if self.businessButtonText == "" {
                        Helper.showAlertFromTop(showOnView: self.view, message: "Please choose button text".localized)
                         return
                    }else {
                       newPostDetails?.businessButtonText = self.businessButtonText
                    }
                    newPostDetails?.businessButtonColor = self.businessButtonColor
                  }else {
                    newPostDetails?.businessPrice = nil
                    newPostDetails?.businessPostTypeId = self.postTypeId
                    newPostDetails?.businessCurrency = ""
                    newPostDetails?.businessUrl = ""
                    newPostDetails?.businessButtonText = ""
                 }
          }
         }
     if self.isEdit{
        if AppConstants.appType == .picoadda {
            /*
             Bug Name:- Posting not working when we post from other tabs
             Fix Date:- 25 Aug 2021
             Fixed By:- Jayaram G
             Description of Fix:- posting from viewcontroller objct removed observers
             */
            if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                    return
                }
                guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return}
                homeVC.uploadNewPost(newPostModel: newPostDetails)
            }
        }else{
            if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                    return
                }
                guard let homeVC = swipeNav.viewControllers.first as? PostDetailsViewController else {return}
                homeVC.uploadNewPost(newPostModel: newPostDetails)
            }
//            NotificationCenter.default.post(name: NSNotification.Name("createNewPost"), object: newPostDetails)

        }
                /*
                 Bug Name:- Application is struck on constantly clicking on edit post and then clicking on the back button multiplte times
                 Fix Date:- 21st june 2021
                 Fixed By:- Nikunj C
                 Description of Fix:- make root view controller instead of pop view as it some time store in stack and make issue.
                 */
                if let callBack = self.editPostCallback{
                    callBack(self.socialModel!)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
                if let profileVC : ProfileViewController = self.navigationController?.viewControllers.filter({$0.isKind(of: ProfileViewController.self)}).first as? ProfileViewController{
                    profileVC.isNotFromTabBar = true
                    let appdelegate = (UIApplication.shared.delegate) as? AppDelegate
                    if AppConstants.appType == .picoadda {
                        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                        let tabbar : TabbarController = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TabBarVC) as! TabbarController
                        tabbar.selectedIndex = 4
                        appdelegate?.window?.rootViewController = tabbar
                    }else{
                        let tabbar : DublyTabbarViewController = UIStoryboard.init(name: "DublyTabbar", bundle: nil).instantiateViewController(withIdentifier: String(describing: DublyTabbarViewController.self)) as! DublyTabbarViewController
                        tabbar.selectedIndex = 4
                        appdelegate?.window?.rootViewController = tabbar
                    }
                }else{
                    let appdelegate = (UIApplication.shared.delegate) as? AppDelegate
                    if AppConstants.appType == .picoadda {
                        let storyBoard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
                        let tabbar : TabbarController = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.TabBarVC) as! TabbarController
                        tabbar.selectedIndex = 0
                        appdelegate?.window?.rootViewController = tabbar
                    }else{
                        let tabbar : DublyTabbarViewController = UIStoryboard.init(name: "DublyTabbar", bundle: nil).instantiateViewController(withIdentifier: String(describing: DublyTabbarViewController.self)) as! DublyTabbarViewController
                        tabbar.selectedIndex = 0
                        appdelegate?.window?.rootViewController = tabbar
                    }
                }
            }else{
                /*
                 Refactor Name:- remove category validation for upload post
                 Refactor Date:- 08/04/21
                 Refactor By  :- Nikunj C
                 Description of Refactor:- remove category validation for upload post
                 */
                /*
                 Bug Name:- Posting not working when we post from other tabs
                 Fix Date:- 24 Aug 2021
                 Fixed By:- Jayaram G
                 Description of Fix:- posting from viewcontroller objct removed observers
                 */
                if AppConstants.appType == .picoadda {
                    if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                        guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                            return
                        }
                        guard let homeVC = swipeNav.viewControllers.first as? SocialViewController else {return}
                        homeVC.uploadNewPost(newPostModel: newPostDetails)
                    }
                    self.dismiss(animated:true, completion:nil)
                }else{
                    DispatchQueue.main.async {
                        /*
                         Refactor Name:- select category is not mendatory
                         Refactor Date:- 08/04/21
                         Refactor By  :- Nikunj C
                         Description of refactor:- remove condition that show pop up if category not selected
                         
                         */
                        self.tabBarController?.selectedIndex = 0
                        if let tabController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
                            guard let swipeNav = tabController.viewControllers?[0] as? SwipeNavigationController else {
                                return
                            }
                            guard let homeVC = swipeNav.viewControllers.first as? PostDetailsViewController else {return}
                            homeVC.uploadNewPost(newPostModel: self.newPostDetails)
                        }
                        self.navigationController?.popToRootViewController(animated: false)
                        
                        
                    }
                }
                
            }
//        }
    }
    
    @IBAction func instagramShareBtnAction(_ sender: Any) {
//        shareToSocial()
        postImageToInstagram(image: (postDetailsCell?.shareImageView.image)!)

    }
    
    @IBAction func twitterShareBtnAction(_ sender: Any) {
        shareToSocial()
    }
    
    @IBAction func facebookShareBtnAction(_ sender: Any) {
//        shareToSocial()
        shareToFaceBook(image: (postDetailsCell?.shareImageView.image)!)

    }
    
    
    /*
     Bug Name:- Add Social media post share
     Fix Date:- 22/06/21
     Fix By  :- Jayram G
     Description of Fix:- updated code from dubly , improved share post
     */
    func shareToFaceBook(image: UIImage){
        let photo:SharePhoto = SharePhoto()
        if isForVideo {
            postVideoToFaceBook()
        }else{
            photo.image = image
            photo.isUserGenerated = true
            let content:SharePhotoContent = SharePhotoContent()
            content.photos = [photo]
            let sd = ShareDialog()
            sd.shareContent = content
            sd.show()
        }
     
    }
    
    func postImageToInstagram(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func postVideoToFaceBook(){
        let url = URL(string: (newPostDetails!.mediaPath))!
        if let urlData = NSData(contentsOf: url){
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath="\(documentsPath)/tempFile.mov"
            urlData.write(toFile: filePath, atomically: true)
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(filePath))
            {
                UISaveVideoAtPathToSavedPhotosAlbum((filePath), self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func video(_ videoPath: String , didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if error != nil {
                print(error)
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)


            if let lastAsset = fetchResult.firstObject as? PHAsset {
                let video = ShareVideo()
                video.videoAsset = lastAsset
                let content = ShareVideoContent()
               content.video = video
                let sd = ShareDialog()
                sd.shareContent = content
                sd.show()
            }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if error != nil {
                print(error)
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            var fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if isForVideo {
            fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        }

            if let lastAsset = fetchResult.firstObject as? PHAsset {

                let url = URL(string: "instagram://library?LocalIdentifier=\(lastAsset.localIdentifier)")!

                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    if URL(string: "https://apps.apple.com/app/instagram/id389801252?vt=lo") != nil {
                        UIApplication.shared.open(URL(string: "https://apps.apple.com/app/instagram/id389801252?vt=lo")!)
                    }
                    
                    
//                    let alertController = UIAlertController(title: "Error", message: "Instagram is not installed", preferredStyle: .alert)
//                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alertController, animated: true, completion: nil)
                }

            }
    }
    
    func shareToSocial() {
        if isForVideo {
            SocialShareHelper.shareVideo(videoUrl: newPostDetails!.mediaPath, viewContr:self)
        } else {
            SocialShareHelper.shareImage(image:(postDetailsCell?.shareImageView.image)!, vcContr:self)
        }
    }
    
    @IBAction func addToChannelToggleBtn(_ sender: Any) {
        let toggleBtn = sender as! UISwitch
        showChannels = toggleBtn.isOn
        if !showChannels {
            self.newPostDetails?.channel = nil
        }
        self.postTableView.reloadData()
    }
    
    @IBAction func allowComments(_ sender: Any) {
        let toggleBtn = sender as! UISwitch
        newPostDetails?.allowComment = toggleBtn.isOn
    }
    @IBAction func allowDownloads(_ sender: Any) {
        let toggleBtn = sender as! UISwitch
        newPostDetails?.allowDownload = toggleBtn.isOn
    }
    
    
    @IBAction func removeLocationBtnAction(_ sender: Any) {
        postDetailsCell?.locationMainLabel.text = ""
        postDetailsCell?.locationDetailLabel.text = ""
        newPostDetails?.selectedAddress =  nil
        newPostDetails?.placeId = ""
        self.postTableView.reloadData()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func openCategoryBtnAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: AppConstants.StoryBoardIds.Main, bundle: nil)
        let selectCatVc = storyboard.instantiateViewController(withIdentifier: "CategoryListViewController") as! CategoryListViewController
         selectCatVc.isForPosting = true
         selectCatVc.delegate = self
     self.navigationController?.pushViewController(selectCatVc, animated: true)
    }
}


extension CreatePostViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.postTableView) {
            if section == 1 {
                if showChannels {
                    return myChannels.count
                } else {
                    return 0
                }
            }else if section == 2 {
                var number = 0
                if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                    if businessProfileCreated {
                        if postType != "Regular".localized{
                            number = 4
                        }else {
                            number = 1
                        }
                     }else {
                        number = 0
                    }
                }
                return number
            }
            return 1
        } else {
            if isSearchPeople {
                return self.searchViewModel.peopleArray.count
            } else {
                return self.searchViewModel.hashTagArray.count
            }
        }
    }
    

    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == self.postTableView) {
           return 6
        } else {
            //search tableview.
            return 1
        }
    }
    
    func getTagsService(searchString:String){
        if searchString == ""{
            self.view.endEditing(true)

        }
        var strUrl: String = AppConstants.hashTagList + "?"
        strUrl = AppConstants.hashTagList + "?hashtag=\(searchString)&"
        searchViewModel.getSearchData(with: strUrl, type: .tag) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
                self.viewForSearchResults.isHidden = false
                
            }else if let error = error{
                print(error.localizedDescription)
//                if error.code != 204{
//                    self.view.endEditing(true)
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
//                }
//                else if error.code == 204{
//                    self.searchTableView.reloadData()
////                    self.view.endEditing(true)
//                }
                self.searchViewModel.tagOffset = self.searchViewModel.tagOffset - 40
            }
        }
    }
    
    //MARK:- Service call
    fileprivate func getPeopleService(searchString:String){
        self.searchViewModel.peopleOffset = -40
        var strUrl: String = AppConstants.searchPeople + "?"
        strUrl = AppConstants.searchPeople + "?username=\(searchString)&"
        
        searchViewModel.getSearchData(with: strUrl, type: .people) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
                self.viewForSearchResults.isHidden = false
            }else if let error = error{
                print(error.localizedDescription)
//                if error.code != 204{
                    self.viewForSearchResults.isHidden = true
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
//                }
//                else if error.code == 204{
//                     self.viewForSearchResults.isHidden = true
//                    self.searchTableView.reloadData()
//                }
                self.searchViewModel.peopleOffset = self.searchViewModel.peopleOffset - 40
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            if isSearchPeople {
                let stringArray = postDetailsCell?.captionTextView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                let lastString = stringArray!.last!
                postDetailsCell?.captionTextView.text = postDetailsCell?.captionTextView.text.replacingLastOccurrenceOfString(lastString, with:"")
                let nameWithSymbol = "@"+self.searchViewModel.peopleArray[indexPath.row].userName! + " "
                postDetailsCell?.captionTextView.text.append(nameWithSymbol)
            
            } else {
                let stringArray = postDetailsCell?.captionTextView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                let lastString = stringArray!.last!
                postDetailsCell?.captionTextView.text = postDetailsCell?.captionTextView.text.replacingLastOccurrenceOfString(lastString, with:"")
                let nameWithSymbol = self.searchViewModel.hashTagArray[indexPath.row].hashTag + " "
                postDetailsCell?.captionTextView.text.append(nameWithSymbol)
            }
            removeTableData()
        } else if (tableView == self.postTableView) {
            if indexPath.section == 1 {
                selectedChannel(atIndex:indexPath.row)
            }
        }
    }
    
    func removeTableData() {
        self.searchViewModel.peopleArray.removeAll()
        self.searchViewModel.hashTagArray.removeAll()
        self.searchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.postTableView) {
            if indexPath.section == 0 {
                
                if self.isEdit{
                    if let addr = newPostDetails?.selectedAddress{
                        postDetailsCell?.locationMainLabel.text = addr.addressLine1
                    }
                }
                var locationViewHeight = 40
                if postDetailsCell?.locationMainLabel.text != "" {
                    locationViewHeight = 80
                }
                
                if(self.myChannels.count == 0) {
                    return  CGFloat(225+locationViewHeight)
                } else {
                    
                    /*
                     Refactor Name:- Hide Channel
                     Refactor Date:- 30/03/21
                     Refactor By  :- Nikunj C
                     Discription of Refactor:- make height same for mychannel count 0 and more than 0
                     */
                    
                    return CGFloat(225+locationViewHeight)

                    
//                    return CGFloat(300+locationViewHeight)
                }
            } else if indexPath.section == 1 {
                return 50
            } else if indexPath.section == 2{
                return 50
            }else if indexPath.section == 3{
                if self.isEdit{
                    if socialModel?.isStar == 0 || socialModel?.isStar == nil{
                        return 0
                    }else{
                        if isPaidPost {
                            return 200
                        }
                        else{
                            return 40
                        }
                    }
                }else{
                    
                    if let isStarVerified  = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isVerifiedUserProfile)  as? Bool {
                        if isStarVerified {
                            if isPaidPost {
                                return 200
                            }
                            else{
                                return 40
                            }
                        }else {
                           return 0
                        }
                    }
                }
                return 40
            }else if indexPath.section == 4{
             return 130
            }else {
                return 0
            }
        }else {
             return 60
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.postTableView {
            self.view.endEditing(true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         if(tableView == self.postTableView) {
            if indexPath.section == 0  {
                if postDetailsCell == nil {
                    postDetailsCell = tableView.dequeueReusableCell(withIdentifier: "PostingTableViewCell", for:indexPath) as? PostingTableViewCell
                    postDetailsCell?.captionTextView.delegate = self
                    postDetailsCell?.postMediaBackView.makeBorderWidth(width: 1.5, color: Utility.appColor())
                    /*
                     Bug Name:- Create post media view not properly
                     Fix Date:- 14/06/21
                     Fix By  :- jayaram G
                     Description of Fix:- Added rectangle view for dubly , square for picoadda
                     */
                    if AppConstants.appType == .picoadda {
                        postDetailsCell?.postMediaWidthConstraint.constant = 120
                    }else{
                        postDetailsCell?.postMediaWidthConstraint.constant = 70
                    }
                    
                }
                
                if self.isEdit{
                    if self.isForVideo{
                        let url = self.mediaPath
                        let endIndex = url.index(url.endIndex, offsetBy: -3)
                        var truncated = url.substring(to: endIndex)
                        truncated = truncated + "jpg"
//                        postDetailsCell?.shareImageView.contentMode = UIViewContentMode.scaleAspectFill
                        postDetailsCell?.shareImageView.setImageOn(imageUrl: truncated, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    }else{
//                        postDetailsCell?.shareImageView.contentMode = UIViewContentMode.scaleAspectFit
                        postDetailsCell?.shareImageView.setImageOn(imageUrl: self.mediaPath, defaultImage: #imageLiteral(resourceName: "defaultPicture"))
                    }
                    if let addr = newPostDetails?.selectedAddress{
                        postDetailsCell?.locationMainLabel.text = addr.addressLine1
                        
                    }
                    if self.caption != ""{
                        postDetailsCell?.captionTextView.text = caption
                        self.caption = ""
                    }
                    if let channel = newPostDetails?.channel, let _ = channel.channelId{
                        postDetailsCell?.categoryNameLabel.text = channel.category?.categoryName
                    }else{
                        postDetailsCell?.categoryNameLabel.text = newPostDetails?.category.categoryName
//                        self.postDetailsCell?.addToChannelSwitch.isOn = false
                    }
                }else{
                    postDetailsCell?.shareImageView.image = selectedImage
                }
                
                if isForVideo {
                    postDetailsCell?.videoPlayPauseBtn.isHidden = false
                }
                
                if postDetailsCell?.locationMainLabel.text == "" {
                    postDetailsCell?.locationViewHeightConstraint.constant = 50
                    postDetailsCell?.viewForSelectedLocation.isHidden = true
                } else {
                    postDetailsCell?.viewForSelectedLocation.isHidden = false
                    postDetailsCell?.locationViewHeightConstraint.constant = 90
                }
                
                return postDetailsCell!
                
            } else if indexPath.section == 1 {
                
                let addChannelCell = tableView.dequeueReusableCell(withIdentifier: "PostChannelTableViewCell", for:indexPath) as! PostChannelTableViewCell
                
                let channelModel = self.myChannels[indexPath.row]
                addChannelCell.setupChannelDetails(channel:channelModel)
                addChannelCell.selectChannelBtn.tag = indexPath.row
                if(newPostDetails?.channel?.channelId == channelModel.channelId) {
                    
                    /*
                     Refactor Name:- Hide Channel
                     Refactor Date:- 30/03/21
                     Refactor By  :- Nikunj C
                     Discription of Refactor:- unselect selectedChannelBtn
                     */
                    
                    addChannelCell.selectChannelBtn.isSelected = false
                } else {
                    addChannelCell.selectChannelBtn.isSelected = false
                }
                
                return addChannelCell
            }else if indexPath.section == 2{
                let businessPostingCell = tableView.dequeueReusableCell(withIdentifier: AppConstants.CellIds.businessPostingTableViewCellId, for:indexPath) as! BusinessPostingTableViewCell
                businessPostingCell.delegateObj = self
                switch indexPath.row {
                case 0:
                    businessPostingCell.lblTitleText.text = Strings.businessPostType.localized
                    businessPostingCell.buttonOutlet.tag = 1
                    businessPostingCell.imageWidthConstraint.constant = 0
                    businessPostingCell.buttonOutlet.setTitle(self.postType, for: .normal)
                case 1:
                    businessPostingCell.lblTitleText.text = Strings.businessLink.localized
                    businessPostingCell.buttonOutlet.tag = 2
                    businessPostingCell.imageWidthConstraint.constant = 12.0
                    if self.businessLink == ""{
                        businessPostingCell.buttonOutlet.setTitle("Link here".localized, for: .normal)
                    }else {
                        businessPostingCell.buttonOutlet.setTitle(self.businessLink, for: .normal)
                    }
                case 2:
                    businessPostingCell.lblTitleText.text = Strings.productPrice.localized
                    businessPostingCell.buttonOutlet.tag = 3
                    businessPostingCell.imageWidthConstraint.constant = 0
                    businessPostingCell.buttonOutlet.setTitle("\(self.businessCurrency)"+" "+"\(self.productPrice)", for: .normal)
                default:
                    businessPostingCell.lblTitleText.text = Strings.buttonText.localized
                    businessPostingCell.buttonOutlet.tag = 4
                    businessPostingCell.imageWidthConstraint.constant = 12.0
                    businessPostingCell.buttonOutlet.setTitle(self.businessButtonText, for: .normal)
                }
                    return businessPostingCell
            } else if indexPath.section == 3 {
                let coinCell = tableView.dequeueReusableCell(withIdentifier:"CoinTableViewCell"
                    , for: indexPath) as! CoinTableViewCell
                coinCell.amountTf.text = self.selectedAmount
                coinCell.amountTf.tag = 100
                coinCell.switchPaidPost.isOn = self.isPaidPost
                coinCell.amountList = self.currencyViewModelObj.coinAmountsListArray
                coinCell.delegate = self
                coinCell.coinCollection.reloadData()
                return coinCell
            }
            else if indexPath.section == 4{
                guard let moreOptionsCell = tableView.dequeueReusableCell(withIdentifier: String(describing: MorePostingTableViewCell.self), for: indexPath) as? MorePostingTableViewCell else {return UITableViewCell()}
                if let data = newPostDetails{
                    moreOptionsCell.allowCommentsSwitch.isOn = data.allowComment
                    moreOptionsCell.allowDownloadsSwitch.isOn = data.allowDownload
                }
                return moreOptionsCell
            }else {
                    let shareCell = tableView.dequeueReusableCell(withIdentifier:"PostShareTableViewCell"
                        , for: indexPath) as! PostShareTableViewCell
                    if(self.myChannels.count == 0) {
                        shareCell.borderLineForShare.isHidden = true
                    } else {
                        shareCell.borderLineForShare.isHidden = false
                    }
                    return shareCell
                }
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier:"searchTableViewCell") as? SearchTableViewCell else {fatalError()}
            
            
            if isSearchPeople {
                cell.setPeopleData(modelData: self.searchViewModel.peopleArray[indexPath.row])
            } else {
                cell.setTagData(modelData: self.searchViewModel.hashTagArray[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            if let businessProfileCreated = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.isActiveBusinessProfile) as? Bool {
                if businessProfileCreated {
                   return 40
                }else {
                   return 0
                }
            }
            return 40.0
        }else if section == 4{
            return 40
        }else{
            return 0
        }
    }

 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.frame = CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40)
            label.text = "Business post details".localized
            label.font = Utility.Font.Bold.ofSize(17)
            label.textColor = .setColor(lightMode: AppColourStr.darkGrayColor, darkMode: AppColourStr.whiteColor)
            label.textAlignment = .left
            headerView.addSubview(label)
            return headerView
        }else if section == 4{
            let headerView = UIView()
            headerView.backgroundColor = UIColor.groupTableViewBackground
            let label = UILabel()
            label.frame = CGRect(x: 10, y: 0, width: self.view.frame.width, height: 40)
            label.text = "Privacy Settings".localized
            label.font = Utility.Font.Bold.ofSize(17)
            label.textColor = .setColor(lightMode: AppColourStr.darkGrayColor, darkMode: AppColourStr.whiteColor)
            label.textAlignment = .left
            headerView.addSubview(label)
            return headerView
        }else {
            return UIView()
        }
    }
}

extension CreatePostViewController:CoinCellDelegate{
    func switchTap(isOn: Bool, amount: String) {
        self.isPaidPost = isOn
        self.selectedAmount = amount
        self.postTableView.reloadRows(at: [IndexPath(row: 0, section: 3)], with: .none)
    }
    
    func coinSelected(amount:String) {
        self.selectedAmount = amount
    }
}

extension CreatePostViewController:CategoryListViewControllerDelegate {
    func selectedCategory(categoryListModel: CategoryListModel) {
        postDetailsCell?.categoryNameLabel.text = categoryListModel.categoryName
        if(newPostDetails?.channel?.category?.categoryId != categoryListModel.categoryId) {
            self.newPostDetails?.channel = nil
            self.postDetailsCell?.addToChannelSwitch.isOn = false
            showChannels = false
        }
        newPostDetails?.category = categoryListModel
        self.postTableView.reloadData()
    }
}

extension CreatePostViewController {
    func getAllMyChannels() {
        let PostedByApi = SocialAPI()
        PostedByApi.getSocialData(withURL: "channel", params: [:]) { (modelArray, customError) in
            if modelArray != nil {
                if let allChanels = modelArray as? [[String:Any]] {
                    for channel in allChanels.enumerated() {
                       let  channelModel = ChannelModel(channelData: channel.element)
                        self.myChannels.append(channelModel)
                    }
                }
            }
            if self.isEdit{
                if let channel = self.newPostDetails?.channel, let _ = channel.channelId{
                    self.showChannels = true
                    self.postDetailsCell?.addToChannelSwitch.isOn = true
                }
            }
            self.postTableView.reloadData()
            print("model array")
            print("custom error")
        }
    }
}

extension StringProtocol where Index == String.Index {
    var byWords: [SubSequence] {
        var byWords: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, _ in
            byWords.append(self[range])
        }
        return byWords
    }
}


extension String
{
    func replacingLastOccurrenceOfString(_ searchString: String,
                                         with replacementString: String,
                                         caseInsensitive: Bool = true) -> String
    {
        let options: String.CompareOptions
        if caseInsensitive {
            options = [.backwards, .caseInsensitive]
        } else {
            options = [.backwards]
        }
        
        if let range = self.range(of: searchString,
                                  options: options,
                                  range: nil,
                                  locale: nil) {
            
            return self.replacingCharacters(in: range, with: replacementString)
        }
        return self
    }
}

extension CreatePostViewController: SearchAddressDelegate {
    func searchAddressDelegateMethod(_ addressModel: AddressModel) {
         newPostDetails?.selectedAddress = addressModel
         newPostDetails?.placeId = addressModel.addressId
        newPostDetails?.location = addressModel.addressLine1
         newPostDetails?.selectedAddress?.addressLine1 = addressModel.addressLine1
         postDetailsCell?.locationMainLabel.text = addressModel.addressLine1
         postDetailsCell?.locationDetailLabel.text = addressModel.addressLine2
         self.postTableView.reloadData()
    }
}


extension CreatePostViewController: businessPostingCellDelegate{
    func buttonAction(btnTag: Int) {
        switch btnTag {
        case 1:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessProductTypeVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessProductTypeListViewControllerVcId) as! BusinessProductTypeListViewController
            businessProductTypeVc.post = self.postType
            self.navigationController?.pushViewController(businessProductTypeVc, animated: true)
        case 2:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let addLinkVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.addLinkViewControllerVcId) as! AddLinkViewController
            if self.businessLink != "Link here".localized{
                addLinkVc.businessLink = self.businessLink
            }
            self.navigationController?.pushViewController(addLinkVc, animated: true)
        case 3:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let addPriceVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.addPriceViewControllerVcId) as! AddPriceViewController
            addPriceVc.businessPrice = self.productPrice
            addPriceVc.currencySymbol = self.currencySymbol
            addPriceVc.currency = self.businessCurrency
            self.navigationController?.pushViewController(addPriceVc, animated: true)
        default:
            let mainStoryboard = UIStoryboard(name: AppConstants.StoryBoardIds.Settings, bundle: nil)
            let businessButtonTextVc = mainStoryboard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.businessButtonTextViewControllerVcId) as! BusinessButtonTextViewController
            businessButtonTextVc.businessButton.buttonText = self.businessButtonText
            businessButtonTextVc.businessButton.buttonColor = self.businessButtonColor
            self.navigationController?.pushViewController(businessButtonTextVc, animated: true)
        }
    }
 }
 
extension CreatePostViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let isTableView = touch.view?.isKind(of: UITableView.self) else{
            return true
        }
        return isTableView
    }
}
extension CreatePostViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var txtAfterUpdate : String = ""
        if let text = textField.text as NSString? {
            txtAfterUpdate = text.replacingCharacters(in: range, with: string)
        }
        if textField.tag == 100 {
        self.selectedAmount = txtAfterUpdate
        }
        return true
    }
}
