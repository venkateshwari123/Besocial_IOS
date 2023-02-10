//
//  LiveOverlayViewController.swift
//  Live
//
//  Created by Vengababu Maparthi on 24/11/18.
//  Copyright © 2018 Vengababu Maparthi. All rights reserved.
//

import UIKit
import Kingfisher

protocol BackToVCDelegate: class {
    func streamHasEnded()
    func changeCameraAudio(type:Int, button : UIButton)
    func endButtonHandle()
}

import IHKeyboardAvoiding

class LiveOverlayViewController: UIViewController {

    @IBOutlet weak var btnEnd: DesignableButton!
    @IBOutlet weak var giftDisplayView: GiftDisplayArea!
    
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var emitterView: WaveEmitterView!
    @IBOutlet weak var bottomTableViewConst: NSLayoutConstraint!
    @IBOutlet weak var followersTableView: UITableView!
    weak var delegate:BackToVCDelegate!
    
    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewCountBtnOutlet: UIButton!
    @IBOutlet weak var vwNoViewers: UIView!
    @IBOutlet weak var eyeView: UIView!
    @IBOutlet weak var livelbl: UILabel!
    @IBOutlet weak var viewerLbl: UILabel!
    @IBOutlet weak var noFollowerLbl: UILabel!
    
    var chatModel = ChatModel()
    var chatData = [ChatData]()
    var timer:Timer!
    var second = 0
//    var viewers = [Viewers]()
    var imageView:UIImageView!
    var isActive : Bool = false
    var audiStreamID : String = ""
    var isDoneOnce: Bool = false
    var audioPlayer:AVAudioPlayer?
    
    @IBOutlet weak var ViewCount: UILabel!
    
    @IBOutlet weak var streamTime: UILabel!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if Utility.getDeviceHasSafeAreaStatus() {
            self.topViewTopConstraint.constant = 10
        }else {
            self.topViewTopConstraint.constant = 0
        }
        if self.isActive{
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth = 1
            livelbl .text = "Live".localized
            viewerLbl.text = "Viewers".localized
            textField.placeholder = "Chat here".localized + "..."
            noFollowerLbl.text = "You don't have any viewers yet".localized + "."
            btnEnd.setTitle("End".localized, for: .normal)
            eyeView.layer.borderColor = UIColor.white.cgColor
            eyeView.layer.borderWidth = 1
            
            
            textField.delegate = self
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 30
            tableView.rowHeight = UITableView.automaticDimension
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
            tap.delegate = self
            view.addGestureRecognizer(tap)
            KeyboardAvoiding.avoidingView = inputContainer
            
            
            //Subscribing for MQTT stream data
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationSubscribeData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.subscribeStream.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationChatData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamChat.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationGiftData(notification:)), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamGift.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLikeData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamLike.rawValue), object: nil)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isActive{
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.subscribe + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.like + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.gift + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.chat + audiStreamID, withDelivering: .exactlyOnce)
            
            tableView.contentInset.top = tableView.bounds.height
            tableView.reloadData()
            self.runTimer()

        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.makeGradientColorForUserAndTopView()
        /*
         Bug Name:- network handling
         Fix Date:- 20/04/21
         Fix By  :- Nikunj C
         Description of Fix:- check connectivity and show popup for no internet
         */
        Helper.checkConnectionAvaibility(view: self.view)
    }
    
    
    func makeGradientColorForUserAndTopView(){
        if !self.isDoneOnce{
            self.isDoneOnce = true
            let colorTop =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
            let colorBottom = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5)
            self.makeGradiantColor(onView: self.inputContainer, topColor: colorTop, bottomColor: colorBottom)
            self.makeGradiantColor(onView: self.topContainerView, topColor: colorBottom, bottomColor: colorTop)
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MQTT.sharedInstance.unsubscribeTopic(topic: AppConstants.MQTT.subscribe + audiStreamID)
        MQTT.sharedInstance.unsubscribeTopic(topic: AppConstants.MQTT.chat + audiStreamID)
        MQTT.sharedInstance.unsubscribeTopic(topic: AppConstants.MQTT.like + audiStreamID)
        MQTT.sharedInstance.unsubscribeTopic(topic: AppConstants.MQTT.gift + audiStreamID)
        NotificationCenter.default.removeObserver(self)
//        self.timer.invalidate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(LiveOverlayViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        second = second + 1
        let hours = Int(second) / 3600
        let minutes = Int(second) / 60 % 60
        let seconds = Int(second) % 60
        
        streamTime.text = String(format:"%02i:%02i:%02i", hours, minutes, seconds)
      
    }
    
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        if self.bottomTableViewConst.constant == 0 {
            self.bottomTableViewConst.constant = -360
            self.viewCountBtnOutlet.isEnabled = true
        }
        
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
        textField.resignFirstResponder()
    }
    
    @objc func tick(_ timer: Timer) {
        guard chatData.count > 0 else {
            return
        }
        if tableView.contentSize.height > tableView.bounds.height {
            tableView.contentInset.top = 0
        }
        tableView.scrollToRow(at: IndexPath(row: chatData.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    //MARK:- Buttons action
    
    @IBAction func btnEndAction(_ sender: Any) {
        self.delegate.endButtonHandle()
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let streamId = Utility.getStreamId(){
            if let text = textField.text , text != "" {
                self.postTheChat(message: text, streamID: streamId)
                self.textField.text = ""
            }
           // textField.resignFirstResponder()
        }
    }
    
    @IBAction func viewFollowers(_ sender: Any) {
        if self.bottomTableViewConst.constant == 0 {
            self.viewCountBtnOutlet.isEnabled = true
            self.bottomTableViewConst.constant = -280
        }else{
            self.getFollowersServiceCall()
            self.viewCountBtnOutlet.isEnabled = false
            self.bottomTableViewConst.constant = 0
        }
        
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
//        self.followersTableView.reloadData()
    }
    
    
    @IBAction func muteTheAudio(_ sender: UIButton) {
        if sender.isSelected == true{
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
        
        delegate.changeCameraAudio(type: 1, button : sender)
    }
    
    @IBAction func flipCamera(_ sender: Any) {
        delegate.changeCameraAudio(type: 2, button : btnSwitchCamera)
    }
    
    func widthOfTheLabel(text: String, height: CGFloat) -> CGFloat {
        
        let label: UILabel = UILabel(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: CGFloat.greatestFiniteMagnitude,
                                                   height: height))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        
        return label.frame.width + 25
    }
    
    //MARK:- Service call
    func postTheChat(message:String,streamID:String) {
        chatModel.postTheChat(message: message, streamID: streamID) { (success) in
            if success{
                
            }
        }
    }
    
    func getFollowersServiceCall(){
        guard let streamId = Utility.getStreamId() else{return}
        guard let userId = Utility.getUserid() else{return}
        chatModel.getSubscriberUserList(stramId: streamId, userId: userId) { (success) in
            if success{
                self.followersTableView.reloadData()
            }
        }
    }
}


extension LiveOverlayViewController:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.emojiCollectionView){
            return false
        }else{
            return true
        }
    }
}

extension LiveOverlayViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if Utility.getDeviceHasSafeAreaStatus() {
            self.topViewTopConstraint.constant = 40
        }else {
            self.topViewTopConstraint.constant = 0
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            if let streamId =  Utility.getStreamId(){
                textField.resignFirstResponder()
                if let text = textField.text , text != ""{
                    self.postTheChat(message: text, streamID: streamId)
                }
                textField.text = ""
            }
            return false
        }
        return true
    }
}

extension LiveOverlayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView{
            return chatData.count
        }else{
            return self.chatModel.viewerList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
            cell.comment = chatData[(indexPath as NSIndexPath).row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Followers", for: indexPath) as! Followers
            let data = self.chatModel.viewerList[indexPath.row]
            cell.followerUserName.text = data.firstName + " " + data.lastName
            cell.followButton.addTarget(self, action: #selector(followButtonAction(_:)), for: .touchUpInside)
            cell.followButton.tag = indexPath.row
            cell.followerFullName.text = data.name
            Helper.addedUserImage(profilePic: data.image, imageView: cell.followerImg, fullName: data.firstName + " " + data.lastName)
            let title = data.following == 0 ? "Follow".localized : "Following".localized
            cell.followButton.setTitle(title, for: .normal)
            return cell
        }
    }
    
    @objc func followButtonAction(_ button: UIButton){
        let index = button.tag
        self.chatModel.followAndUnFollowUserService(index: index)
        self.followersTableView.reloadData()
    }
}

extension LiveOverlayViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    // EmojiData
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize()
        cellSize.width = self.widthOfTheLabel(text: EmojiData.data[indexPath.row], height: 25)
        cellSize.height = 35
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let streamId = Utility.getStreamId() else{return}
        self.postTheChat(message: EmojiData.data[indexPath.row], streamID: streamId)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmojiData.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionCell", for: indexPath) as! EmojiCollectionCell
        cell.emojiText.text = EmojiData.data[indexPath.row]
        return cell
    }
}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var custImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var message: UILabel!
    
    var comment: ChatData! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentContainer.layer.cornerRadius = 5
    }
    
    func updateUI() {
        /*need to check*/
        var font = Utility.Font.Bold.ofSize(14)
        var attributed = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        [ convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]
        let attributedMessage = NSMutableAttributedString(string: comment.message, attributes: convertToOptionalNSAttributedStringKeyDictionary(attributed))
        message.attributedText = attributedMessage
        
            //.attributedComment()
//        message.text = comment.message
        titleLabel.text = comment.name
        Helper.addedUserImage(profilePic: comment.userImage, imageView:             self.custImg, fullName: comment.name)

//        self.custImg.kf.setImage(with: URL(string: comment.userImage),
//                                     placeholder:#imageLiteral(resourceName: "defaultImage"),
//                                     options: [.transition(ImageTransition.fade(1))],
//                                     progressBlock: { receivedSize, totalSize in
//        },
//                                     completionHandler: { image, error, cacheType, imageURL in
//        })
    }
}

/*need to check*/
//extension LiveOverlayViewController:MQTTManagerDelegate{
//    func receivedMessage(_ message: [String : Any]!, andChannel channel: String!) {
//
//        var streamId = ""
//        if (UserDefaults.standard.object(forKey: "streamID") != nil){
//            streamId = Utility.getStreamId()
//            if channel == "stream-chat/" + streamId{
//                if let dict = message["data"] as? [String:Any]{
//                    chatData.append(ChatData.init(data: dict))
//                }
//                self.tableView.reloadData()
//            }else if channel == "stream-like/" + streamId{
//                let image = UIImage(named: "like_on")
//                self.emitterView.emitImage(image!)
//            }else if channel == "stream-subscribe/" + streamId{
//                if viewers.count > 0{
//                    if let viewerDict = message["data"] as? [String:Any]{
//                        if viewerDict["action"] as! String == "unsubscribe"{
//                            viewers.removeAll(where: {$0.id == viewerDict["id"] as! String})
//                        }else if viewerDict["action"] as! String == "stop"{
//
//                        }else{
//                            if !viewers.contains(where:{$0.id == viewerDict["id"] as! String} ){
//                                viewers.append(Viewers.init(dict: viewerDict))
//                            }
//                        }
//                    }
//                }else{
//                    if let viewerDict = message["data"] as? [String:Any]{
//                        viewers.append(Viewers.init(dict: viewerDict))
//                    }
//                }
//                self.ViewCount.text = "\(viewers.count)"
//                self.followersTableView.reloadData()
//
//            }else if channel == "stream-gift/" + streamId{
//                if self.imageView != nil{
//                    self.imageView.removeFromSuperview()
//                }
//                let event = GiftEvent(dict: message )
//                self.giftDisplayView.pushGiftEvent(event)
//                if let gif = message["gifs"] as? String{
//                    self.showGifAndHide(gifUrl:gif)
//                }
//            }
//        }
//    }
//
//    func showGifAndHide(gifUrl:String){
//        if !gifUrl.contains(".gif") {
//            return
//        }
//        let jeremyGif = UIImage.gifImageWithURL(gifUrl)
//        imageView = UIImageView(image: jeremyGif)
//        imageView.frame = CGRect(x: self.giftDisplayView.bounds.width + 5, y:UIScreen.main.bounds.height - 450, width: 100, height: 100)
//        imageView.contentMode = .scaleAspectFill
//        self.view.addSubview(imageView)
//        self.view.bringSubviewToFront(imageView)
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//            if self.imageView != nil{
//                self.imageView.removeFromSuperview()
//            }
//        }
//    }
//}

//MARK:- MQTT channel subscription selector methods
extension LiveOverlayViewController{
    
    @objc func notificationSubscribeData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        
//        if viewers.count > 0{
//            if let viewerDict = message["data"] as? [String:Any]{
//                if viewerDict["action"] as! String == "unsubscribe"{
//                    viewers.removeAll(where: {$0.id == viewerDict["id"] as! String})
//                }else if viewerDict["action"] as! String == "stop"{
//
//                }else{
//                    if !viewers.contains(where:{$0.id == viewerDict["id"] as! String} ){
//                        viewers.append(Viewers.init(dict: viewerDict))
//                    }
//                }
//            }
//        }else{
//            if let viewerDict = message["data"] as? [String:Any]{
//                if let action = viewerDict["action"] as? String, action == "stop"{
//                }
//                else{
//                    viewers.append(Viewers.init(dict: viewerDict))
//                }
//            }
//        }
        guard let viewersData = message["data"] as? [String : Any] else{return}
        guard let count = viewersData["activeViewwers"] as? Int else{return}
        if count > 0 {
            self.ViewCount.text = "\(count)"
            self.vwNoViewers.isHidden = true
        }else{
            self.ViewCount.text = "0"
            self.vwNoViewers.isHidden = false
        }
        
        
//        self.followersTableView.reloadData()
        
        
    }
    
    @objc func notificationChatData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let dict = chatData["data"] as? [String : Any] else{return}
        if let _ = Utility.getStreamId(), let data = dict["data"] as? [String : Any]{
            self.chatData.append(ChatData.init(data: data))
            self.tableView.reloadData()
        }
    }
    
    @objc func notificationGiftData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        if self.imageView != nil{
            self.imageView.removeFromSuperview()
        }
        let event = GiftEvent(dict: message )
        self.giftDisplayView.pushGiftEvent(event)
        playCoinsSound()
        if let gif = message["gifs"] as? String{
            print(gif)
            self.showGifAndHide(gifUrl:gif)
        }
    }
    
    func playCoinsSound() {
           guard let path = Bundle.main.path(forResource: "Coin-collect-sound-effect", ofType: "mp3") else{
               return
           }
           guard let url = URL(string: path) else{return}
           do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker,.allowBluetooth,.allowBluetooth,.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
           }catch let error{
               print(error.localizedDescription)
           }
       }
    
    @objc func notificationLikeData(notification: Notification){
//        guard let chatData = notification.userInfo as? [String : Any] else{return}
        let image = UIImage(named: "like_on")
        self.emitterView.emitImage(image!)
    }
    
    func showGifAndHide(gifUrl:String){
        /*
         Bug Name:- Animating gif
         Fix Date:- 15/06/21
         Fix By  :- Jayaram G
         Description of Fix:- removing gif instead of moving
         */
        if !gifUrl.contains(".gif") {
            return
        }
        let jeremyGif = UIImage.gifImageWithURL(gifUrl)
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: self.giftDisplayView.bounds.width + 5, y:UIScreen.main.bounds.height - 450, width: 100, height: 100)
        imageView.contentMode = .scaleAspectFill
        self.view.addSubview(imageView)
        self.view.bringSubviewToFront(imageView)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            if self.imageView != nil{
                self.imageView.removeFromSuperview()
            }
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
