//
//  CommentsViewController.swift
//  MQTT Chat Module
//
//  Created by 3Embed Software Tech Pvt Ltd on 11/10/18.
//  Copyright © 2018 Rahul Sharma. All rights reserved.
//

import UIKit

protocol CommentsViewControllerDelegate: class {
    func commentCount(count: Int)
}

class CommentsViewController: UIViewController {
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var noCommentsView: UIView!
    @IBOutlet weak var noCommentsLbl: UILabel!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var inputToolBar: UIView!
//    @IBOutlet weak var userImageButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    var userId: String?
    
    var commentsViewModel = CommentsViewModel()
    var postDetailModel:SocialModel?
    var canServiceCall: Bool = false
    var postId: String?
    var postIndex : Int = 0
    var ipAddress:String = ""
    var city:String = ""
    var country: String = ""
    var checkingText:String = ""
    var isTextViewActive: Bool = false
    var noOfPostArray = [[String:Int]]()
    
    var isSearchPeople = false
    
    var newCommentCount: Int = 0
    var delegate: CommentsViewControllerDelegate?
    
    struct cellIdentifier {
        static let commentTableViewCell = "commentTableViewCell"
        static let searchTableViewCell = "searchTableViewCell"
    }
    
    struct storyboardId {
        static let postedByController = "postedByController"
        static let profileViewController = "ProfileViewController"
    }
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentServiceCall()
        setViewUI()
        self.sendButton.isEnabled = false
        self.commentTableView.estimatedRowHeight = 120
        self.commentTableView.rowHeight = UITableView.automaticDimension
        // *** Customize GrowingTextView ***
        textView.layer.cornerRadius = 4.0
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        if !Utility.isDarkModeEnable(){
            self.searchTableView.makeShadowEffect(color: UIColor.lightGray)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchIpDetails()
        self.inputToolBar.backgroundColor = .setColor(lightMode: AppColourStr.inputToolBarBackground, darkMode: AppColourStr.blackColor)
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.layer.zPosition = 0;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        self.userImageButton.makeCornerRadious(readious: self.userImageButton.frame.size.width / 2)
        self.userImageView.makeCornerRadious(readious: userImageView.frame.size.width / 2)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textView.becomeFirstResponder()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    
    func fetchIpDetails() {
        if let url = URL(string: "http://www.geoplugin.net/json.gp") {
            do {
                let contents = try String(contentsOf: url)
                
                if let data = contents.data(using: String.Encoding.utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                            print(json)
                            // Helper.storeIPDetails(ipdetails:json)
                            if let ip = json["geoplugin_request"] as? String {
                            self.ipAddress = ip
                            }
                            if let currentCity = json["geoplugin_city"] as? String {
                                city = currentCity
                            }
                            if let currentCountry = json["geoplugin_countryName"] as? String {
                                country = currentCountry
                            }
                         }
                    } catch {
                        print("Something went wrong")
                    }
                }
            } catch {
                // contents could not be loaded
            }
        } else {
            // the URL was bad!
        }
    }
    
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            if self.commentsViewModel.commentModelArray.count != 0{
                let indexPath = IndexPath(row: self.commentsViewModel.commentModelArray.count - 1, section: 0)
                self.commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
//        DispatchQueue.main.async {
//            if self.commentsViewModel.commentModelArray.count != 0{
//                let indexPath = IndexPath(row: 0, section: 0)
//                self.commentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//        }
    }
    
    func setViewUI(){
        if let image = UserDefaults.standard.value(forKey: AppConstants.UserDefaults.userImage) as? String{
            Helper.addedUserImage(profilePic: image, imageView: self.userImageView, fullName: Utility.getUserFullName() ?? "P")
        }
        self.navigationItem.title = "Comments".localized
        textView.text = "Write a comment".localized + "..."
        if Utility.isDarkModeEnable(){
            textView.textColor = .white
        }else{
            textView.textColor = .lightGray
        }
        
        self.noCommentsLbl.text = "No".localized + " " + "comments".localized + " !."
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if keyboardHeight == 0{
                self.searchTableView.isHidden = true
            }
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
            self.scrollToBottom()
        }
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    

    //MARK:- Button Action
    
    @IBAction func sendButtonAction(_ sender: Any) {
        if textView.text != "", let comment = self.textView.text{
            guard let id = postId else {return}
            guard let userId = self.userId else{return}
            let strUrl = AppConstants.comment
            
            let stringArray = comment.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
            var hashTagsStrings = String()
            var arrayOfTaggedUsers = [String]()
            
            var index: Int = 0
            for eachString in stringArray.enumerated() {
                if eachString.element.first == "#" {
                    if eachString.element.count > 2 {
                        var hashtag = eachString.element
                        hashtag.removeFirst()
                        if index == 0{
                            index = 1
                            hashTagsStrings = hashtag
                        }else{
                            hashTagsStrings = "\(hashTagsStrings),\(hashtag)"
                        }
                    }
                }
                
                if eachString.element.first == "@" {
                    if eachString.element.count > 2 {
                        var userName = eachString.element
                        userName.removeFirst()
                        arrayOfTaggedUsers.append(userName)
                    }
                }
            }
            
            let params: [String : Any] = ["comment":comment,
                                          "hashTags":hashTagsStrings,
                                          "userTags":arrayOfTaggedUsers,
                                          "postedBy":userId,
                                          "postId":id]
            self.textView.text = ""
            self.newCommentCount = self.newCommentCount + 1
            commentsViewModel.postCommentServiceCall(strUrl: strUrl, params: params) { (success, error) in
                if success{
                //    self.postDetailViewModel.socialModelArray[self.postIndex].commentCount += 1
                        self.noCommentsView.isHidden = true
                    let totalCount = self.postDetailModel?.commentCount
                    self.postDetailModel?.commentCount = totalCount! + 1
                    DispatchQueue.main.async {
                        self.commentTableView.reloadData()
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshHomeScreen"), object: nil)
//                    self.scrollToBottom()
                }else{
                    Helper.showAlertViewOnWindow("Message".localized, message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    
    @IBAction func userImageButtonAction(_ sender: Any) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isSelf = true
        profileVC.isNotFromTabBar = true
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func cellUserImageTap(sender: UIButton){
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        let index = sender.tag
        let data = self.commentsViewModel.commentModelArray[index]
        profileVC.memberId = data.commentedByUserId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func profileImageBtn_Action(_ sender: UIButton) {
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        let index = sender.tag
        let data = self.commentsViewModel.commentModelArray[index]
        profileVC.memberId = data.commentedByUserId
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    @IBAction func backbuttonAction(_ sender: Any) {
        if self.delegate != nil && self.newCommentCount > 0{
            self.delegate?.commentCount(count: self.newCommentCount)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Service call
    func commentServiceCall(){
        guard let id = self.postId else {return}
        let strURL: String = AppConstants.comment + "?postId=\(id)"
        
        Helper.showPI()
        
        let params = ["ip":self.ipAddress,
                      "city": self.city,
                      "country":self.country]
        commentsViewModel.commentServiceCall(strUrl: strURL,params: params) { (success, error, canServiceCall) in
            if success{
                print("success")
                if self.commentsViewModel.commentModelArray.count == 0 {
                    self.noCommentsView.isHidden = false
                }else {
                    self.noCommentsView.isHidden = true
                }
                self.commentTableView.reloadData()
//                self.scrollToBottom()
            }else if let error = error{
                if error.code != 204{
                    Helper.showAlertViewOnWindow(Strings.error.localized, message: error.localizedDescription)
                }
                self.commentsViewModel.offset = self.commentsViewModel.offset - 20
            }
            self.canServiceCall = canServiceCall
        }
    }
    
    func getPeopleService(searchString:String){
        self.commentsViewModel.peopleOffset = -20
        var strUrl: String = AppConstants.searchPeople + "?"
        strUrl = AppConstants.searchPeople + "?username=\(searchString)&"
        
        commentsViewModel.getSearchData(with: strUrl, type: .people) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
            }else if let error = error{
                print(error.localizedDescription)
                //                if error.code != 204{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                //                }else if error.code == 204{
                //                    self.searchTableView.reloadData()
                //                }
                self.commentsViewModel.peopleOffset = self.commentsViewModel.peopleOffset - 20
            }
            self.showOrRemoveSearchTableView()
        }
    }
    
    
    func getTagsService(searchString:String){
        var strUrl: String = AppConstants.hashTagList + "?"
        strUrl = AppConstants.hashTagList + "?hashtag=\(searchString)&"
        commentsViewModel.getSearchData(with: strUrl, type: .tag) { (success, error, canServiceCall) in
            if success{
                self.searchTableView.reloadData()
            }else if let error = error{
                print(error.localizedDescription)
                //                if error.code != 204{
                Helper.showAlertViewOnWindow(Strings.error.localized, message: (error.localizedDescription))
                //                }else if error.code == 204{
                //                    self.searchTableView.reloadData()
                //                }
                self.commentsViewModel.tagOffset = self.commentsViewModel.tagOffset - 20
            }
            self.showOrRemoveSearchTableView()
        }
    }

    
    /// To show or remove table view based on number of item in table view
    func showOrRemoveSearchTableView(){
        if self.isSearchPeople{
            if self.commentsViewModel.peopleArray.count == 0{
                self.searchTableView.isHidden = true
            }else{
                self.searchTableView.isHidden = false
            }
        } else if self.commentsViewModel.hashTagArray.count == 0{
            self.searchTableView.isHidden = true
        }else{
            self.searchTableView.isHidden = false
        }
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    // *** Call layoutIfNeeded on superview for animation when changing height ***
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveLinear], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isTextViewActive = true
        if textView.textColor == UIColor.lightGray || textView.textColor == UIColor.white{
                textView.text = nil
            if textView.textColor == UIColor.lightGray{
                textView.textColor = #colorLiteral(red: 0.06274509804, green: 0.07843137255, blue: 0.1098039216, alpha: 1)
            }else{
                textView.textColor = UIColor.white
            }
                
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isTextViewActive = false
        if textView.text.isEmpty {
            textView.text = "Write a comment".localized + "..."
            if Utility.isDarkModeEnable(){
                textView.textColor = .white
            }else{
                textView.textColor = .lightGray
            }
            
        }
    }
        
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        let stringArray = textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        
        print(textView.text)
        
        checkingText = textView.text!
        
        if  !checkingText.replace(target: "\n", withString: " ").trimmingCharacters(in: .whitespaces).isEmpty{
             self.sendButton.isEnabled = true
        }else {
            self.sendButton.isEnabled = false
        }
        
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
                    getPeopleService(searchString:removeSymbol)
                } else if lastString.first == "#",lastString.count > 1 {
                    isSearchPeople = false
                    
                    var removeSymbol = lastString
                    removeSymbol = String(removeSymbol.dropFirst())
                    getTagsService(searchString: removeSymbol)
                } else {
                    removeTableData()
                }
            }
        }
    }
    
    func removeTableData() {
        self.commentsViewModel.peopleArray.removeAll()
        self.commentsViewModel.hashTagArray.removeAll()
        self.searchTableView.reloadData()
        self.searchTableView.isHidden = true
    }
}

//MARK:- Tbale view delegate and datasource
extension CommentsViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.commentTableView{
            return self.commentsViewModel.commentModelArray.count
        }else{
            if isSearchPeople {
                return self.commentsViewModel.peopleArray.count
            } else {
                return self.commentsViewModel.hashTagArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.commentTableView{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.commentTableViewCell) as? CommentTableViewCell else{fatalError()}
            let data = self.commentsViewModel.commentModelArray[indexPath.row]
            cell.userImageButton.tag = indexPath.row
            cell.userImageButton.addTarget(self, action: #selector(CommentsViewController.cellUserImageTap(sender:)), for: .touchUpInside)
            cell.setCellData(modelData: data)
            cell.index = indexPath.row
            cell.delegate = self
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.searchTableViewCell) as? SearchTableViewCell else{fatalError()}
            if isSearchPeople {
                cell.setPeopleData(modelData: self.commentsViewModel.peopleArray[indexPath.row])
            } else {
                cell.setTagData(modelData: self.commentsViewModel.hashTagArray[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let indexPassed: Bool = indexPath.row >= self.commentsViewModel.commentModelArray.count - 10
        if canServiceCall && indexPassed{
            canServiceCall = false
            self.commentServiceCall()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.commentTableView{
            
            /*
             Bug Name:- On typing 4 line single comment the last line is not posted
             Fix Date:- 20th June 2021
             Fixed By:- Nikunj C
             Description of Fix:- use automaticDimension instead of calculate height programatically
             */
            return UITableView.automaticDimension
        }else{
            return 55.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            if isSearchPeople {
                let stringArray = self.textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                let lastString = stringArray.last!
                self.textView.text = self.textView.text.replacingLastOccurrenceOfString(lastString, with:"")
                let nameWithSymbol = "@"+self.commentsViewModel.peopleArray[indexPath.row].userName! + " "
                self.textView.text.append(nameWithSymbol)
                
            } else {
                let stringArray = self.textView.text.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                let lastString = stringArray.last!
                self.textView.text = self.textView.text.replacingLastOccurrenceOfString(lastString, with:"")
                let nameWithSymbol = self.commentsViewModel.hashTagArray[indexPath.row].hashTag + " "
                
                /*
                 Bug Name:- On tagging a new post in the hash tag, the post count is displayed incorrectly
                 Fix Date:- 18th June 2021
                 Fixed By:- Nikunj C
                 Description of Fix:- insert hashtag name and count in noOfPostArray to show it in postedByViewController
                 */
                
                let hashTagDic = [self.commentsViewModel.hashTagArray[indexPath.row].hashTag:self.commentsViewModel.hashTagArray[indexPath.row].totalPublicPost]
                self.noOfPostArray.append(hashTagDic)
                self.textView.text.append(nameWithSymbol)
            }
            removeTableData()
        }
    }
    
    
}

//MARK:- Comment table view cell delegate
extension CommentsViewController: CommentTableViewCellDelegate{


    /*
     Bug Name:- Add readmore/readless
     Fix Date:- 22/06/21
     Fixed By:- Jayaram G
     Description of Fix:- reloading collectionview
     */
    func forYouviewmoreTapped(isViewed: Bool, index: Int) {
        self.commentsViewModel.commentModelArray[index].isExpand = isViewed
        self.commentTableView.reloadData()
    }
    
    func userNameGetClicked(name: String){
        let profileVC = ProfileViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.Profile) as ProfileViewController
        profileVC.isNotFromTabBar = true
        let tag = name.replace(target: "@", withString: "")
        profileVC.userNameTag = tag
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func hasgtagGetClicked(hasgTag: String){
        let postedbyController = PostedByViewController.instantiate(storyBoardName: AppConstants.StoryBoardIds.postedBy) as PostedByViewController
        postedbyController.hashTagName = hasgTag
        postedbyController.isHashTag = true
        
        /*
         Bug Name:- On tagging a new post in the hash tag, the post count is displayed incorrectly
         Fix Date:- 18th June 2021
         Fixed By:- Nikunj C
         Description of Fix:- insert hashtag name and count in noOfPostArray to show it in postedByViewController
         */
        var hashTagCount = 0
        for hashtag in self.noOfPostArray{
            if hashtag.keys.contains(hasgTag){
                hashTagCount = hashtag[hasgTag] ?? 0
            }
                
            
        }
        postedbyController.noofPostsCount = hashTagCount
        self.navigationController?.pushViewController(postedbyController, animated: true)
    }
}

//MARK:- Tap gesture  delegate
extension CommentsViewController: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        if self.isTextViewActive && self.searchTableView.isHidden{
            return true
        }
        return false
    }
}
