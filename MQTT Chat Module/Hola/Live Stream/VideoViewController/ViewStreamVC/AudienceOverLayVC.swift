//
//  AudienceOverLayVC.swift
//  Live
//
//  Created by Vengababu Maparthi on 29/11/18.
//  Copyright © 2018 io.ltebean. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

protocol AudienceDelegate: class {
    func streamHasEnded(streamId : String)
    func streamReconnected(streamId : String)
}


class AudienceOverLayVC: UIViewController {

    @IBOutlet weak var followersTableView: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var lblLivePaused: UILabel!
    
    @IBOutlet weak var ViewCount: UILabel!
    @IBOutlet weak var streamName: UILabel!
    @IBOutlet weak var streamTime: UILabel!

    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var topContainerView: UIView!
    
    @IBOutlet weak var eyeView: UIView!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var tableViewBottomConst: NSLayoutConstraint!

    @IBOutlet weak var giftDisplayView: GiftDisplayArea!
    @IBOutlet weak var emitterView: WaveEmitterView!
    
    weak var delegate:AudienceDelegate!
    var chatModel = ChatModel()
    var chatData = [ChatData]()
    var audiStreamID = ""
    var streamer = ""
    var streamStartedTime:Int64 = 0
    var timer:Timer!
    var second:Int64 = 0
    var imageView:UIImageView!
    var isActive : Bool = false
    var isDoneOnce: Bool = false
    var receiverName: String = ""
    var receiverId:String = ""
    var audioPlayer:AVAudioPlayer?
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isActive{
            eyeView.isHidden = true
            self.streamName.text = streamer
            second = ((Helper.getCurrentTimeStamp/1000) - streamStartedTime)
            textField.layer.borderColor = UIColor.lightGray.cgColor
            textField.layer.borderWidth = 1
            
            eyeView.layer.borderColor = UIColor.white.cgColor
            eyeView.layer.borderWidth = 1
            textField.placeholder = "Chat here".localized + "..."
            lblLivePaused.text = "Live video ended".localized
            textField.delegate = self
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.estimatedRowHeight = 30
            tableView.rowHeight = UITableView.automaticDimension
            
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
            tap.delegate = self
            view.addGestureRecognizer(tap)
            KeyboardAvoiding.avoidingView = inputContainer
            runTimer()
            emojiCollectionView.delegate = self
            emojiCollectionView.dataSource = self
            
            
            
            
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.subscribe + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.like + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.gift + audiStreamID, withDelivering: .exactlyOnce)
            MQTT.sharedInstance.subscribeTopic(withTopicName: AppConstants.MQTT.chat + audiStreamID, withDelivering: .exactlyOnce)
            /*need to check*/
            //            MQTT.sharedInstance.delegate = self
            //Subscribing for MQTT stream data
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationSubscribeData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.subscribeStream.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationChatData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamChat.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationGiftData(notification:)), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamGift.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.notificationLikeData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamLike.rawValue), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.getSubscribeStreamData(notification: )), name: NSNotification.Name(rawValue: AppConstants.notificationCenterName.streamNow.rawValue), object: nil)

            tableView.layer.shadowColor = UIColor.darkGray.cgColor
            tableView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            tableView.layer.shadowOpacity = 1.0
            tableView.layer.shadowRadius = 2
        }
    }
    
    @objc func getSubscribeStreamData(notification: Notification){
//         self.getTheStreamingData()
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        guard let messageData = message["data"] as? [String : Any] else{return}
        if let action = messageData["action"] as? String, action == "wait"{
            lblLivePaused.isHidden = !(audiStreamID == messageData["streamId"] as! String)
        }else if let action = messageData["action"] as? String, action == "stop"{
            if let del = self.delegate{
                del.streamHasEnded(streamId: messageData["streamId"] as! String)
            }
        }
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

    @IBAction func viewFollowersAction(_ sender: Any) {

    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*need to check*/
//        MQTT.sharedInstance.delegate = self
        super.viewWillAppear(animated)
        
        if self.isActive{
            tableView.contentInset.top = tableView.bounds.height
            tableView.reloadData()
            self.getTheChatData(streamID:audiStreamID)
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

    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
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
    
    func postTheChat(message:String,streamID:String) {
        chatModel.postTheChat(message: message, streamID: streamID) { (success) in
        }
    }
    
    func getTheChatData(streamID:String) {
        chatModel.getChatData(streamID: streamID) { (chatArray, success) in
            if success{
                self.chatData = chatArray
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK:- Buttons Action
    @IBAction func sendMessage(_ sender: Any) {
        let storyboard  = UIStoryboard(name: AppConstants.StoryBoardIds.live, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "giftChooser") as! GiftChooserViewController
        controller.audiStreamID = audiStreamID
        controller.delegate = self
        controller.receiverName = self.receiverName
        controller.receiverId = self.receiverId
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sentHearts(_ sender: Any) {
        let dict = ["message":"0",
                    "streamID":audiStreamID]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            print(jsonData)
            MQTT.sharedInstance.publishData(wthData: jsonData, onTopic: AppConstants.MQTT.like + audiStreamID, retain: false, withDelivering: .exactlyOnce)
        }catch{
            
        }
        let image = UIImage(named: "like_on")
        self.emitterView.emitImage(image!)
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
}

extension AudienceOverLayVC:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: self.emojiCollectionView){
            return false
        }else{
            return true
        }
    }
    
}

extension AudienceOverLayVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            if let text = textField.text , text != "" {
                self.postTheChat(message: text, streamID: audiStreamID)
            }
            textField.text = ""
            return false
        }
        return true
    }
    
}

extension AudienceOverLayVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.comment = chatData[(indexPath as NSIndexPath).row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Followers", for: indexPath) as! Followers
            return cell
        }
    }
    
}



extension AudienceOverLayVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize()
        cellSize.width = self.widthOfTheLabel(text: EmojiData.data[indexPath.row], height: 25)
        cellSize.height = 35
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.postTheChat(message: EmojiData.data[indexPath.row], streamID: audiStreamID)
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

/*need to check*/
//extension AudienceOverLayVC:MQTTManagerDelegate{
//    func receivedMessage(_ message: [String : Any]!, andChannel channel: String!) {
//        if channel == "stream-chat/" + audiStreamID{
//            if let dict = message["data"] as? [String:Any]{
//                chatData.append(ChatData.init(data: dict))
//            }
//            self.tableView.reloadData()
//        }  else if channel == "stream-like/" + audiStreamID{
//            let image = UIImage(named: "like_on")
//            self.emitterView.emitImage(image!)
//        }
//        else if channel == "stream-subscribe/" + audiStreamID{
//            if let dict = message["data"] as? [String:Any]{
//                if let action = dict["action"] as? String, action == "stop"{
//                    if let del = self.delegate{
//                        del.streamHasEnded()
//                        del.streamReconnected(streamId: (dict["action"] as? String)!)
//                    }
//                }
//                if let viewers = dict["activeViewwers"] as? Int {
//                    self.ViewCount.text = "\(viewers)"
//                }
//            }else if let dict = message{
//                if let messageType = dict["messageType"] as? String{
//                    if messageType == "0"{
//                        if let del = self.delegate{
//                            del.streamReconnected(streamId: dict["streamID"] as! String)
//                        }
//                    }
//                }
//            }
//        }else if channel == "stream-gift/" + audiStreamID{
//            if self.imageView != nil{
//                self.imageView.removeFromSuperview()
//            }
//            let event = GiftEvent(dict: message)
//            self.giftDisplayView.pushGiftEvent(event)
//            if let gif = message["gifs"] as? String{
//                self.showGifAndHide(gifUrl:gif)
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
//        imageView.contentMode = .scaleAspectFill
//        imageView.frame = CGRect(x: self.giftDisplayView.bounds.width + 5, y:UIScreen.main.bounds.height - 450, width: 100, height: 100)
//        self.view.addSubview(imageView)
//        self.view.bringSubviewToFront(imageView)
//
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
//            if self.imageView != nil{
//                self.imageView.removeFromSuperview()
//            }
//        }
//    }
//
//}

//MARK:- MQTT channel subscription selector methods
extension AudienceOverLayVC{
    
    @objc func notificationSubscribeData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        
        if let dict = message["data"] as? [String:Any]{
            if let action = dict["action"] as? String, action == "stop"{
                if let del = self.delegate{
                    del.streamHasEnded(streamId: (dict["streamId"] as? String)!)
                    del.streamReconnected(streamId: (dict["action"] as? String)!)
                }
            }
            if let viewers = dict["activeViewwers"] as? Int {
                if viewers > 0 {
                    self.ViewCount.text = "\(viewers)"
                }else{
                    self.ViewCount.text = "0"
                }
                
            }
        }else{
            if let messageType = message["messageType"] as? String{
                if messageType == "0"{
                    if let del = self.delegate{
                        del.streamReconnected(streamId: message["streamID"] as! String)
                        lblLivePaused.isHidden = true
                    }
                }
            }
        }
    }
    
    @objc func notificationChatData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        
        if let dict = message["data"] as? [String:Any]{
            self.chatData.append(ChatData.init(data: dict))
        }
        self.tableView.reloadData()
    }
    
    @objc func notificationGiftData(notification: Notification){
        guard let chatData = notification.userInfo as? [String : Any] else{return}
        guard let message = chatData["data"] as? [String : Any] else{return}
        
        
        if self.imageView != nil{
            self.imageView.removeFromSuperview()
        }
        let event = GiftEvent(dict: message)
        self.giftDisplayView.pushGiftEvent(event)
        if let gif = message["gifs"] as? String{
            self.showGifAndHide(gifUrl:gif)
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





class Followers: UITableViewCell {
    
    @IBOutlet weak var followerImg: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerFullName: UILabel!
    @IBOutlet weak var followerUserName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.setTitle("Follow".localized, for: .normal)
        followButton.layer.cornerRadius = 3
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.darkGray.cgColor
        self.followerImg.makeCornerRadious(readious: self.followerImg.frame.size.width / 2)
    }
}


extension AudienceOverLayVC: GiftChooserViewControllerDelegate {
    func sentGiftCoinAnimation() {
        
    }
    
    /* Bug Name : "LIVESTREAM In other person livestream, user is able to send gifts when there are no coins or not. In other person
     livestream, user should not be able to send gifts when there are no coins."
     Fix Date : 09-apr-2021
     Fixed By : Jayaram G
     Description Of Fix : Added navigation to coinwallet if there is no coins
     */
    
    func navigateToCoinWallet() {
        let storyBoard = UIStoryboard(name: "CoinWallet", bundle: nil)
        guard let destinationVC = storyBoard.instantiateViewController(withIdentifier: AppConstants.viewControllerIds.CoinWallet) as? CoinWalletViewController else {return}
        let navVc = UINavigationController(rootViewController: destinationVC)
//        navVc.modalPresentationStyle = .fullScreen
        self.present(navVc, animated: true, completion: nil)
    }
    
    func sentGiftCoinAnimation(chatData: [String: Any]) {
        
//        if self.imageView != nil{
//            self.imageView.removeFromSuperview()
//        }s
//        let event = GiftEvent(dict: chatData)
//        self.giftDisplayView.pushGiftEvent(event)
//        if let gif = chatData["gifs"] as? String{
//            self.showGifAndHide(gifUrl:gif)
//        }
    }
    
    
}

